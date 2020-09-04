lstm_step_list = [1 3 5 7 9 11 13 15];
list_num_4 = length(lstm_step_list);
SNR_est_mean_list_4 = zeros(1, list_num_4);
SNR_pred_mean_list_4 = zeros(1, list_num_4);
n_o_e_list_4 = zeros(1, list_num_4);
n_o_l_list_4 = zeros(1, list_num_4);
for i = 1 : list_num_4
    lstm_step = lstm_step_list(i);
    
    get_data;
    run_simulation;
    
    SNR_est_mean_list_4(i) = SNR_est_mean;
    SNR_pred_mean_list_4(i) = SNR_pred_mean;
    n_o_e_list_4(i) = n_o_e;
    n_o_l_list_4(i) = n_o_l;
end
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
set(legend_1, 'Fontname', 'Times New Roman');