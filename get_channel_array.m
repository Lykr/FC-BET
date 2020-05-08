function channel_array = get_channel_array(info_bs, sumo_output)

timesteps_num = numel(fieldnames(sumo_output));

for i = 1 : timesteps_num
    timestep_name = strcat('t', num2str(i - 1));
    vehs_num = numel(fieldnames(sumo_output.(timestep_name)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        channel_array.(timestep_name).(veh_name) = ...
            generate_channel(info_bs, sumo_output.(timestep_name).(veh_name));
    end
end
end

