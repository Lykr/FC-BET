function channel = get_channel(bs, veh)
% Generate channel matrix from parameters

vector_bs_to_veh = [veh.x, veh.y] - [bs.x, bs.y];
vector_veh_to_bs = -vector_bs_to_veh;
aod = vector_to_angle(vector_bs_to_veh);
aoa = vector_to_angle(vector_veh_to_bs);
angle_veh_turn = veh.angle - pi / 2;
aoa = aoa - angle_veh_turn;

% generate array response vector
e_t = get_eMatrix(bs.num_antenna, aod);
e_r = get_eMatrix(16, aoa); % 16 is veh.num_antenna

% generate small scale fading gain
carrier_length = physconst('LightSpeed') / bs.frequency_carrier;
relative_angle = aoa - pi / 2;
doppler_part = exp(1i * 2 * pi * veh.speed / carrier_length * cos(relative_angle));
distance = norm(vector_bs_to_veh);
path_loss = 61.4 + 10 * 2 * log10(distance) + randn * 5.8;
small_scale_fading_gain = sqrt(10 ^ (-0.1 * path_loss) / 2) * (randn + 1i * randn) * doppler_part;

% channel struct
channel.h = small_scale_fading_gain * e_r .* e_t';
channel.aoa = aoa;
channel.aod = aod;

end