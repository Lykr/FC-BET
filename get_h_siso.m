function h_siso = get_h_siso(param, others, angles)

n = length(angles);
h_siso = zeros(n, 1);

veh_beam_book = param.veh.beam_info.beam_book;
veh_beam_angles = param.veh.beam_info.beam_angles;
bs_beam_book = param.bs.beam_info.beam_book;
bs_beam_angles = param.bs.beam_info.beam_angles;
h_list = others.h_list(end - n + 1 : end);

for i = 1 : n
    [~, beam_veh] = min(abs(veh_beam_angles - angles(i, 1)));
    [~, beam_bs] = min(abs(bs_beam_angles - angles(i, 2)));
    e_r = veh_beam_book(:, beam_veh);
    e_t = bs_beam_book(:, beam_bs);
    
    h_siso(i) = e_r' * h_list{i} * e_t;
end
end

