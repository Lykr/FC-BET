clear;

%% Raw data generation
info_bs.x = 80; % position of base station
info_bs.y = 80;
info_bs.num_antenna = 64; % number of base station antenna
info_bs.frequency_carrier = 28e9; % frequency of carrier
info_vehs.num_antenna = 16;

training_raw_data = get_raw_data(info_bs, info_vehs, load('sumo_output_for_training.mat').sumo_output);
testing_raw_data = get_raw_data(info_bs, info_vehs, load('sumo_output_for_testing.mat').sumo_output);

%% Learning data generation
lstm_step = 3;

[train_x, train_y] = get_learning_data(training_raw_data, lstm_step);
[test_x, test_y] = get_learning_data(testing_raw_data, lstm_step);

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
num_hidden_units = 100;
num_responses = 2;% numel(categories(train_y)); % info_vehs.num_antenna * info_bs.num_antenna;

layers = [ ...
    sequenceInputLayer(input_size)
    bilstmLayer(num_hidden_units, 'OutputMode', 'last')
    dropoutLayer(0.2)
    fullyConnectedLayer(num_responses)
    regressionLayer];

max_epochs = 500;
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
plot(pred_y(:, 2), 'x');
plot(test_y(:, 2), '.');
plot(pred_y(:, 1), 'x');
plot(test_y(:, 1), '.');
hold off;
xlim([0 length(pred_y)]);
legend('AOD: LSTM-Based Prediction', 'AOD: Exhausted Search', 'AOA: LSTM-Based Prediction', 'AOA: Exhausted Search')

h_pred = get_h_pred(pred_y);

figure(2);
hold on;
plot(norm(h_pred - h_est) / norm(h_est), '.');
hold off;

% nrmse = sqrt(mean((pred_y(:, 2) - test_y(:, 2)) .^ 2) / mean(test_y(:, 2) .^2));
