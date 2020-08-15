clear;

%% Raw data generation
param.interval = 5;
param.bs.x = 80; % position of base station
param.bs.y = 80;
param.bs.frequency_carrier = 28e9; % frequency of carrier
param.bs.num_antenna = 16; % number of base station antenna
param.bs.beam_info = get_beam_info(param.bs.num_antenna, 2 * param.bs.num_antenna); % get beam codebook for bs

param.veh.num_antenna = 4; % number of veh's antenna
param.veh.beam_info = get_beam_info(param.veh.num_antenna, 2 * param.veh.num_antenna); % get beam codebook for veh

param.channel.L = 20;
param.channel.lambda = 1.8;
param.channel.r_tau = 2.8;
param.channel.zeta = 4.0;
param.channel.spread_e_t = 10.2 / 180 * pi; % 10.2 degree
param.channel.spread_e_r = 15.5 / 180 * pi; % 15.5 degree
param.channel.var_n = 10 ^ (-14);

training_raw_data = get_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
testing_raw_data = get_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);

%% Learning data generation
lstm_step = 5;

[x_train, y_train, others_train] = get_learning_data(training_raw_data, lstm_step);
[x_test, y_test, others_test] = get_learning_data(testing_raw_data, lstm_step);

%% LSTM network training

% Define LSTM network
input_size = size(x_train{1}, 1);
num_hidden_units = 50;
num_responses = 2;% numel(categories(train_y));
% info_vehs.num_antenna * info_bs.num_antenna;

% crl = custom_regression_layer;
% crl.bs_beam_info = param.bs.beam_info;
% crl.veh_beam_info = param.veh.beam_info;

layers = [ ...
    sequenceInputLayer(input_size)
    bilstmLayer(num_hidden_units, 'OutputMode', 'sequence')
    dropoutLayer(0.2)
    lstmLayer(num_hidden_units, 'OutputMode', 'last')
    fullyConnectedLayer(num_responses)
    regressionLayer];

max_epochs = 200;
mini_batch_size = numel(x_train);

options = trainingOptions('adam' , ...
    'ExecutionEnvironment', 'cpu', ...
    'GradientThreshold', 1, ...
    'LearnRateDropPeriod',100, ...
    'LearnRateDropFactor',0.2, ...
    'InitialLearnRate', 0.005, ...
    'MaxEpochs', max_epochs, ...
    'MiniBatchSize', mini_batch_size, ...
    'SequenceLength', 'longest', ...
    'Shuffle', 'once', ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

% Train network
net = trainNetwork(x_train, y_train, layers, options);

%% LSTM network testing
SNR_threshold = 5; % in dB
% pred_y = predict(net, test_x);

[y_pred, SNR_pred_n, n_o, n_m] = evaluate_pred(param, others_test, net, x_test, y_test, SNR_threshold);

% [y_kf, SNR_kf, n_o_kf, n_m_kf] = evaluate_kf(param, others_test, x_test, y_test, SNR_threshold);

%% Result
t_p = length(y_pred);

% AOA and AOD
figure(1);
hold on;
plot(y_test(:, 1), '.');
plot(y_test(:, 2), '.');
plot(y_pred(:, 1), 'x');
plot(y_pred(:, 2), 'x');
hold off;
xlim([0 t_p]);
ylim([0 pi]);
legend('AOA: Exhaustive Search', 'AOD: Exhaustive Search', 'AOA: LSTM-based', 'AOD: LSTM-based');

% % h_siso
% h_siso_est = test_others.h_siso_est_list(end - t_p + 1 : end);
% 
% figure(2);
% hold on;
% plot((abs(h_siso_pred) - abs(h_siso_est)) ./ abs(h_siso_est), '.');
% hold off;
% xlim([0 t_p]);
% ylim([-1 0]);

% SNR
SNR_est = 10 * log10(others_test.SNR_est_list(end - t_p + 1 : end));
SNR_est_mean = 10 * log10(mean(others_test.SNR_est_list(end - t_p + 1 : end)));
SNR_pred = 10 * log10(SNR_pred_n);
SNR_pred_mean = 10 * log10(mean(SNR_pred_n));
figure(3);
hold on;
plot(SNR_est, '.');
plot(SNR_pred, '.');
plot([0 t_p], [SNR_est_mean SNR_est_mean], 'LineWidth', 1.5);
plot([0 t_p], [SNR_pred_mean SNR_pred_mean], 'LineWidth', 1.5);
plot([0 t_p], [SNR_threshold SNR_threshold], 'LineWidth', 1.5);
hold off;
xlim([0 t_p]);
legend('Exhaustive Search', 'LSTM-based', ...
    'Average SNR of Exhaustive Search', 'Average SNR of LSTM-based', ...
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
legend('Exhaustive Search', 'LSTM-based', 'Threshold');

%
nrmse = sqrt(mean((y_pred(:, 2) - y_test(:, 2)) .^ 2) / mean(y_test(:, 2) .^2));
