function [data_x, data_y, others] = get_learning_data(raw_data, lstm_step)

timesteps_num = numel(fieldnames(raw_data));
data_size = timesteps_num - lstm_step;
data_x = cell(data_size, 1);
temp_x = [];
data_y = zeros(data_size, 2);
others.h_list = cell(data_size, 1);
others.h_siso_est_list = zeros(data_size, 1);
others.angles_list = zeros(data_size, 2);
others.angles_est_list = zeros(data_size, 2);
others.SNR_est_list = zeros(data_size, 1);
others.noise_list = cell(data_size, 1);
others.original_y = zeros(data_size, 2);

% Get data
for i = 1 : timesteps_num
    timestep_name = strcat('t', num2str(i - 1));
    vehs_num = numel(fieldnames(raw_data.(timestep_name)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        h = raw_data.(timestep_name).(veh_name).h;
        h_siso_est = raw_data.(timestep_name).(veh_name).h_siso_est;
        angles = raw_data.(timestep_name).(veh_name).angles;
        angles_est = raw_data.(timestep_name).(veh_name).angles_est;
        beam_pair = raw_data.(timestep_name).(veh_name).beam_pair;
        speed = raw_data.(timestep_name).(veh_name).speed;
        SNR_est = raw_data.(timestep_name).(veh_name).SNR_act;
        noise = raw_data.(timestep_name).(veh_name).noise;
        
        % Store raw data into list
        others.h_list{i} = h;
        others.h_siso_est_list(i) = h_siso_est;
        others.angles_list(i, :) = angles;
        others.angles_est_list(i, :) = angles_est;
        others.SNR_est_list(i, :) = SNR_est;
        others.noise_list{i} = noise;
    end
end

% Preprocessing
smooth_angles_est_list = sgolayfilt(others.angles_est_list, 1, 11);

for i = 1 : timesteps_num
    for j = 1 : vehs_num
        angles_est = smooth_angles_est_list(i, :);
        x = angles_est';  % add AOA and AOD as input
        temp_x = [temp_x x]; % append input
        
        if size(temp_x, 2) == lstm_step + 1
            index = i - lstm_step;
            data_x{index} = temp_x(:, 1:lstm_step);
            data_y(index, :) = angles_est;
            temp_x(:,1) = [];
        end
    end
end
end

