function [data_x, data_y] = get_learning_data(raw_data, lstm_step)

timesteps_num = numel(fieldnames(raw_data));
data_size = timesteps_num - lstm_step;
data_x = cell(data_size, 1);
temp_x = [];
data_y = zeros(data_size, 2);

for i = 1 : timesteps_num
    timestep_name = strcat('t', num2str(i - 1));
    vehs_num = numel(fieldnames(raw_data.(timestep_name)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        h = raw_data.(timestep_name).(veh_name).h_est;
        beam_pair = raw_data.(timestep_name).(veh_name).beam_pair;
        speed = raw_data.(timestep_name).(veh_name).speed;
        aoa = raw_data.(timestep_name).(veh_name).aoa;
        aod = raw_data.(timestep_name).(veh_name).aod;
        
        if aoa > pi
            aoa = 2 * pi - aoa;
        end
        
        if aod > pi
            aod = 2 * pi - aod;
        end
        
        [n_r, n_t] = size(h);
        b_r = get_beam_book(n_r);
        b_t = get_beam_book(n_t);
        angle_est = [b_r(beam_pair(1)) b_t(beam_pair(2))];
        
        x = reshape(angle_est, 2, 1);
        % reshape(beam_pair, 2, 1);
        % reshape([real(h) imag(h)], n_r * n_t * 2, 1); % reshape h matrix to vector
        x = [x; speed];
        temp_x = [temp_x x];
        
        if size(temp_x, 2) == lstm_step + 1
            index = i - lstm_step;
            data_x{index} = temp_x(:, 1:lstm_step);
            data_y(index, :) = angle_est;
            temp_x(:,1) = [];
        end
    end
end
end

