function [data_x, data_y] = get_learning_data(raw_data, lstm_step)

timesteps_num = numel(fieldnames(raw_data));
data_size = timesteps_num - lstm_step;
data_x = cell(data_size, 1);
temp_x = [];
data_y = zeros(data_size, 1);

for i = 1 : timesteps_num
    timestep_name = strcat('t', num2str(i - 1));
    vehs_num = numel(fieldnames(raw_data.(timestep_name)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        h = raw_data.(timestep_name).(veh_name).h;
        beam_pair = raw_data.(timestep_name).(veh_name).beam_pair;
        
        [n_r, n_t] = size(h);
        h = reshape([real(h) imag(h)], n_r * n_t * 2, 1); % reshape h matrix to vector
        temp_x = [temp_x h];
        if size(temp_x, 2) == lstm_step + 1
            index = i - lstm_step;
            data_x{index} = temp_x(:, 1:lstm_step);
            data_y(index) = beam_pair_to_index(n_t, beam_pair);
            temp_x(:,1) = [];
        end
    end
end

data_y = categorical(data_y);
end

