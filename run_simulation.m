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
    dropoutLayer(0.2)
    fullyConnectedLayer(num_responses)
    regressionLayer]; % custom_regression / regressionLayer

max_epochs = 400;
mini_batch_size = numel(x_train);

options = trainingOptions('adam' , ...
    'ExecutionEnvironment', 'gpu', ...
    'GradientThreshold', 1, ...
    'LearnRateSchedule','none', ...
    'LearnRateDropPeriod',50, ...
    'LearnRateDropFactor',0.9, ...
    'InitialLearnRate', 0.05, ...
    'MaxEpochs', max_epochs, ...
    'MiniBatchSize', mini_batch_size, ...
    'SequenceLength', 'longest', ...
    'Shuffle', 'once', ...
    'Verbose', 1, ...
    'Plots', 'none');

% Train network
net = trainNetwork(x_train, y_train, layers, options);

%% LSTM network testing
% pred_y = predict(net, test_x);

[y_pred, SNR_pred_n, n_o, n_m] = evaluate_pred(param, others_test, net, x_test, y_test);

% [y_kf, SNR_kf, n_o_kf, n_m_kf] = evaluate_kf(param, others_test, x_test, y_test, SNR_threshold);

%% Check results of networks
check_results;