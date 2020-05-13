clear;

%% Raw data generation
info_bs.x = 80; % position of base station
info_bs.y = 80;
info_bs.num_antenna = 64; % number of base station antenna
info_bs.frequency_carrier = 28e9; % frequency of carrier
info_vehs.num_antenna = 16;

training_raw_data = load('sumo_output_for_training.mat');
training_raw_data = get_raw_data(info_bs, info_vehs, training_raw_data.sumo_output);
testing_raw_data = load('sumo_output_for_testing.mat');
testing_raw_data = get_raw_data(info_bs, info_vehs, testing_raw_data.sumo_output);

%% Train data generation
lstm_step = 3;

[train_x, train_y] = get_learning_data(training_raw_data, lstm_step);
[test_x, test_y] = get_learning_data(testing_raw_data, lstm_step);

%% LSTM
