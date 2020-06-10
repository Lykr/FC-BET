function [angles, h] = get_channel(param, veh_data)
% Generate channel matrix from parameters
% angle: right,anti-clockwise; array: right, up

% Get AOA and AOD from raw data
vector_bs_to_veh = [veh_data.x, veh_data.y] - [param.bs.x, param.bs.y];
vector_veh_to_bs = -vector_bs_to_veh;
aod = vector_to_angle(vector_bs_to_veh);
aoa = vector_to_angle(vector_veh_to_bs);
angle_veh_turn = pi / 2 - veh_data.angle;
aoa = aoa - angle_veh_turn;

% Get channel parameters
L = param.channel.L; % number of subpath
spread_e_r = param.channel.spread_e_r;
spread_e_t = param.channel.spread_e_t;
K = 1; % max(poissrnd(param.channel.lambda), 1);
r_tau = param.channel.r_tau;
zeta = param.channel.zeta;

% generate cluster parameters
gamma = rand(1, K) .^ (r_tau - 1) .* randn(1, K) * zeta;
gamma = gamma / sum(gamma);
gamma = kron(gamma, ones(1, L));

% generate subpath parameters
spread_r = exprnd(spread_e_r);
spread_t = exprnd(spread_e_t);
aoas = angle(exp(1i * (aoa + (-1 + 2 * rand(K * L, 1)) * spread_r / 2)));
aods = angle(exp(1i * (aod + (-1 + 2 * rand(K * L, 1)) * spread_t / 2)));

% generate array response vector
e_r = get_e(param.veh.num_antenna, aoas);
e_t = get_e(param.bs.num_antenna, aods);

% generate small scale fading gain
c = physconst('LightSpeed');
carrier_length = c / param.bs.frequency_carrier;
relative_angle = aoas' - pi / 2;
time_transmission = norm(vector_bs_to_veh) / c;
doppler_part = exp(1i * 2 * pi * time_transmission * veh_data.speed / carrier_length * cos(relative_angle));
distance = norm(vector_bs_to_veh);
path_loss = 61.4 + 10 * 2 * log10(distance) + randn * 5.8;
small_scale_fading_gain = sqrt(gamma * 10 ^ (-0.1 * path_loss) / 2) .* (randn(1, K * L) + 1i * randn(1, K * L)) .* doppler_part;

% channel struct
h = 1 / sqrt(L) * small_scale_fading_gain .* e_r * e_t';

if aoa > pi
    aoa = 2 * pi - aoa;
end

if aod > pi
    aod = 2 * pi - aod;
end

angles = [aoa, aod];

end

function angle = vector_to_angle(vec)
    angle = atan2(vec(2), vec(1));
    
    if angle < 0
        angle = 2 * pi + angle;
    end
end

function e = get_e(num_atenna, angles)
    r = num_atenna;
    c = length(angles);
    e = zeros(r, c);
    
    for i = 1 : c
        e(:, i) = get_eMatrix(num_atenna, angles(i));
    end
end