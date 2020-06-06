function [beam_pair, angles_est, h_est] = beam_sweep(channel, param)

veh_beam_book = param.veh.beam_info.beam_book;
veh_beam_angles = param.veh.beam_info.beam_angles;
SNR = param.veh.beam_info.SNR;

bs_beam_book = param.bs.beam_info.beam_book;
bs_beam_angles = param.bs.beam_info.beam_angles;

r_n = size(veh_beam_book, 1);
c_n = size(bs_beam_book, 2);
var_n = 1 / (10 ^ SNR / 10); % noise variance

y = veh_beam_book' * (channel * bs_beam_book + (randn(r_n, c_n) + 1i * randn(r_n, c_n)) * sqrt(var_n / 2)); % recevied signal
target = abs(y);
[i, j] = find(target == max(max(target))); % index of minimum of target
aoa_est = veh_beam_angles(i);
aod_est = bs_beam_angles(j);

beam_pair = [i, j];
angles_est = [aoa_est, aod_est];
h_est = y(i, j) * veh_beam_book(:, i) * bs_beam_book(:, j)';

end