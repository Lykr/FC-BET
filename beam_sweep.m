function [beam_pair, angles_est, h_est] = beam_sweep(channel, veh_beam_info, bs_beam_info)

veh_beam_book = veh_beam_info.beam_book;
veh_beam_angles = veh_beam_info.beam_angles;
bs_beam_book = bs_beam_info.beam_book;
bs_beam_angles = bs_beam_info.beam_angles;


y = veh_beam_book' * channel * bs_beam_book;
target = abs(y);
[i, j] = find(target == max(max(target)));
aoa_est = veh_beam_angles(i);
aod_est = bs_beam_angles(j);

beam_pair = [i, j];
angles_est = [aoa_est, aod_est];
h_est = y(i, j) * veh_beam_book(:, i) * bs_beam_book(:, j)';

end