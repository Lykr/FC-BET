clear;

%% Raw data generation
info_bs.x = 120; % position of base station
info_bs.y = 120;
info_bs.num_antenna = 16; % number of base station antenna
info_bs.frequency_carrier = 28e9; % frequency of carrier
info_vehs.num_antenna = 4;

training_raw_data = load('sumo_output_for_training.mat');
training_raw_data = get_raw_data(info_bs, info_vehs, training_raw_data.sumo_output);
testing_raw_data = load('sumo_output_for_testing.mat');
testing_raw_data = get_raw_data(info_bs, info_vehs, testing_raw_data.sumo_output);

%% Learning data generation
lstm_step = 10;

[train_x, train_y] = get_learning_data(training_raw_data, lstm_step);
[test_x, test_y] = get_learning_data(testing_raw_data, lstm_step);

% Normalization
mu = mean([train_x{:}], 2);
sig = std([train_x{:}], 0, 2);

for i = 1 : numel(train_x)
    train_x{i} = (train_x{i} - mu) ./ sig;
end

for i = 1 : numel(test_x)
    test_x{i} = (test_x{i} - mu) ./ sig;
end

%% LSTM network training

% Define LSTM network
input_size = info_vehs.num_antenna * info_bs.num_antenna * 2; % real and imag parts
num_hidden_units = 100;
num_responses = 1;% numel(categories(train_y)); % info_vehs.num_antenna * info_bs.num_antenna;

layers = [ ...
    sequenceInputLayer(input_size)
    lstmLayer(num_hidden_units, 'OutputMode', 'last')
    fullyConnectedLayer(50)
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
    'Shuffle', 'never', ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

% Train network
net = trainNetwork(train_x, train_y, layers, options);

%% LSTM network testing
% Test network
% pred_y = classify(net, test_x, ...
%     'MiniBatchSize', mini_batchSize, ...
%     'SequenceLength', 'longest');

% Calculate accurracy
% acc = sum(pred_y == test_y) ./ numel(test_y)

pred_y = predict(net, test_x);

%% Result
figure(1);
hold on;

plot(pred_y, '.');
plot(test_y, 'LineWidth', 2);
legend('Pred', 'Act')
nrmse = sqrt(mean((pred_y - test_y) .^ 2) / mean(test_y .^2));
