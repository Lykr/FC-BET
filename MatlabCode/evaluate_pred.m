function [y_pred, SNR_pred, n_o_l, n_m, n_o_e] = evaluate_pred(param, others_test, net, x_test, y_test)

n = length(x_test);
lstm_step = size(x_test{1}, 2);

SNR_pred = zeros(n, 1);
y_pred = zeros(n, 2);
y_pred(1 : lstm_step, :) = x_test{1}';

n_o_l = 0;
n_o_e = 0;
n_m = lstm_step;
hasOutage = 0;
mao = 0;

veh_beam_book = param.veh.beam_info.beam_book;
veh_beam_angles = param.veh.beam_info.beam_angles;
bs_beam_book = param.bs.beam_info.beam_book;
bs_beam_angles = param.bs.beam_info.beam_angles;
h_list = others_test.h_list;
noise_list = others_test.noise_list;

for i = lstm_step + 1 : n + lstm_step
    % prediction
    if hasOutage == 1
        y_pred(i, :) = y_test(i - lstm_step, :);
        n_m = n_m + 1;
        mao = mao + 1;
        if mao >= lstm_step
            hasOutage = 0;
            mao = 0;
        end
    else
        y_pred(i, :) = predict(net, num2cell(y_pred(i - lstm_step : i - 1, :)', [1 2]));
    end
    
    % array response
    [~, beam_veh] = min(abs(veh_beam_angles - y_pred(i, 1)));
    [~, beam_bs] = min(abs(bs_beam_angles - y_pred(i, 2)));
    e_r = veh_beam_book(:, beam_veh);
    e_t = bs_beam_book(:, beam_bs);
    
    % calculate SNR
    SNR_pred(i) = abs(e_r' * h_list{i} * e_t)^2 / abs(noise_list{i}(beam_veh, beam_bs))^2;
    
    if 10*log10(SNR_pred(i)) <= param.SNR_threshold
        hasOutage = 1;
        n_o_l = n_o_l + 1;
        mao = 0;
    end
    
    if 10*log10(others_test.SNR_est_list(i)) <= param.SNR_threshold
        n_o_e = n_o_e + 1;
    end
end

SNR_pred = SNR_pred(lstm_step + 1 : end, :);
y_pred = y_pred(lstm_step + 1 : end, :);
end

