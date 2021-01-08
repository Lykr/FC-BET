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

% hierarchical sweep
veh_beam_book_h = param.veh.beam_info.beam_book_h;
bs_beam_book_h = param.bs.beam_info.beam_book_h;
veh_beam_angles_h = param.veh.beam_info.beam_angles_h;
bs_beam_angles_h = param.bs.beam_info.beam_angles_h;

veh_level = length(veh_beam_angles_h);
bs_level = length(bs_beam_angles_h);
cur_veh_beam_level = 1;
cur_bs_beam_level = 1;
best_veh_beam = 1;
best_bs_beam = 1;
while cur_veh_beam_level <= veh_level + 1 && cur_bs_beam_level <= bs_level + 1
    % Get cur_beam_book and cur_beam_angles
    if cur_veh_beam_level == veh_level + 1
        cur_veh_beam_book = veh_beam_book_h{cur_veh_beam_level - 1}(:, best_veh_beam);
        cur_veh_beam_angles = veh_beam_angles_h{cur_veh_beam_level - 1}(best_veh_beam);
    else
        next_veh_beams = best_veh_beam * 2 - 1 : best_veh_beam * 2;
        cur_veh_beam_book = veh_beam_book_h{cur_veh_beam_level}(:, next_veh_beams);
        cur_veh_beam_angles = veh_beam_angles_h{cur_veh_beam_level}(next_veh_beams);
    end
    
    if cur_bs_beam_level == bs_level + 1
        cur_bs_beam_book = bs_beam_book_h{cur_bs_beam_level - 1}(:, best_bs_beam);
        cur_bs_beam_angles = bs_beam_angles_h{cur_bs_beam_level - 1}(best_bs_beam);
    else
        next_bs_beams = best_bs_beam * 2 - 1 : best_bs_beam * 2;
        cur_bs_beam_book = bs_beam_book_h{cur_bs_beam_level}(:, next_bs_beams);
        cur_bs_beam_angles = bs_beam_angles_h{cur_bs_beam_level}(next_bs_beams);
    end
    
    % Y = w' * Hf + w' * n;
    % Get noise
    cur_veh_beam_num = length(cur_veh_beam_angles);
    cur_bs_beam_num = length(cur_bs_beam_angles);
    
%     noise = (randn(cur_veh_beam_num, cur_bs_beam_num, n_r) + 1i * randn(cur_veh_beam_num, cur_bs_beam_num, n_r)) .* sqrt(var_n / 2); % noise part of received signal
    N = zeros(cur_veh_beam_num, cur_bs_beam_num);

    for i = 1 : cur_veh_beam_num
        for j = 1 : cur_bs_beam_num
%             N(i, j) = cur_veh_beam_book(:, i)' * reshape(noise(i, j, :), n_r, 1);
            N(i, j) = cur_veh_beam_book(:, i)' * noise;
        end
    end

    Hf =  channel * cur_bs_beam_book; % useful part of received signal
    S = cur_veh_beam_book' * Hf;
    Y = S + N; % received part signal

    % Get optimal angles and beams
    target = abs(Y);
    [~, li] = max(target(:));
    [i, j] = ind2sub(size(target), li); % index of minimum of target
    
    aoa_est = cur_veh_beam_angles(i);
    aod_est = cur_bs_beam_angles(j);
    CSI.angles_est_h = [aoa_est, aod_est];
    
    if cur_veh_beam_level <= veh_level
        best_veh_beam = best_veh_beam * 2 - 2 + i;
    end
    
    if cur_bs_beam_level <= bs_level
        best_bs_beam = best_bs_beam * 2 - 2 + j;
    end

    % SNR
    CSI.SNR_est_h = abs(S(i, j))^2 / abs(N(i, j))^2;
        
    % Update cur_beam_level
    if cur_veh_beam_level <= veh_level
        cur_veh_beam_level = cur_veh_beam_level + 1;
    end
    if cur_bs_beam_level <= bs_level
        cur_bs_beam_level = cur_bs_beam_level + 1;
    end
    
    % Check end condition
    if cur_veh_beam_level == veh_level + 1 && cur_bs_beam_level == bs_level + 1
        break;
    end
end

end