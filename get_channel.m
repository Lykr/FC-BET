function [angles, h] = get_channel(bs, veh, info_vehs)
% Generate channel matrix from parameters
% angle: right,anti-clockwise; array: right, up

vector_bs_to_veh = [veh.x, veh.y] - [bs.x, bs.y];
vector_veh_to_bs = -vector_bs_to_veh;
aod = vector_to_angle(vector_bs_to_veh);
aoa = vector_to_angle(vector_veh_to_bs);
angle_veh_turn = veh.angle - pi / 2;
aoa = aoa - angle_veh_turn;

% generate array response vector
e_t = get_eMatrix(bs.num_antenna, aod);
e_r = get_eMatrix(info_vehs.num_antenna, aoa);

% generate small scale fading gain
carrier_length = physconst('LightSpeed') / bs.frequency_carrier;
relative_angle = aoa - pi / 2;
doppler_part = exp(1i * 2 * pi * veh.speed / carrier_length * cos(relative_angle));
distance = norm(vector_bs_to_veh);
path_loss = 61.4 + 10 * 2 * log10(distance) + randn * 5.8;
small_scale_fading_gain = sqrt(10 ^ (-0.1 * path_loss) / 2) * (randn + 1i * randn) * doppler_part;

% channel struct
h = small_scale_fading_gain * e_r .* e_t';

if aoa > pi
    aoa = 2 * pi - aoa;
end

if aod > pi
    aod = 2 * pi - aod;
end

angles = [aoa, aod];

end