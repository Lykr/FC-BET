function [data_x, data_y, others] = gen_learning_data(param, raw_data)

lstm_step = param.lstm_step;
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
others.angles_est_h_list = zeros(data_size, 2);
others.SNR_est_h_list = zeros(data_size, 1);
others.outage = 0;
others.outage_h = 0;

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
        SNR_est = raw_data.(timestep_name).(veh_name).SNR_est;
        noise = raw_data.(timestep_name).(veh_name).noise;
        angles_est_h = raw_data.(timestep_name).(veh_name).angles_est_h;
        SNR_est_h = raw_data.(timestep_name).(veh_name).SNR_est_h;
        
        % Store raw data into list
        others.h_list{i} = h;
        others.h_siso_est_list(i) = h_siso_est;
        others.angles_list(i, :) = angles;
        others.angles_est_list(i, :) = angles_est;
        others.SNR_est_list(i, :) = SNR_est;
        others.noise_list{i} = noise;
        others.angles_est_h_list(i, :) = angles_est_h;
        others.SNR_est_h_list(i, :) = SNR_est_h;
        
        if 10*log10(SNR_est_h) <= param.SNR_threshold
            others.outage_h = others.outage_h + 1;
        end
        
        if 10*log10(SNR_est) <= param.SNR_threshold
            others.outage = others.outage + 1;
        end
    end
end

% Preprocessing
smooth_angles_est_list = sgolayfilt(others.angles_est_list, 1, 51);

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

