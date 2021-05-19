%% Learning data generation
[x_train, y_train, others_train] = gen_learning_data(param, training_raw_data);
[x_test, y_test, others_test] = gen_learning_data(param, testing_raw_data);