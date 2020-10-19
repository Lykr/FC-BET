clear;

%% Parameters
param.interval = 2;
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
param.channel.var_n = 1e-12;

param.SNR_threshold = 5; % in dB

lstm_step = 5;

%% Run simulation
simulation_switch = 4; %-1-normal 0-all, 1-var_n, 2-measurements, 3-anttenna, 4-steps

% Normal
if simulation_switch == 0 || simulation_switch == -1
    get_data;
    run_simulation; 
end

% Different noise variances of received signal
if simulation_switch == 0 || simulation_switch == 1
    sim_var_n;
end

% Number of measurement
if simulation_switch == 0 || simulation_switch == 2
    get_data;
    run_simulation;
    n_m_2 = n_m;
end

% Antenna
if simulation_switch == 0 || simulation_switch == 3
    sim_antenna;
end

% Steps
if simulation_switch == 0 || simulation_switch == 4
    sim_steps;
end
%% Check results of networks
if simulation_switch == -1
    check_results;
end