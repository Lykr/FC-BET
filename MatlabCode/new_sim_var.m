var_n_list = [1e-14 1e-13 1e-12 1e-11 1e-10 1e-9 1e-8 1e-7];
list_num = length(var_n_list);
SNR_est_mean_list = zeros(1, list_num);
SNR_est_h_mean_list = zeros(1, list_num);
SNR_pred_e_mean_list = zeros(1, list_num);
SNR_pred_h_mean_list = zeros(1, list_num);
n_o_e_list = zeros(1, list_num);
n_o_h_list = zeros(1, list_num);
n_o_l_e_list = zeros(1, list_num);
n_o_l_h_list = zeros(1, list_num);

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

training_raw_data = gen_raw_data(param, load('sumo_output_for_training.mat').sumo_output);
[x_train, y_train, others_train] = gen_learning_data(param, training_raw_data);
[net, ~] = get_lstm_net(param, x_train, y_train);

times = 20;
for time = 1 : times
    disp(['Time. ', num2str(time)])
    for i = 1 : list_num
        disp(['No. ', num2str(i)]);
        param.channel.var_n = var_n_list(i);

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

%% Plot
n = length(others_test.h_list);
pc_r = [178 34 34]./255;
pc_b = [61 89 171]./255;
figure(1);
colororder([pc_b; pc_r]);
box on;
hold on;

x_in_dBW = 10 * log10(var_n_list);

yyaxis left;
xlim([-140.01, -69.99]);
ylim([-10.01, 80.01]);

% for legend
plot(1, 'ko', 'LineWidth', 1);
plot(1, 'kx', 'LineWidth', 1);
plot(1, 'k^', 'LineWidth', 1);
plot(1, 'k*', 'LineWidth', 1);

plot(x_in_dBW, SNR_est_mean_list, '-o', 'LineWidth', 1);
plot(x_in_dBW, SNR_est_h_mean_list, '-x', 'LineWidth', 1);
plot(x_in_dBW, SNR_pred_e_mean_list, '-^', 'LineWidth', 1);
plot(x_in_dBW, SNR_pred_h_mean_list, '-*', 'LineWidth', 1);
xlabel('Noise variance of received signal (dBW)', 'Fontname', 'Times New Roman');
ylabel('Average SNR of received signal (dB)', 'Fontname', 'Times New Roman');

yyaxis right;
ylim([-0.01, 1.01]);
plot(x_in_dBW, n_o_e_list./n, '--o', 'LineWidth', 1);
plot(x_in_dBW, n_o_h_list./n, '--x', 'LineWidth', 1);
plot(x_in_dBW, n_o_l_e_list./n, '--^', 'LineWidth', 1);
plot(x_in_dBW, n_o_l_h_list./n, '--*', 'LineWidth', 1);
ylabel('Probability of outages', 'Fontname', 'Times New Roman');
hold off;
legend_ = legend('Exhaustive', 'Hierarchical', 'FC-BET-E', 'FC-BET-H');
set(legend_, 'Fontname', 'Times New Roman');
set(gca, 'linewidth', 1);
% set(gca,'YScale','log')