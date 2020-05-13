function index = beam_pair_to_index(n_t, beam_pair)
l_r = beam_pair(1);
l_t = beam_pair(2);
index = (l_r - 1) * n_t + l_t;
end