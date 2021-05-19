var_n_list = [1e-14 1e-13 1e-12 1e-11 1e-10 1e-9 1e-8 1e-7];
list_num = length(var_n_list);

% for i = 1 : list_num
%     disp(['No. ', num2str(i)]);
%     param.channel.var_n = var_n_list(i);
% 
%     get_raw_data;
%     get_learning_data;
%     run_simulation;
% 
%     SNR_est_mean_list(i) = SNR_est_mean;
%     SNR_est_h_mean_list(i) = SNR_est_h_mean;
%     SNR_pred_e_mean_list(i) = SNR_pred_e_mean;
%     SNR_pred_h_mean_list(i) = SNR_pred_h_mean;
%     
%     n_o_e_list(i) = others_test.outage;
%     n_o_h_list(i) = others_test.outage_h;
%     n_o_l_e_list(i) = exhaustive.n_o;
%     n_o_l_h_list(i) = hierarchical.n_o;
% end

param.channel.var_n = 1e-12;
training_raw_data = gen_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
[x_train, y_train, others_train] = gen_learning_data(param, training_raw_data);
[net, ~] = get_lstm_net(param, x_train, y_train);

%% Simulate
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

mu = 3;
times = 100;
for time = 1 : times
    for i = 1 : list_num
        disp(['Time.', num2str(time), ', No.', num2str(i)]);
        param.channel.var_n = var_n_list(i);
% 
%         training_raw_data = gen_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
%         [x_train, y_train, others_train] = gen_learning_data(param, training_raw_data);
%         [net, ~] = get_lstm_net(param, x_train, y_train);
        testing_raw_data = gen_raw_data(param, load('sumo_output_for_testing.mat').sumo_output);
        [~, ~, others_test] = gen_learning_data(param, testing_raw_data);
        [exhaustive, hierarchical] = evaluate_pred(param, others_test, net);
        
        SNR_est_mean = mean(10 * log10(others_test.SNR_est_list));
        SNR_est_h_mean = mean(10 * log10(others_test.SNR_est_h_list));
        SNR_pred_e_mean = mean(10 * log10(exhaustive.SNR));
        SNR_pred_h_mean = mean(10 * log10(hierarchical.SNR));
        
%         SNR_est_mean = mean(log2(1 + others_test.SNR_est_list));
%         SNR_est_h_mean = mean(log2(1 + others_test.SNR_est_h_list));
%         SNR_pred_e_mean = mean(log2(1 + exhaustive.SNR));
%         SNR_pred_h_mean = mean(log2(1 + hierarchical.SNR));
        
%         n = length(others_test.h_list);
%         antenna_mul = param.veh.num_antenna * param.bs.num_antenna;
%         interval = param.interval * 10;
%         SNR_est_mean = (1 - (antenna_mul * 4 / (14 * 2^mu)) / interval) * mean(log2(1 + others_test.SNR_est_list));
%         SNR_est_h_mean = (1 - (2 * log2(antenna_mul) *4/ (14 * 2^mu)) / interval) * mean(log2(1 + others_test.SNR_est_h_list));
%         SNR_pred_e_mean = (1 - ((n - n_m_l_e_list(i) + n_m_l_e_list(i) * antenna_mul)/n *4/ (14 * 2^mu)) / interval) * mean(log2(1 + exhaustive.SNR));
%         SNR_pred_h_mean = (1 - ((n - n_m_l_h_list(i) + n_m_l_h_list(i) * 2 * log2(antenna_mul))/n *4/ (14 * 2^mu)) / interval) * mean(log2(1 + hierarchical.SNR));
        
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
% SNR_est_mean_list = 10 * log10(SNR_est_mean_list./times);
% SNR_est_h_mean_list = 10 * log10(SNR_est_h_mean_list./times);
% SNR_pred_e_mean_list = 10 * log10(SNR_pred_e_mean_list./times);
% SNR_pred_h_mean_list = 10 * log10(SNR_pred_h_mean_list./times);
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
lineWidth = 1.5;
pc_r = [178 34 34]./255;
pc_b = [61 89 171]./255;
n = length(others_test.h_list);

figure(1);
colororder([pc_b; pc_r]);
box on;
hold on;

x_in_dBW = 10 * log10(var_n_list);
xlim([-140.01, -69.99]);

yyaxis left;

% for legend
plot(1, 'ko', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(1, 'kx', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(1, 'k^', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(1, 'k*', 'LineWidth', lineWidth, 'MarkerSize', 8);
% ylim([-12.5, 61]);
% ylim([-0.01, 20.5]);
ylim([-45, 65]);
plot(x_in_dBW, SNR_est_mean_list, '-o', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x_in_dBW, SNR_est_h_mean_list, '-x', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x_in_dBW, SNR_pred_e_mean_list, '-^', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x_in_dBW, SNR_pred_h_mean_list, '-*', 'LineWidth', lineWidth, 'MarkerSize', 8);
xlabel('Noise variance of received signal (dBW)', 'Fontname', 'Times New Roman');
ylabel('Average signal-to-noise ratio (dB)', 'Fontname', 'Times New Roman');
% ylabel('Average Spectral Efficiency (bps/Hz)', 'Fontname', 'Times New Roman');

yyaxis right;
ylim([0.001, 1.01]);
plot(x_in_dBW, n_o_e_list./n, '--o', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x_in_dBW, n_o_h_list./n, '--x', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x_in_dBW, n_o_l_e_list./n, '--^', 'LineWidth', lineWidth, 'MarkerSize', 8);
plot(x_in_dBW, n_o_l_h_list./n, '--*', 'LineWidth', lineWidth, 'MarkerSize', 8);
ylabel('Outage Probability', 'Fontname', 'Times New Roman');
hold off;
legend_ = legend('Exhaustive', 'Hierarchical', 'FC-BET-E', 'FC-BET-H');
set(legend_, 'Fontname', 'Times New Roman');
set(gca, 'LineWidth', lineWidth);
set(gca,'YScale','log')
set(gca,'looseInset',[0 0 0 0]) % clear outerspace in figure