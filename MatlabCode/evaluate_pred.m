function [exhaustive, hierarchical] = evaluate_pred(param, others_test, net)

veh_beam_book = param.veh.beam_info.beam_book;
veh_beam_angles = param.veh.beam_info.beam_angles;
bs_beam_book = param.bs.beam_info.beam_book;
bs_beam_angles = param.bs.beam_info.beam_angles;
h_list = others_test.h_list;
noise_list = others_test.noise_list;
angles_est_list = others_test.angles_est_list;
angles_est_h_list = others_test.angles_est_h_list;

n = length(h_list);
lstm_step = param.lstm_step;

SNR_e = zeros(n, 1);
y_e = zeros(n, 2);
n_o_l_e = 0;
n_m_l_e = 0;
cur_feature = zeros(2, lstm_step);
cur_feature_size = 0;

% Predict by exhaustive
for i = 1 : n
    % prediction
    if cur_feature_size < lstm_step
        y_e(i, :) = angles_est_list(i, :);
        cur_feature_size = cur_feature_size + 1;
        n_m_l_e = n_m_l_e + 1;
    else
        y_e(i, :) = predict(net, num2cell(cur_feature, [1, 2]));
    end
    
    % combine new feature
    cur_feature = [cur_feature(:, 2:end), y_e(i, :)'];
    
    % array response
    [~, beam_veh] = min(abs(veh_beam_angles - y_e(i, 1)));
    [~, beam_bs] = min(abs(bs_beam_angles - y_e(i, 2)));
    e_r = veh_beam_book(:, beam_veh);
    e_t = bs_beam_book(:, beam_bs);
    
    % calculate SNR
    SNR_e(i) = abs(e_r' * h_list{i} * e_t)^2 / abs(noise_list{i}(beam_veh, beam_bs))^2;
    
    if 10*log10(SNR_e(i)) <= param.SNR_threshold
        n_o_l_e = n_o_l_e + 1;
        cur_feature_size = 0;
    end
end

exhaustive.y = y_e;
exhaustive.SNR = SNR_e;
exhaustive.n_o = n_o_l_e;
exhaustive.n_m = n_m_l_e;

% Predict by hierarchical
y_h = zeros(n, 2);
SNR_h = zeros(n, 1);
n_o_l_h = 0;
n_m_l_h = 0;
cur_feature = zeros(2, lstm_step);
cur_feature_size = 0;

for i = 1 : n
    % prediction
    if cur_feature_size < lstm_step
        y_h(i, :) = angles_est_h_list(i, :);
        cur_feature_size = cur_feature_size + 1;
        n_m_l_h = n_m_l_h + 1;
    else
        y_h(i, :) = predict(net, num2cell(cur_feature, [1, 2]));
    end
    
    % combine new feature
    cur_feature = [cur_feature(:, 2:end), y_h(i, :)'];
    
    % array response
    [~, beam_veh] = min(abs(veh_beam_angles - y_h(i, 1)));
    [~, beam_bs] = min(abs(bs_beam_angles - y_h(i, 2)));
    e_r = veh_beam_book(:, beam_veh);
    e_t = bs_beam_book(:, beam_bs);
    
    % calculate SNR
    SNR_h(i) = abs(e_r' * h_list{i} * e_t)^2 / abs(noise_list{i}(beam_veh, beam_bs))^2;
    
    if 10*log10(SNR_h(i)) <= param.SNR_threshold
        n_o_l_h = n_o_l_h + 1;
        cur_feature_size = 0;
    end
end

hierarchical.y = y_h;
hierarchical.SNR = SNR_h;
hierarchical.n_o = n_o_l_h;
hierarchical.n_m = n_m_l_h;
end

