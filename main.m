clear;

%% Raw data generation
info_bs.x = 80; % position of base station
info_bs.y = 80;
info_bs.num_antenna = 64; % number of base station antenna
info_bs.frequency_carrier = 28e9; % frequency of carrier
info_vehs.num_antenna = 16;

load('sumo_output.mat');
raw_data = get_raw_data(info_bs, info_vehs, sumo_output);

%% Train data generation
lstm_step = 3;

[data_x, data_y] = get_train_data(raw_data, lstm_step);

%% LSTM
