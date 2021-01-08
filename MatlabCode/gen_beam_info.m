function beam_info = gen_beam_info(antenna_num, beam_num)
    beam_book = zeros(antenna_num, beam_num);
    beam_angles = [pi/beam_num: pi/beam_num : pi];
    % acos([1 : -2/beam_num : -1 + 2/beam_num]); [0: pi/beam_num : pi - pi/beam_num]
    
    for i = 1 : beam_num
        beam_book(:, i) = gen_eMatrix(antenna_num, beam_angles(i));
    end
    
    beam_info.beam_book = beam_book;
    beam_info.beam_angles = beam_angles;
    
    % hierachical book, 2^n, beam_num = valid antenna num
    level = log2(antenna_num);
    beam_book_h = cell(level, 1);
    
    for i = 1 : level
        beam_num_h = 2 ^ i;
        beam_angles_h = [pi / beam_num_h / 2 : pi / beam_num_h : pi];
        beam_book_h{i} = zeros(antenna_num, beam_num_h);
        for j = 1 : beam_num_h
            beam_book_h{i}(:, j) = [gen_eMatrix(beam_num_h, beam_angles_h(j)); zeros(antenna_num - beam_num_h, 1)];
        end
    end
    beam_info.beam_book_h = beam_book_h;
end

