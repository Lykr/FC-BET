bs_antenna_num_list = [4 8 8 16 16 32 32 64 64];
veh_antenna_num_list = [2 2 4 4 8 8 16 16 32];
list_num = length(bs_antenna_num_list);
SNR_est_mean_list = zeros(1, list_num);
SNR_est_h_mean_list = zeros(1, list_num);
SNR_pred_e_mean_list = zeros(1, list_num);
SNR_pred_h_mean_list = zeros(1, list_num);
n_o_e_list = zeros(1, list_num);
n_o_h_list = zeros(1, list_num);
n_o_l_e_list = zeros(1, list_num);
n_o_l_h_list = zeros(1, list_num);
n_m_l_e_list = zeros(1, list_num);
n_m_l_h_list = zeros(1, list_num);
x = [1 : 9];
times = 10;
for i = 1 : list_num
    param.bs.num_antenna = bs_antenna_num_list(i);
    param.veh.num_antenna = veh_antenna_num_list(i);
    param.bs.beam_info = gen_beam_info(param.bs.num_antenna, param.bs.num_antenna); % get beam codebook for bs
    param.veh.beam_info = gen_beam_info(param.veh.num_antenna, param.veh.num_antenna); % get beam codebook for veh
    
    training_raw_data = gen_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
    [x_train, y_train, others_train] = gen_learning_data(param, training_raw_data);
    [net, ~] = get_lstm_net(param, x_train, y_train);
    
    for time = 1 : times
        disp(['Time.', num2str(time), ', No.', num2str(i)]);
        
        testing_raw_data = gen_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);
        [~, ~, others_test] = gen_learning_data(param, testing_raw_data);
        [exhaustive, hierarchical] = evaluate_pred(param, others_test, net);
        
        SNR_est_mean = 10 * log10(mean(others_test.SNR_est_list));
        SNR_est_h_mean = 10 * log10(mean(others_test.SNR_est_h_list));
        SNR_pred_e_mean = 10 * log10(mean(exhaustive.SNR));
        SNR_pred_h_mean = 10 * log10(mean(hierarchical.SNR));
        
        SNR_est_mean_list(i) = SNR_est_mean_list(i) + SNR_est_mean;
        SNR_est_h_mean_list(i) = SNR_est_h_mean_list(i) + SNR_est_h_mean;
        SNR_pred_e_mean_list(i) = SNR_pred_e_mean_list(i) + SNR_pred_e_mean;
        SNR_pred_h_mean_list(i) = SNR_pred_h_mean_list(i) + SNR_pred_h_mean;
        
        n_o_e_list(i) = n_o_e_list(i) + others_test.outage;
        n_o_h_list(i) = n_o_h_list(i) + others_test.outage_h;
        n_o_l_e_list(i) = n_o_l_e_list(i) + exhaustive.n_o;
        n_o_l_h_list(i) = n_o_l_h_list(i) + hierarchical.n_o;
        
        n_m_l_e_list(i) = n_m_l_e_list(i) + exhaustive.n_m;
        n_m_l_h_list(i) = n_m_l_h_list(i) + hierarchical.n_m;
    end
end

SNR_est_mean_list = SNR_est_mean_list./times;
SNR_est_h_mean_list = SNR_est_h_mean_list./times;
SNR_pred_e_mean_list = SNR_pred_e_mean_list./times;
SNR_pred_h_mean_list = SNR_pred_h_mean_list./times;
n_o_e_list = n_o_e_list./times;
n_o_h_list = n_o_h_list./times;
n_o_l_e_list = n_o_l_e_list./times;
n_o_l_h_list = n_o_l_h_list./times;
n_m_l_e_list = n_m_l_e_list./times;
n_m_l_h_list = n_m_l_h_list./times;

%% Plot
n = length(others_test.h_list);
pc_r = [178 34 34]./255;
pc_b = [61 89 171]./255;
lineWidth = 1.5;
figure(3);
colororder([pc_b; pc_r]);
box on;
hold on;
yyaxis left;
ylim([0, 80]);
xlim([0.99 9.01]);
plot(-1, 'ko', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(-1, 'kx', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(-1, 'k^', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(-1, 'k*', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x, SNR_est_mean_list, '-o', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x, SNR_est_h_mean_list, '-x', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x, SNR_pred_e_mean_list, '-^', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x, SNR_pred_h_mean_list, '-*', 'LineWidth', lineWidth, 'MarkerSize', 8);
xlabel('Antenna Size M_r\timesM_t', 'Fontname', 'Times New Roman');
ylabel('Average SNR of received signal (dB)', 'Fontname', 'Times New Roman');

yyaxis right;
ylim([0.001, 1]);
plot(x, n_o_e_list./n, '--o', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x, n_o_h_list./n, '--x', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x, n_o_l_e_list./n, '--^', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x, n_o_l_h_list./n, '--*', 'LineWidth', lineWidth, 'MarkerSize', 8);
ylabel('Outage Probability', 'Fontname', 'Times New Roman');
hold off;
xticklabels({'2\times4','2\times8','4\times8','4\times16','8\times16','8\times32','16\times32','16\times64','32\times64'});
legend_ = legend('Exhaustive', 'Hierarchical', 'FC-BET-E', 'FC-BET-H');
set(legend_, 'Fontname', 'Times New Roman');
set(gca, 'LineWidth', lineWidth);
set(gca,'YScale','log')
set(gca,'looseInset',[0 0 0 0]) % clear outerspace in figure