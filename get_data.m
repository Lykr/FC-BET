%% Raw data generation
training_raw_data = gen_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
testing_raw_data = gen_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);

%% Learning data generation
[x_train, y_train, others_train] = gen_learning_data(training_raw_data, lstm_step);
[x_test, y_test, others_test] = gen_learning_data(testing_raw_data, lstm_step);