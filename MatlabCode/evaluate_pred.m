function [exhaustive, hierarchical] = evaluate_pred(param, others_test, net)

veh_beam_book = param.veh.beam_info.beam_book;
veh_beam_angles = param.veh.beam_info.beam_angles;
bs_beam_book = param.bs.beam_info.beam_book;
bs_beam_angles = param.bs.beam_info.beam_angles;
h_list = others_test.h_list;
noise_list = others_test.noise_list;
noise_list_h = others_test.noise_list_h;
angles_est_list = others_test.angles_est_list;
angles_est_h_list = others_test.angles_est_h_list;
SNR_est_list = others_test.SNR_est_list;

n = length(h_list);
lstm_step = param.lstm_step;

SNR_e = zeros(n, 1);
p_s_e = zeros(n, 1);
p_n_e = zeros(n, 1);
y_e = zeros(n, 2);
n_o_l_e = 0;
n_m_l_e = 0;
cur_feature = zeros(2, lstm_step);
cur_feature_size = 0;

consecutive_pred = 0;

% Predict by exhaustive
for i = 1 : n
%     prediction
    if cur_feature_size < lstm_step
        y_e(i, :) = angles_est_list(i, :);
        cur_feature_size = cur_feature_size + 1;
        n_m_l_e = n_m_l_e + 1;
    else
        y_e(i, :) = predict(net, num2cell(cur_feature, [1, 2]));
    end
    
%     % prediction
%     if cur_feature_size < lstm_step
%         y_e(i, :) = angles_est_list(i, :);
%         cur_feature_size = cur_feature_size + 1;
%         n_m_l_e = n_m_l_e + 1;
%     else
%         if consecutive_pred >= lstm_step
%             y_e(i, :) = angles_est_list(i, :);
%             n_m_l_e = n_m_l_e + 1;
%             consecutive_pred = 0;
%         else
%             y_e(i, :) = predict(net, num2cell(cur_feature, [1, 2]));
%             consecutive_pred = consecutive_pred + 1;
%         end
%     end
diff_angles_veh = veh_beam_angles - y_e(i, 1);
diff_angles_bs = bs_beam_angles - y_e(i, 2);
y_max = -inf;
prefer_veh_beam = 1;
prefer_bs_beam = 1;
for s = 1 : param.n_adj
    % array response
    [~, veh_beam] = min(abs(diff_angles_veh));
    [~, bs_beam] = min(abs(diff_angles_bs));
    e_r = veh_beam_book(:, veh_beam);
    e_t = bs_beam_book(:, bs_beam);
    
    % Cancel cur min value
    diff_angles_veh(veh_beam) = inf;
    diff_angles_bs(bs_beam) = inf;
    
    % calculate abs(y)
    y_abs = abs(e_r' * h_list{i} * e_t + noise_list{i}(veh_beam, bs_beam));
    if y_abs > y_max
        y_max = y_abs;
        prefer_veh_beam = veh_beam;
        prefer_bs_beam = bs_beam;
    end
end
    % array response
    e_r = veh_beam_book(:, prefer_veh_beam);
    e_t = bs_beam_book(:, prefer_bs_beam);
    
    % combine new feature
    y_e(i, :) = [veh_beam_angles(prefer_veh_beam), bs_beam_angles(prefer_bs_beam)];
    cur_feature = [cur_feature(:, 2:end), y_e(i, :)'];
    
    % calculate SNR
    p_s_e(i) = abs(e_r' * h_list{i} * e_t)^2;
    p_n_e(i) = abs(noise_list{i}(prefer_veh_beam, prefer_bs_beam))^2;
    SNR_e(i) = p_s_e(i) / p_n_e(i);
    
    if 10*log10(SNR_e(i)) <= param.SNR_threshold
        n_o_l_e = n_o_l_e + 1;
        cur_feature_size = 0;
    end
end

exhaustive.y = y_e;
exhaustive.p_s_e = p_s_e;
exhaustive.p_n_e = p_n_e;
exhaustive.SNR = SNR_e;
exhaustive.n_o = n_o_l_e;
exhaustive.n_m = n_m_l_e;

% Predict by hierarchical
y_h = zeros(n, 2);
SNR_h = zeros(n, 1);
p_s_h = zeros(n, 1);
p_n_h = zeros(n, 1);
n_o_l_h = 0;
n_m_l_h = 0;
cur_feature = zeros(2, lstm_step);
cur_feature_size = 0;

consecutive_pred = 0;

for i = 1 : n
    % prediction
    if cur_feature_size < lstm_step
        y_h(i, :) = angles_est_h_list(i, :);
        cur_feature_size = cur_feature_size + 1;
        n_m_l_h = n_m_l_h + 1;
    else
        y_h(i, :) = predict(net, num2cell(cur_feature, [1, 2]));
    end
    
%     % prediction
%     if cur_feature_size < lstm_step
%         y_h(i, :) = angles_est_h_list(i, :);
%         cur_feature_size = cur_feature_size + 1;
%         n_m_l_h = n_m_l_h + 1;
%     else
%         if consecutive_pred >= lstm_step
%             y_h(i, :) = angles_est_h_list(i, :);
%             n_m_l_h = n_m_l_h + 1;
%             consecutive_pred = 0;
%         else
%             y_h(i, :) = predict(net, num2cell(cur_feature, [1, 2]));
%             consecutive_pred = consecutive_pred + 1;
%         end
%     end
diff_angles_veh = veh_beam_angles - y_h(i, 1);
diff_angles_bs = bs_beam_angles - y_h(i, 2);
y_max = -inf;
prefer_veh_beam = 1;
prefer_bs_beam = 1;
for s = 1 : param.n_adj
    % array response
    [~, veh_beam] = min(abs(diff_angles_veh));
    [~, bs_beam] = min(abs(diff_angles_bs));
    e_r = veh_beam_book(:, veh_beam);
    e_t = bs_beam_book(:, bs_beam);
    
    % Cancel cur min value
    diff_angles_veh(veh_beam) = inf;
    diff_angles_bs(bs_beam) = inf;
    
    % calculate abs(y)
    y_abs = abs(e_r' * h_list{i} * e_t + noise_list{i}(veh_beam, bs_beam));
    if y_abs > y_max
        y_max = y_abs;
        prefer_veh_beam = veh_beam;
        prefer_bs_beam = bs_beam;
    end
end
    % array response
    e_r = veh_beam_book(:, prefer_veh_beam);
    e_t = bs_beam_book(:, prefer_bs_beam);
    
    % combine new feature
    y_h(i, :) = [veh_beam_angles(prefer_veh_beam), bs_beam_angles(prefer_bs_beam)];
    cur_feature = [cur_feature(:, 2:end), y_h(i, :)'];
    
    % calculate SNR
    p_s_h(i) = abs(e_r' * h_list{i} * e_t)^2;
    p_n_h(i) = abs(noise_list{i}(prefer_veh_beam, prefer_bs_beam))^2;
    SNR_h(i) = p_s_h(i) / p_n_h(i);
    
    if 10*log10(SNR_h(i)) <= param.SNR_threshold
        n_o_l_h = n_o_l_h + 1;
        cur_feature_size = 0;
    end
end

hierarchical.y = y_h;
hierarchical.p_s_h = p_s_h;
hierarchical.p_n_h = p_n_h;
hierarchical.SNR = SNR_h;
hierarchical.n_o = n_o_l_h;
hierarchical.n_m = n_m_l_h;
end

