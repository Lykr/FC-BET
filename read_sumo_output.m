%% Initialization
clear;
xml = xmlread('beamformingScene.out.xml');
xml_root = xml.getDocumentElement();
timesteps = xml_root.getElementsByTagName('timestep');
timesteps_num = timesteps.getLength();

%%
sumo_output = struct();

for i = 0 : timesteps_num - 1 % 0.01s per
    xml_timestep = timesteps.item(i);
    str_timestep = strcat('t', num2str(i));
    sumo_output.(str_timestep) = struct();
    xml_vehs = xml_timestep.getElementsByTagName('vehicle');
    xml_vehs_num = xml_vehs.getLength();
    for j = 0 : xml_vehs_num - 1
        xml_veh = xml_vehs.item(j);
        str_veh = strcat('v', num2str(j));
        sumo_output.(str_timestep).(str_veh) = struct();
        sumo_output.(str_timestep).(str_veh).x = str2double(xml_veh.getAttribute('x'));
        sumo_output.(str_timestep).(str_veh).y = str2double(xml_veh.getAttribute('y'));
        sumo_output.(str_timestep).(str_veh).speed = str2double(xml_veh.getAttribute('speed'));
        % change the normal vector to east and anti-clockwise
        angle_old = str2double(xml_veh.getAttribute('angle'));
        sumo_output.(str_timestep).(str_veh).angle = deg2rad(mod(450 - angle_old, 360)); % rad
    end
end

save('sumo_output.mat', 'sumo_output');