function beam_book = get_beam_book(num_antenna)

    beam_book = [pi / num_antenna / 2 : pi / num_antenna : pi]; % from 0 to pi in uniform
end

