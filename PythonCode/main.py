import math
import numpy as np
import scipy.io as sio
import scipy.constants as sconsts
import matplotlib.pyplot as plt
from keras.models import Sequential
from keras.layers import Dense, LSTM, Dropout
from scipy.signal import savgol_filter

def vector_to_angle(vec):
    angle = math.atan2(vec[1], vec[0])
    return angle if angle >= 0 else angle + 2 * np.pi

def gen_eMatrix(n, angle):
    eMatrix = np.ones([n, 1], dtype=complex)
    
    for i in range(n):
        eMatrix[i] = np.exp(1j * np.pi * i * np.cos(angle))
    
    eMatrix = 1 / np.sqrt(n) * eMatrix

    return eMatrix

def get_e(num_atenna, angles):
    r = num_atenna
    c = len(angles)
    e = np.zeros([r, c], dtype=complex)
    
    for i in range(c):
        e[:, i] = gen_eMatrix(r, angles[i]).reshape(r)

    return e

def gen_channel(param, veh_data):
    # Generate channel matrix from parameters
    # angle: right,anti-clockwise array: right, up

    # Get AOA and AOD from raw data
    veh_x = veh_data[0][0][0]
    veh_y = veh_data[1][0][0]
    veh_speed = veh_data[2][0][0]
    veh_angle = veh_data[3][0][0]
    vector_bs_to_veh = np.array([veh_x, veh_y]) - np.array([param['bs']['x'], param['bs']['y']])
    vector_veh_to_bs = -vector_bs_to_veh
    aod = vector_to_angle(vector_bs_to_veh)
    aoa = vector_to_angle(vector_veh_to_bs)
    angle_veh_turn = veh_angle - np.pi / 2
    aoa = aoa - angle_veh_turn

    # Get channel parameters
    L = param['channel']['L'] # number of subpath
    spread_e_r = param['channel']['spread_e_r']
    spread_e_t = param['channel']['spread_e_t']
    K = 1 # max(poissrnd(param.channel.lambda), 1)
    r_tau = param['channel']['r_tau']
    zeta = param['channel']['zeta']

    # generate cluster parameters
    gamma = np.random.rand(K, 1) ** (r_tau - 1) * np.random.randn(K, 1) * zeta
    gamma = gamma / sum(gamma)
    gamma = np.kron(gamma, np.ones([L, K]))

    # generate subpath parameters
    spread_r = np.random.exponential(spread_e_r)
    spread_t = np.random.exponential(spread_e_t)
    aoas = np.angle(np.exp(1j * (aoa + np.angle(np.exp(1j*np.random.randn(K * L, 1) * spread_r)))))
    aods = np.angle(np.exp(1j * (aod + np.angle(np.exp(1j*np.random.randn(K * L, 1) * spread_t)))))

    # generate array response vector
    e_r = get_e(param['veh']['num_antenna'], aoas)
    e_t = get_e(param['bs']['num_antenna'], aods)

    # generate small scale fading gain
    c = sconsts.speed_of_light
    carrier_length = c / param['bs']['frequency_carrier']
    relative_angle = aoas - np.pi / 2
    time_transmission = np.linalg.norm(vector_bs_to_veh) / c
    doppler_part = np.exp(1j * 2 * np.pi * time_transmission * veh_speed / carrier_length * np.cos(relative_angle))
    distance = np.linalg.norm(vector_bs_to_veh)
    path_loss = 61.4 + 10 * 2 * np.log10(distance) + np.random.randn() * 5.8
    small_scale_fading_gain = np.sqrt(gamma * 10 ** (-0.1 * path_loss) / 2) * (np.random.randn(K * L, 1) + 1j * np.random.randn(K * L, 1)) * doppler_part

    # channel struct
    h = np.sqrt(param['veh']['num_antenna'] * param['bs']['num_antenna']) / np.sqrt(L) * np.matmul(e_r, np.matmul(np.diag(small_scale_fading_gain.squeeze()), e_t.T))

    if aoa > np.pi:
        aoa = 2 * np.pi - aoa

    if aod > np.pi:
        aod = 2 * np.pi - aod

    angles = [aoa, aod]

    return [angles, h]

def beam_sweep(channel, param):
    veh_beam_book = param['veh']['beam_info']['beam_book']
    veh_beam_angles = param['veh']['beam_info']['beam_angles']

    bs_beam_book = param['bs']['beam_info']['beam_book']
    bs_beam_angles = param['bs']['beam_info']['beam_angles']

    veh_beam_num = len(veh_beam_angles)
    bs_beam_num = len(bs_beam_angles)

    # Y = w' * Hf + w' * n
    n_r = param['veh']['num_antenna']
    var_n = param['channel']['var_n'] # noise variance
    # noise = (randn(veh_beam_num, bs_beam_num, n_r) + 1i * randn(veh_beam_num, bs_beam_num, n_r)) .* sqrt(var_n / 2) % noise part of received signal
    noise = (np.random.randn(n_r, 1) + 1j * np.random.randn(n_r, 1)) * np.sqrt(var_n / 2)
    N = np.zeros([veh_beam_num, bs_beam_num], dtype=complex)

    for i in range(veh_beam_num):
        for j in range(bs_beam_num):
            #         N(i, j) = veh_beam_book(:, i).T * reshape(noise(i, j, :), n_r, 1)
            N[i,j] = np.matmul(veh_beam_book[:, i], noise) # column vector turn to line vector by [:, i]
    
    CSI = dict()
    CSI['noise'] = N

    Hf = np.matmul(channel, bs_beam_book) # useful part of received signal
    S = np.matmul(veh_beam_book.T, Hf)
    Y = S + N # received part signal

    # Get optimal angles and beams
    target = abs(Y)
    [i, j] = np.where(target == np.max(target))
    aoa_est = veh_beam_angles[i[0]]
    aod_est = bs_beam_angles[j[0]]

    CSI['beam_pair'] = [i[0], j[0]]
    CSI['angles_est'] = [aoa_est, aod_est]
    CSI['h_siso_est'] = Y[i[0], j[0]]

    # SNR
    CSI['SNR_est'] = abs(S[i, j]) ** 2 / abs(N[i, j]) ** 2

    return CSI

def gen_raw_data(param, sumo_output):
    timesteps_num = len(sumo_output[0][0])
    data = dict()

    # b['t1'][0][0][0][0][0][0][0][0 - 3][0][0] : 0 - x, 1 - y, 2 - speed, 3 - angle
    for i in range(timesteps_num - 1):
        if i % param['interval'] != 0:
            continue

        veh_data = sumo_output['t' + str(i)][0][0][0][0][0][0][0]

        timestep = 't' + str(int(i / param['interval']))
        
        data[timestep] = dict()
        data[timestep]['speed'] = veh_data[2][0][0]
        
        [angles, h] = gen_channel(param, veh_data)
        data[timestep]['angles'] = angles
        data[timestep]['h'] = h
        
        CSI = beam_sweep(h, param)
        data[timestep]['beam_pair'] = CSI['beam_pair']
        data[timestep]['angles_est'] = CSI['angles_est']
        data[timestep]['h_siso_est'] = CSI['h_siso_est']
        data[timestep]['SNR_act'] = CSI['SNR_est']
        data[timestep]['noise'] = CSI['noise']

    return data

def get_raw_data(param):
    training_raw_data = gen_raw_data(param, sio.loadmat('sumo_output_for_training.mat')['sumo_output'])
    testing_raw_data = gen_raw_data(param, sio.loadmat('sumo_output_for_testing.mat')['sumo_output'])

    return {'train':training_raw_data, 'test':testing_raw_data}

def gen_learning_data(param, raw_data, smooth):
    lstm_step = param['lstm_step']
    veh_beam_shape = np.shape(param['veh']['beam_info']['beam_book'])
    bs_beam_shape = np.shape(param['bs']['beam_info']['beam_book'])
    veh_antenna_num = veh_beam_shape[0]
    bs_antenna_num = bs_beam_shape[0]
    veh_beam_num = veh_beam_shape[1]
    bs_beam_num = bs_beam_shape[1]
    timesteps_num = len(raw_data)
    data_size = timesteps_num - lstm_step

    data_x = np.zeros([data_size, lstm_step, 2], dtype=float)
    temp_x = np.zeros([lstm_step, 2], dtype=float)
    data_y = np.zeros([data_size, 2], dtype=float)
    others = dict()
    others['h_list'] = np.zeros([timesteps_num, veh_antenna_num, bs_antenna_num], dtype=complex)
    others['h_siso_est_list'] = np.zeros([timesteps_num, 1], dtype=complex)
    others['angles_list'] = np.zeros([timesteps_num, 2], dtype=float)
    others['angles_est_list'] = np.zeros([timesteps_num, 2], dtype=float)
    others['smooth_angles_est_list'] = np.zeros([timesteps_num, 2], dtype=float)
    others['SNR_est_list'] = np.zeros([timesteps_num, 1], dtype=float)
    others['noise_list'] = np.zeros([timesteps_num, veh_beam_num, bs_beam_num], dtype=complex)

    # Get data
    for i in range(timesteps_num):
        timestep = 't' + str(i)
        h = raw_data[timestep]['h']
        h_siso_est = raw_data[timestep]['h_siso_est']
        angles = raw_data[timestep]['angles']
        angles_est = raw_data[timestep]['angles_est']
        # beam_pair = raw_data[timestep]['beam_pair']
        # speed = raw_data[timestep]['speed']
        SNR_est = raw_data[timestep]['SNR_act']
        noise = raw_data[timestep]['noise']
        
        # Store raw data into list
        others['h_list'][i] = h
        others['h_siso_est_list'][i] = h_siso_est
        others['angles_list'][i] = angles
        others['angles_est_list'][i] = angles_est
        others['SNR_est_list'][i] = SNR_est
        others['noise_list'][i] = noise

    # Preprocessing
    smooth_angles_est_list = savgol_filter(others['angles_est_list'].T, 51, 1)
    others['smooth_angles_est_list'] = smooth_angles_est_list.T

    for i in range(timesteps_num):
        angles_est = smooth_angles_est_list[:, i] if smooth else others['angles_est_list'].T[:, i]
        x = angles_est.T  # add AOA and AOD as input

        if i >= lstm_step:
            data_x[i - lstm_step] = temp_x
            data_y[i - lstm_step] = x

        # append input
        temp_x[0:-1] = temp_x[1:]
        temp_x[-1] = x

    return [data_x, data_y, others]


def get_learning_data(param, raw_data):
    # Learning data generation
    [x_train, y_train, others_train] = gen_learning_data(param, raw_data['train'], True)
    [x_test, y_test, others_test] = gen_learning_data(param, raw_data['test'], False)
    return {'train':{'x':x_train, 'y':y_train, 'others':others_train}, 'test':{'x':x_test, 'y':y_test, 'others':others_test}}

def gen_beam_info(antenna_num, beam_num):
    beam_book = np.zeros([antenna_num, beam_num], dtype=complex)
    beam_angles = [np.pi / beam_num * x + np.pi / beam_num for x in range(beam_num)]
    
    for i in range(beam_num):
        beam_book[:, i] = gen_eMatrix(antenna_num, beam_angles[i]).reshape(antenna_num)
    
    beam_info = dict()
    beam_info['beam_book'] = beam_book
    beam_info['beam_angles'] = beam_angles

    return beam_info

def evaluate_pred(param, model, learning_data_test):
    lstm_step = param['lstm_step']
    x = learning_data_test['x']
    y = learning_data_test['y']
    others = learning_data_test['others']
    num_pred = np.shape(x)[0] + lstm_step
    y_pred = np.zeros([num_pred, 2], dtype=float)
    SNR_pred = np.zeros([num_pred, 1], dtype=float)

    veh_beam_book = param['veh']['beam_info']['beam_book']
    veh_beam_angles = param['veh']['beam_info']['beam_angles']
    bs_beam_book = param['bs']['beam_info']['beam_book']
    bs_beam_angles = param['bs']['beam_info']['beam_angles']
    h_list = others['h_list']
    noise_list = others['noise_list']

    num_measurements = 0
    num_outage_pred = 0
    num_outage_channel = 0
    cur_feature_size = 0
    cur_feature = np.zeros([1, lstm_step, 2])

    for i in range(num_pred):
        # Check whether initial measurement is done
        if cur_feature_size < lstm_step:
            cur_angles = others['angles_est_list'][i]
            cur_feature_size += 1
            num_measurements += 1
        else:
            cur_angles = model.predict(cur_feature)

        cur_angles = cur_angles.squeeze()

        # combined cur_angles into cur_feature
        cur_feature[:, 0:-1, :] = cur_feature[:, 1:, :]
        cur_feature[:, -1, :] = cur_angles

        y_pred[i] = cur_angles

        # Get response array by cur_angles
        target_veh = abs(veh_beam_angles - cur_angles[0])
        target_bs = abs(bs_beam_angles - cur_angles[0])
        beam_veh = np.where(target_veh == min(target_veh))[0][0]
        beam_bs = np.where(target_bs == min(target_bs))[0][0]
        e_r = veh_beam_book[:, beam_veh]
        e_t = bs_beam_book[:, beam_bs]

        # Calculate SNR under cur_angles
        SNR_pred[i] = abs(np.matmul(e_r.T, np.matmul(h_list[i], e_t))) ** 2 / abs(noise_list[i][beam_veh, beam_bs]) ** 2

        # SNR judgement
        if 10 * np.log10(SNR_pred[i]) <= param['SNR_threshold']:
            if cur_feature_size < lstm_step:
                num_outage_channel += 1
            else:
                num_outage_pred += 1
            cur_feature_size = 0

    return [y_pred, SNR_pred, num_outage_pred, num_outage_channel]

# LSTM network training
def get_model(param, learning_data):
    lstm_step = param['lstm_step']
    angles_num = 2

    # build model
    my_model = Sequential()
    my_model.add(LSTM(50, activation='relu',input_shape=(lstm_step, angles_num), return_sequences=True))
    my_model.add(Dropout(0.2))
    my_model.add(LSTM(50, activation='relu',input_shape=(lstm_step, angles_num), return_sequences=False))
    my_model.add(Dropout(0.2))
    my_model.add(Dense(2))
    my_model.compile(loss='mean_squared_error', optimizer='adam')

    # train model
    my_model.fit(learning_data['train']['x'], learning_data['train']['y'], batch_size=32, epochs=400, verbose=0)

    return my_model

# Parameters
param = dict() # dict for parameters
param['interval'] = 2 # 10ms per interval

param['bs'] = dict()
param['bs']['x'] = 80 # x position of base station
param['bs']['y'] = 80 # y position of base station
param['bs']['frequency_carrier'] = 28e9 # frequency of carrier
param['bs']['num_antenna'] = 16 # number of base station antenna, default to 16
param['bs']['beam_info'] = gen_beam_info(param['bs']['num_antenna'], 2 * param['bs']['num_antenna']) # get beam codebook for bs

param['veh'] = dict()
param['veh']['num_antenna'] = 4 # number of veh's antenna, default to 4
param['veh']['beam_info'] = gen_beam_info(param['veh']['num_antenna'], 2 * param['veh']['num_antenna']) # get beam codebook for veh

param['channel'] = dict()
param['channel']['L'] = 20
param['channel']['lambda'] = 1.8
param['channel']['r_tau'] = 2.8
param['channel']['zeta'] = 4.0
param['channel']['spread_e_t'] = 10.2 / 180 * np.pi # 10.2 degree
param['channel']['spread_e_r'] = 15.5 / 180 * np.pi # 15.5 degree
param['channel']['var_n'] = 1e-12

param['SNR_threshold'] = 5 #in dB

param['lstm_step'] = 5

## Run simulation
simulation_switch = -1 #-1-normal 0-all, 1-var_n, 2-measurements, 3-anttenna, 4-steps

# Normal
if simulation_switch == 0 or simulation_switch == -1:
    raw_data = get_raw_data(param)
    learning_data = get_learning_data(param, raw_data)
    model = get_model(param, learning_data)
    [y_pred, SNR_pred, num_outage_pred, num_outage_channel] = evaluate_pred(param, model, learning_data['test'])

# # Different noise variances of received signal
# if simulation_switch == 0 or simulation_switch == 1:
#     sim_var_n

# # Number of measurement
# if simulation_switch == 0 or simulation_switch == 2:
#     get_raw_data
#     get_learning_data
#     run_simulation
#     n_m_2 = n_m

# # Antenna
# if simulation_switch == 0 or simulation_switch == 3:
#     sim_antenna

# # Steps
# if simulation_switch == 0 or simulation_switch == 4:
#     sim_steps

# ## Check results of networks
# if simulation_switch == -1:
#     check_results