clear;

%% Parameters
param.interval = 5;
param.bs.x = 80; % position of base station
param.bs.y = 80;
param.bs.frequency_carrier = 28e9; % frequency of carrier
param.bs.num_antenna = 16; % number of base station antenna, default to 16
param.bs.beam_info = get_beam_info(param.bs.num_antenna, 2 * param.bs.num_antenna); % get beam codebook for bs

param.veh.num_antenna = 4; % number of veh's antenna, default to 4
param.veh.beam_info = get_beam_info(param.veh.num_antenna, 2 * param.veh.num_antenna); % get beam codebook for veh

param.channel.L = 20;
param.channel.lambda = 1.8;
param.channel.r_tau = 2.8;
param.channel.zeta = 4.0;
param.channel.spread_e_t = 10.2 / 180 * pi; % 10.2 degree
param.channel.spread_e_r = 15.5 / 180 * pi; % 15.5 degree
param.channel.var_n = 10 ^ (-14);

param.SNR_threshold = 5; % in dB

%% Raw data generation
training_raw_data = get_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
testing_raw_data = get_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);

%% Learning data generation
lstm_step = 5;

[x_train, y_train, others_train] = get_learning_data(training_raw_data, lstm_step);
[x_test, y_test, others_test] = get_learning_data(testing_raw_data, lstm_step);

%% Run simulation
run_simulation;
