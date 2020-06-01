function data = get_raw_data(info_bs, info_vehs, sumo_output)
timesteps_num = numel(fieldnames(sumo_output));

for i = 1 : timesteps_num
    timestep_name = strcat('t', num2str(i - 1));
    vehs_num = numel(fieldnames(sumo_output.(timestep_name)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        data.(timestep_name).(veh_name) = get_channel(info_bs, sumo_output.(timestep_name).(veh_name), info_vehs);
        
        [beam_pair, h_est] = beam_sweep(data.(timestep_name).(veh_name).h);
        data.(timestep_name).(veh_name).beam_pair = beam_pair;
        data.(timestep_name).(veh_name).h_est = h_est;
    end
end
end

