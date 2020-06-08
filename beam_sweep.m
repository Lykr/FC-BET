function [CSI] = beam_sweep(channel, param)

veh_beam_book = param.veh.beam_info.beam_book;
veh_beam_angles = param.veh.beam_info.beam_angles;
SNR = param.veh.beam_info.SNR;

bs_beam_book = param.bs.beam_info.beam_book;
bs_beam_angles = param.bs.beam_info.beam_angles;

% Y = w' * Hf + w' * n;
n_r = param.veh.num_antenna;
var_n = 1 / (10 ^ ((100 + SNR) / 10)); % noise variance
noise = (randn(n_r, 1) + 1i * randn(n_r, 1)) .* sqrt(var_n / 2); % noise part of received signal
CSI.noise = noise;

Hf =  channel * bs_beam_book; % useful part of received signal
Y = veh_beam_book' * (Hf + noise); % received part signal

% Get optimal angles and beams
target = abs(Y);
[~, li] = max(target(:));
[i, j] = ind2sub(size(target), li); % index of minimum of target
aoa_est = veh_beam_angles(i);
aod_est = bs_beam_angles(j);

CSI.beam_pair = [i, j];
CSI.angles_est = [aoa_est, aod_est];
CSI.h_siso_est = Y(i, j);

% SNR
S = veh_beam_book' * Hf;
N = veh_beam_book' * noise;
CSI.SNR_act = abs(S(i, j))^2 / abs(N(i))^2;

end