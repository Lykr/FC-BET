function data = get_raw_data(param, sumo_output)
timesteps_num = numel(fieldnames(sumo_output));

for i = 1 : timesteps_num
    timestep_name = strcat('t', num2str(i - 1));
    vehs_num = numel(fieldnames(sumo_output.(timestep_name)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        veh_data = sumo_output.(timestep_name).(veh_name);
        
        data.(timestep_name).(veh_name).speed = veh_data.speed;
        
        [angles, h] = get_channel(param, veh_data);
        data.(timestep_name).(veh_name).angles = angles;
        data.(timestep_name).(veh_name).h = h;
        
        CSI = beam_sweep(h, param);
        data.(timestep_name).(veh_name).beam_pair = CSI.beam_pair;
        data.(timestep_name).(veh_name).angles_est = CSI.angles_est;
        data.(timestep_name).(veh_name).h_siso_est = CSI.h_siso_est;
        data.(timestep_name).(veh_name).SNR_act = CSI.SNR_act;
        data.(timestep_name).(veh_name).noise = CSI.noise;
    end
end
end

