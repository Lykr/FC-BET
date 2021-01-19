%% Get LSTM network
[net, info] = get_lstm_net(param, x_train, y_train);

%% LSTM network testing
[exhaustive, hierarchical] = evaluate_pred(param, others_test, net);

<<<<<<< HEAD
% %% Calculate SNR
% t_p = length(exhaustive.SNR);
% SNR_est_mean = 10 * log10(mean(others_test.SNR_est_list));
% SNR_est_h_mean = 10 * log10(mean(others_test.SNR_est_h_list));
% SNR_pred_e_mean = 10 * log10(mean(exhaustive.SNR));
% SNR_pred_h_mean = 10 * log10(mean(hierarchical.SNR));
% 
% SE_est_mean = mean(log2(1 + others_test.SNR_est_list));
% SE_est_h_mean = mean(log2(1 + others_test.SNR_est_h_list));
% SE_pred_e_mean = mean(log2(1 + exhaustive.SNR));
% SE_pred_h_mean = mean(log2(1 + hierarchical.SNR));
=======
%% Calculate SNR
t_p = length(exhaustive.SNR);
SNR_est_mean = 10 * log10(mean(others_test.SNR_est_list));
SNR_est_h_mean = 10 * log10(mean(others_test.SNR_est_h_list));
SNR_pred_e_mean = 10 * log10(mean(exhaustive.SNR));
SNR_pred_h_mean = 10 * log10(mean(hierarchical.SNR));

SE_est_mean = mean(log2(1 + others_test.SNR_est_list));
SE_est_h_mean = mean(log2(1 + others_test.SNR_est_h_list));
SE_pred_e_mean = mean(log2(1 + exhaustive.SNR));
SE_pred_h_mean = mean(log2(1 + hierarchical.SNR));
>>>>>>> 4bb9d94ba24fc2a5bafaedfd04da00d867d5777a
