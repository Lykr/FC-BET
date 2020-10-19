bs_antenna_num_list = [4 8 8 16 16 32 32 64 64];
veh_antenna_num_list = [2 2 4 4 8 8 16 16 32];
list_num_3 = length(bs_antenna_num_list);
SNR_est_mean_list_3 = zeros(1, list_num_3);
SNR_pred_mean_list_3 = zeros(1, list_num_3);
n_o_e_list_3 = zeros(1, list_num_3);
n_o_l_list_3 = zeros(1, list_num_3);
x_3 = [1 : 9];
for i = 1 : list_num_3
    param.bs.num_antenna = bs_antenna_num_list(i);
    param.veh.num_antenna = veh_antenna_num_list(i);
    param.bs.beam_info = gen_beam_info(param.bs.num_antenna, 2 * param.bs.num_antenna); % get beam codebook for bs
    param.veh.beam_info = gen_beam_info(param.veh.num_antenna, 2 * param.veh.num_antenna); % get beam codebook for veh
    
    get_raw_data;
    get_learning_data;
    run_simulation;
    
    SNR_est_mean_list_3(i) = SNR_est_mean;
    SNR_pred_mean_list_3(i) = SNR_pred_mean;
    n_o_e_list_3(i) = n_o_e;
    n_o_l_list_3(i) = n_o_l;
end
pc_r = [178 34 34]./255;
pc_b = [61 89 171]./255;
figure(3);
colororder([pc_b; pc_r]);
box on;
hold on;
yyaxis left;
ylim([0, 80]);
xlim([0.99 9.01]);
plot(x_3, SNR_est_mean_list_3, '-o', 'LineWidth', 1);
plot(x_3, SNR_pred_mean_list_3, '-^', 'LineWidth', 1);
xlabel('Antenna Size M_r\timesM_t', 'Fontname', 'Times New Roman');
ylabel('Average SNR of received signal (dB)', 'Fontname', 'Times New Roman');
yyaxis right;
ylim([-0.01, 1.01]);
plot(x_3, n_o_e_list_3./length(y_test), '--o', 'LineWidth', 1);
plot(x_3, n_o_l_list_3./length(y_test), '--^', 'LineWidth', 1);
ylabel('Probability of outages', 'Fontname', 'Times New Roman');
hold off;
xticklabels({'2\times4','2\times8','4\times8','4\times16','8\times16','8\times32','16\times32','16\times64','32\times64'});
legend_1 = legend('Exhaustive', 'FC-BET', 'Exhaustive', 'FC-BET');
set(legend_1, 'Fontname', 'Times New Roman');
set(gca, 'linewidth', 1);