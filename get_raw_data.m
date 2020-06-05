function data = get_raw_data(info_bs, info_vehs, sumo_output)
timesteps_num = numel(fieldnames(sumo_output));

n_r = info_vehs.num_antenna;
n_t = info_bs.num_antenna;
veh_beam_info = get_beam_info(n_r, 2 * n_r);
bs_beam_info = get_beam_info(n_t, 2 * n_t);

for i = 1 : timesteps_num
    timestep_name = strcat('t', num2str(i - 1));
    vehs_num = numel(fieldnames(sumo_output.(timestep_name)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        
        data.(timestep_name).(veh_name).speed = sumo_output.(timestep_name).(veh_name).speed;
        
        [angles, h] = get_channel(info_bs, sumo_output.(timestep_name).(veh_name), info_vehs);
        data.(timestep_name).(veh_name).angles = angles;
        data.(timestep_name).(veh_name).h = h;
        
        [beam_pair, angles_est, h_est] = beam_sweep(h, veh_beam_info, bs_beam_info);
        data.(timestep_name).(veh_name).beam_pair = beam_pair;
        data.(timestep_name).(veh_name).angles_est = angles_est;
        data.(timestep_name).(veh_name).h_est = h_est;
    end
end
end

