function beam_info = get_beam_info(antenna_num, beam_num)
    beam_book = zeros(antenna_num, beam_num);
    beam_angles = acos([1 : -2/beam_num : -1 + 2/beam_num]);
    
    for i = 1 : beam_num
        beam_book(:, i) = get_eMatrix(antenna_num, beam_angles(i));
    end
    
    beam_info.beam_book = beam_book;
    beam_info.beam_angles = beam_angles;
end

