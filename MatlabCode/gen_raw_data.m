function data = gen_raw_data(param, sumo_output)
timesteps_num = numel(fieldnames(sumo_output));
t = 0;

for i = 1 : timesteps_num
    if mod(i - 1, param.interval) ~= 0
        continue;
    end
    timestep = strcat('t', num2str(i - 1));
    rec_timestep = strcat('t', num2str(t));
    t = t + 1;
    vehs_num = numel(fieldnames(sumo_output.(timestep)));
    for j = 1 : vehs_num
        veh_name = strcat('v', num2str(j - 1));
        veh_data = sumo_output.(timestep).(veh_name);
        
        data.(rec_timestep).(veh_name).speed = veh_data.speed;
        
        [angles, h] = gen_channel(param, veh_data);
        data.(rec_timestep).(veh_name).angles = angles;
        data.(rec_timestep).(veh_name).h = h;
        
        CSI = beam_sweep(h, param);
        data.(rec_timestep).(veh_name).beam_pair = CSI.beam_pair;
        data.(rec_timestep).(veh_name).angles_est = CSI.angles_est;
        data.(rec_timestep).(veh_name).h_siso_est = CSI.h_siso_est;
        data.(rec_timestep).(veh_name).SNR_est = CSI.SNR_est;
        data.(rec_timestep).(veh_name).noise = CSI.noise;
        
        data.(rec_timestep).(veh_name).angles_est_h = CSI.angles_est_h;
        data.(rec_timestep).(veh_name).SNR_est_h = CSI.SNR_est_h;
    end
end
end

