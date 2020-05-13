clear;

%% Raw data generation
info_bs.x = 0; % position of base station
info_bs.y = 0;
info_bs.num_antenna = 16; % number of base station antenna
info_bs.frequency_carrier = 28e9; % frequency of carrier
info_vehs.num_antenna = 4;

training_raw_data = load('sumo_output_for_training.mat');
training_raw_data = get_raw_data(info_bs, info_vehs, training_raw_data.sumo_output);
testing_raw_data = load('sumo_output_for_testing.mat');
testing_raw_data = get_raw_data(info_bs, info_vehs, testing_raw_data.sumo_output);

%% Train data generation
lstm_step = 10;

[train_x, train_y] = get_learning_data(training_raw_data, lstm_step);
[test_x, test_y] = get_learning_data(testing_raw_data, lstm_step);

%% LSTM

% Define LSTM network
input_size = info_vehs.num_antenna * info_bs.num_antenna * 2; % real and imag parts
num_hidden_units = 200;
num_classes = numel(categories(train_y)); % info_vehs.num_antenna * info_bs.num_antenna;

layers = [ ...
    sequenceInputLayer(input_size)
    bilstmLayer(num_hidden_units, 'OutputMode', 'last')
    fullyConnectedLayer(num_classes)
    softmaxLayer
    classificationLayer];

max_epochs = 10;
mini_batchSize = 100;

options = trainingOptions('adam' , ...
    'ExecutionEnvironment', 'cpu', ...
    'GradientThreshold', 1, ...
    'MaxEpochs', max_epochs, ...
    'MiniBatchSize', mini_batchSize, ...
    'SequenceLength', 'longest', ...
    'Shuffle', 'never', ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

% Train network
net = trainNetwork(train_x, train_y, layers, options);

% Test network
pred_y = classify(net, test_x, ...
    'MiniBatchSize', mini_batchSize, ...
    'SequenceLength', 'longest');

% Calculate accurracy
acc = sum(pred_y == test_y) ./ numel(test_y)