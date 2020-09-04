bs_antenna_num_list = [4 16 16 32 32 32 64 64 64 64];
veh_antenna_num_list = [4 4 16 4 16 32 4 16 32 64];
list_num_3 = length(bs_antenna_num_list);
SNR_est_mean_list_3 = zeros(1, list_num_3);
SNR_pred_mean_list_3 = zeros(1, list_num_3);
n_o_e_list_3 = zeros(1, list_num_3);
n_o_l_list_3 = zeros(1, list_num_3);
x_3 = [1 : 10];
for i = 1 : list_num_3
    param.bs.num_antenna = bs_antenna_num_list(i);
    param.veh.num_antenna = veh_antenna_num_list(i);
    param.bs.beam_info = gen_beam_info(param.bs.num_antenna, 2 * param.bs.num_antenna); % get beam codebook for bs
    param.veh.beam_info = gen_beam_info(param.veh.num_antenna, 2 * param.veh.num_antenna); % get beam codebook for veh
    
    get_data;
    run_simulation;
    
    SNR_est_mean_list_3(i) = SNR_est_mean;
    SNR_pred_mean_list_3(i) = SNR_pred_mean;
    n_o_e_list_3(i) = n_o_e;
    n_o_l_list_3(i) = n_o_l;
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
plot(x_3, SNR_est_mean_list_3, '-o', 'LineWidth', 1);
plot(x_3, SNR_pred_mean_list_3, '-^', 'LineWidth', 1);
xlabel('Antenna Configuration (M_r*M_t)', 'Fontname', 'Times New Roman');
ylabel('Average SNR of received signal (dB)', 'Fontname', 'Times New Roman');
yyaxis right;
gca.YColor = pc_r;
ylim([-0.01, 1.01]);
plot(x_3, n_o_e_list_3./length(y_test), '--o', 'LineWidth', 1);
plot(x_3, n_o_l_list_3./length(y_test), '--^', 'LineWidth', 1);
ylabel('Probability of outages', 'Fontname', 'Times New Roman');
hold off;
xticklabels({'4*4','4*16','16*16','4*32','16*32','32*32','4*64','16*64','32*64','64*64'});
legend_1 = legend('Exhaustive search', 'LSTM-based', 'Exhaustive search', 'LSTM-based');
set(legend_1, 'Fontname', 'Times New Roman');