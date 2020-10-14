var_n_list_1 = [1e-14 1e-13 1e-12 1e-11 1e-10 1e-9 1e-8 1e-7];
list_num_1 = length(var_n_list_1);
SNR_est_mean_list_1 = zeros(1, list_num_1);
SNR_pred_mean_list_1 = zeros(1, list_num_1);
n_o_e_list_1 = zeros(1, list_num_1);
n_o_l_list_1 = zeros(1, list_num_1);
for i = 1 : list_num_1
    param.channel.var_n = var_n_list_1(i);
    
    get_data;
    run_simulation;
    
    SNR_est_mean_list_1(i) = SNR_est_mean;
    SNR_pred_mean_list_1(i) = SNR_pred_mean;
    n_o_e_list_1(i) = n_o_e;
    n_o_l_list_1(i) = n_o_l;
end
pc_r = [178 34 34]./255;
pc_b = [61 89 171]./255;
figure(1);
colororder([pc_b; pc_r]);
box on;
hold on;
x_in_dBW = 10 * log10(var_n_list_1);
yyaxis left;
xlim([-140.01, -69.99]);
ylim([-10.01, 80.01]);
plot(x_in_dBW, SNR_est_mean_list_1, '-o', 'LineWidth', 1);
plot(x_in_dBW, SNR_pred_mean_list_1, '-^', 'LineWidth', 1);
xlabel('Noise variance of received signal (dBW)', 'Fontname', 'Times New Roman');
ylabel('Average SNR of received signal (dB)', 'Fontname', 'Times New Roman');
yyaxis right;
ylim([-0.01, 1.01]);
plot(x_in_dBW, n_o_e_list_1./length(y_test), '--o', 'LineWidth', 1);
plot(x_in_dBW, n_o_l_list_1./length(y_test), '--^', 'LineWidth', 1);
ylabel('Probability of outages', 'Fontname', 'Times New Roman');
hold off;
legend_1 = legend('Exhaustive', 'FC-BET', 'Exhaustive', 'FC-BET');
set(legend_1, 'Fontname', 'Times New Roman');
set(gca, 'linewidth', 1);