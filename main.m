clear;

%% Parameters of simulation
t_sim = 3600; % simulation time in s
t_step = 0.01; % simulation step seconds/step
show_pic = 1; % show scene of beamforming
info_bs.x = 80; % position of base station
info_bs.y = 80;
info_bs.num_antenna = 64; % number of base station antenna
info_bs.frequency_carrier = 28e9; % frequency of carrier

%% Initialization
load('sumo_output.mat');

%% 