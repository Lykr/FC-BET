clear;

%% Raw data generation
param.bs.x = 80; % position of base station
param.bs.y = 80;
param.bs.frequency_carrier = 28e9; % frequency of carrier
param.bs.num_antenna = 64; % number of base station antenna
param.bs.beam_info = get_beam_info(param.bs.num_antenna, 2 * param.bs.num_antenna); % get beam codebook for bs

param.veh.num_antenna = 16; % number of veh's antenna
param.veh.beam_info = get_beam_info(param.veh.num_antenna, 2 * param.veh.num_antenna); % get beam codebook for veh

param.channel.L = 20;
param.channel.lambda = 1.8;
param.channel.r_tau = 2.8;
param.channel.zeta = 4.0;
param.channel.spread_e_t = 10.2 / 180 * pi; % 10.2 degree
param.channel.spread_e_r = 15.5 / 180 * pi; % 15.5 degree
param.channel.var_n = 10 ^ (-13);

training_raw_data = get_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
testing_raw_data = get_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);

%% Learning data generation
lstm_step = 10;

[train_x, train_y, train_others] = get_learning_data(training_raw_data, lstm_step);
[test_x, test_y, test_others] = get_learning_data(testing_raw_data, lstm_step);

% Remove invalid data
% [train_x, train_y] = remove_invalid_data(train_x, train_y, pi / 4);

% % Normalization
% mu = mean([train_x{:}], 2);
% sig = std([train_x{:}], 0, 2);
% train_x = normalize_data(train_x, mu, sig);
% test_x = normalize_data(test_x, mu, sig);

%% LSTM network training

% Define LSTM network
input_size = size(train_x{1}, 1);
num_hidden_units = 50;
num_responses = 2;% numel(categories(train_y)); % info_vehs.num_antenna * info_bs.num_antenna;

% crl = custom_regression_layer;
% crl.bs_beam_info = param.bs.beam_info;
% crl.veh_beam_info = param.veh.beam_info;

layers = [ ...
    sequenceInputLayer(input_size)
    lstmLayer(num_hidden_units, 'OutputMode', 'sequence')
    dropoutLayer(0.2)
    lstmLayer(num_hidden_units, 'OutputMode', 'last')
    fullyConnectedLayer(num_responses)
    regressionLayer];

max_epochs = 200;
mini_batch_size = numel(train_x);

options = trainingOptions('adam' , ...
    'ExecutionEnvironment', 'cpu', ...
    'GradientThreshold', 1, ...
    'InitialLearnRate', 0.01, ...
    'MaxEpochs', max_epochs, ...
    'MiniBatchSize', mini_batch_size, ...
    'SequenceLength', 'longest', ...
    'Shuffle', 'once', ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

% Train network
net = trainNetwork(train_x, train_y, layers, options);

%% LSTM network testing
pred_y = predict(net, test_x);

%% Result
t_p = length(pred_y);

% AOA and AOD
figure(1);
hold on;
plot(test_y(:, 1), '.');
plot(test_y(:, 2), '.');
plot(pred_y(:, 1), 'x');
plot(pred_y(:, 2), 'x');
hold off;
xlim([0 t_p]);
ylim([0 pi]);
legend('AOA: Exhausted Search', 'AOD: Exhausted Search', 'AOA: LSTM-based', 'AOD: LSTM-based');

[h_siso_pred, SNR_pred] = evaluate_pred(param, test_others, pred_y);

% h_siso
h_siso_est = test_others.h_siso_est_list(end - t_p + 1 : end);

figure(2);
hold on;
plot((abs(h_siso_pred) - abs(h_siso_est)) ./ abs(h_siso_est), '.');
hold off;
xlim([0 t_p]);
ylim([-1 0]);

% SNR
SNR_threshold = -5; % in dB
SNR_est = 10 * log(test_others.SNR_est_list(end - t_p + 1 : end));
SNR_pred = 10 * log(SNR_pred);
SNR_est_mean = mean(SNR_est);
SNR_pred_mean = mean(SNR_pred);
figure(3);
hold on;
plot(SNR_est, '.');
plot(SNR_pred, '.');
plot([0 t_p], [SNR_est_mean SNR_est_mean], 'LineWidth', 1.5);
plot([0 t_p], [SNR_pred_mean SNR_pred_mean], 'LineWidth', 1.5);
plot([0 t_p], [SNR_threshold SNR_threshold], 'LineWidth', 1.5);
hold off;
xlim([0 t_p]);
legend('Exhausted Search', 'LSTM-based', ...
    'Average SNR of Exhausted Search', 'Average SNR of LSTM-based', ...
    'SNR Threshold');

% CDF of SNR
figure(4);
hold on;
cdf_h1 = cdfplot(SNR_est);
cdf_h2 = cdfplot(SNR_pred);
set(cdf_h1, 'LineWidth', 1.5);
set(cdf_h2, 'LineWidth', 1.5);
plot([SNR_threshold SNR_threshold], [0 1], 'LineWidth', 1.5);
hold off;
legend('Exhausted Search', 'LSTM-based', 'Threshold');

%
nrmse = sqrt(mean((pred_y(:, 2) - test_y(:, 2)) .^ 2) / mean(test_y(:, 2) .^2));
