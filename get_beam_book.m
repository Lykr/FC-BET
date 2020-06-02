function beam_book = get_beam_book(num_antenna)

    x = [0 : pi / num_antenna : pi - pi / num_antenna / 2];

    beam_book = x;
end

