lstm_step_list = [1 3 5 10];
list_num_4 = length(lstm_step_list);
SNR_pred_mean_list_4 = zeros(1, list_num_4);
n_o_l_h_list_4 = zeros(1, list_num_4);
n_m_l_h_4 = zeros(1, list_num_4);

training_raw_data = gen_raw_data(param, load('sumo_output_for_training.mat').sumo_output);

times = 10;
for time = 1 : times
    for i = 1 : list_num_4
        lstm_step = lstm_step_list(i);
        
        [x_train, y_train, others_train] = gen_learning_data(param, training_raw_data);
        [net, ~] = get_lstm_net(param, x_train, y_train);
        testing_raw_data = gen_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);
        [~, ~, others_test] = gen_learning_data(param, testing_raw_data);
        [exhaustive, hierarchical] = evaluate_pred(param, others_test, net);

        SNR_pred_mean_list_4(i) = 10 * log10(mean(hierarchical.SNR));
        n_o_l_h_list_4(i) = n_o_l_h_list_4(i) + hierarchical.n_o;
        n_m_l_h_4(i) = n_m_l_h_4(i) + hierarchical.n_m;
    end
end

SNR_pred_mean_list_4 = SNR_pred_mean_list_4 ./ times;
n_o_l_h_list_4 = n_o_l_h_list_4 ./ times;
n_m_l_h_4 = n_m_l_h_4 ./ times;
%%
% É«¿¨£º#FF0033 #006699 #FFFF33
pc_r = [255 0 51]./255;
pc_b = [0 102 255]./255;
figure(3);
box on;
hold on;
yyaxis left;
gca.YColor = pc_b;
ylim([0, 80]);
plot(lstm_step_list, SNR_pred_mean_list_4, '-^', 'LineWidth', 1);
xlabel('LSTM Step', 'Fontname', 'Times New Roman');
ylabel('Average SNR of received signal (dB)', 'Fontname', 'Times New Roman');
yyaxis right;
gca.YColor = pc_r;
ylim([-0.01, 1.01]);
plot(lstm_step_list, n_o_l_list_4./length(y_test), '--^', 'LineWidth', 1);
ylabel('Probability of outages', 'Fontname', 'Times New Roman');
hold off;