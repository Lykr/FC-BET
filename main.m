clear;

%% Raw data generation
param.bs.x = 80; % position of base station
param.bs.y = 80;
param.bs.frequency_carrier = 28e9; % frequency of carrier
param.bs.num_antenna = 64; % number of base station antenna
param.bs.beam_info = get_beam_info(param.bs.num_antenna, 2 * param.bs.num_antenna); % get beam codebook for bs

param.veh.num_antenna = 16; % number of veh's antenna
param.veh.beam_info = get_beam_info(param.veh.num_antenna, 2 * param.veh.num_antenna); % get beam codebook for veh
param.veh.beam_info.SNR = 30; % receiver's SNR in dB

param.channel.L = 20;
param.channel.lambda = 1.8;
param.channel.r_tau = 2.8;
param.channel.zeta = 4.0;
param.channel.spread_t = 10.2 / 180 * pi; % 10.2 degree
param.channel.spread_r = 15.5 / 180 * pi; % 15.5 degree

training_raw_data = get_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
testing_raw_data = get_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);

%% Learning data generation
lstm_step = 3;

[train_x, train_y, train_others] = get_learning_data(training_raw_data, lstm_step);
[test_x, test_y, test_others] = get_learning_data(testing_raw_data, lstm_step);

% Normalization
mu = mean([train_x{:}], 2);
sig = std([train_x{:}], 0, 2);

train_x = normalize_data(train_x, mu, sig);
test_x = normalize_data(test_x, mu, sig);

% Remove invalid data
% [train_x, train_y] = remove_invalid_data(train_x, train_y);

%% LSTM network training

% Define LSTM network
input_size = size(train_x{1}, 1);
num_hidden_units = 50;
num_responses = 2;% numel(categories(train_y)); % info_vehs.num_antenna * info_bs.num_antenna;

layers = [ ...
    sequenceInputLayer(input_size)
    bilstmLayer(num_hidden_units, 'OutputMode', 'last')
    fullyConnectedLayer(num_responses)
    regressionLayer];

max_epochs = 2000;
mini_batch_size = numel(train_x);

options = trainingOptions('adam' , ...
    'ExecutionEnvironment', 'cpu', ...
    'GradientThreshold', 1, ...
    'InitialLearnRate', 0.01, ...
    'MaxEpochs', max_epochs, ...
    'MiniBatchSize', mini_batch_size, ...
    'SequenceLength', 'longest', ...
    'Shuffle', 'never', ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

% Train network
net = trainNetwork(train_x, train_y, layers, options);

%% LSTM network testing
pred_y = predict(net, test_x);

%% Result
figure(1);
hold on;
plot(test_y(:, 2), '.');
plot(test_y(:, 1), '.');
plot(pred_y(:, 2), 'x');
plot(pred_y(:, 1), 'x');
hold off;
xlim([0 length(pred_y)]);
legend('AOD: Exhausted Search', 'AOA: Exhausted Search', 'AOD: LSTM-Based Prediction', 'AOA: LSTM-Based Prediction')

% h_pred = get_h_pred(pred_y);
% 
% figure(2);
% hold on;
% plot(norm(h_pred - h_est) / norm(h_est), '.');
% hold off;

nrmse = sqrt(mean((pred_y(:, 2) - test_y(:, 2)) .^ 2) / mean(test_y(:, 2) .^2));
