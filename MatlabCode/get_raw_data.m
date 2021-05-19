%% Raw data generation
training_raw_data = gen_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
testing_raw_data = gen_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);