clear;

%% Parameters
param.interval = 5;
param.bs.x = 80; % position of base station
param.bs.y = 80;
param.bs.frequency_carrier = 28e9; % frequency of carrier
param.bs.num_antenna = 16; % number of base station antenna, default to 16
param.bs.beam_info = gen_beam_info(param.bs.num_antenna, 2 * param.bs.num_antenna); % get beam codebook for bs

param.veh.num_antenna = 4; % number of veh's antenna, default to 4
param.veh.beam_info = gen_beam_info(param.veh.num_antenna, 2 * param.veh.num_antenna); % get beam codebook for veh

param.channel.L = 20;
param.channel.lambda = 1.8;
param.channel.r_tau = 2.8;
param.channel.zeta = 4.0;
param.channel.spread_e_t = 10.2 / 180 * pi; % 10.2 degree
param.channel.spread_e_r = 15.5 / 180 * pi; % 15.5 degree
param.channel.var_n = 1e-14;

param.SNR_threshold = 5; % in dB

lstm_step = 5;

%% Run simulation
simulation_switch = 0; % 0 for all, 1 for different var_n, 2 for

% Different noise variances of received signal
if simulation_switch == 0 || simulation_switch == 1
    var_n_list = [1e-16 1e-15 1e-14 1e-13 1e-12 1e-11 1e-10 1e-9];
    list_num = length(var_n_list);
    SNR_est_mean_list = zeros(1, list_num);
    SNR_pred_mean_list = zeros(1, list_num);
    n_m_list = zeros(1, list_num);
    n_o_list = zeros(1, list_num);
    for i = 1 : list_num
        param.channel.var_n = var_n_list(i);
        
        get_data;
        run_simulation;
        
        SNR_est_mean_list(i) = SNR_est_mean;
        SNR_pred_mean_list(i) = SNR_pred_mean;
        n_m_list(i) = n_m;
        n_o_list(i) = n_o;
    end
    figure(1);
    box on;
    hold on;
    x_in_dB = 10 * log10(var_n_list);
    yyaxis left;
    ylim([-20, 80]);
    plot(x_in_dB, SNR_est_mean_list, '-o', 'LineWidth', 1);
    plot(x_in_dB, SNR_pred_mean_list, '-^', 'LineWidth', 1);
    xlabel('Noise variance of received signal (dBW)', 'Fontname', 'Times New Roman');
    ylabel('Average SNR of received signal (dB)', 'Fontname', 'Times New Roman');
    yyaxis right;
    ylim([0, 800]);
    plot(x_in_dB, n_m_list, '-o', 'LineWidth', 1);
    plot(x_in_dB, n_o_list, '-^', 'LineWidth', 1);
    ylabel('Number of outages and beam measurements', 'Fontname', 'Times New Roman');
    hold off;
    legend_1 = legend('SNR w exhaustive search', 'SNR w LSTM-based', 'Number of measurements', 'Number of outages');
    set(legend_1, 'Fontname', 'Times New Roman');
    set(gca, 'Fontname', 'Times New Roman', 'LineWidth', 1);
end

%% Check results of networks
% check_results;