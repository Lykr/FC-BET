function [CSI] = beam_sweep(channel, param)

veh_beam_book = param.veh.beam_info.beam_book;
veh_beam_angles = param.veh.beam_info.beam_angles;

bs_beam_book = param.bs.beam_info.beam_book;
bs_beam_angles = param.bs.beam_info.beam_angles;

veh_beam_num = length(veh_beam_angles);
bs_beam_num = length(bs_beam_angles);

% Y = w' * Hf + w' * n;
n_r = param.veh.num_antenna;
var_n = param.channel.var_n; % noise variance
% noise = (randn(veh_beam_num, bs_beam_num, n_r) + 1i * randn(veh_beam_num, bs_beam_num, n_r)) .* sqrt(var_n / 2); % noise part of received signal
noise = (randn(n_r, 1) + 1i * randn(n_r, 1)) .* sqrt(var_n / 2);
N = zeros(veh_beam_num, bs_beam_num);

for i = 1 : veh_beam_num
    for j = 1 : bs_beam_num
        %         N(i, j) = veh_beam_book(:, i)' * reshape(noise(i, j, :), n_r, 1);
        N(i, j) = veh_beam_book(:, i)' * noise;
    end
end
CSI.noise = N;

Hf =  channel * bs_beam_book; % useful part of received signal
S = veh_beam_book' * Hf;
Y = S + N; % received part signal

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
CSI.SNR_est = abs(S(i, j))^2 / abs(N(i, j))^2;

end