function [optimal_beam_pair, h_est] = beam_sweep(channel)

[n_r, n_t] = size(channel);
bs_beam_book = get_beam_list(n_t);
veh_beam_book = get_beam_list(n_r);

optimal_beam_pair = [0, 0];
best_siso_h = 0;

for i = 1 : n_t
    e_t = get_eMatrix(n_t, bs_beam_book(i));
    for j = 1 : n_r
        e_r = get_eMatrix(n_r, veh_beam_book(j));
        siso_h = e_r' * channel * e_t;
        if siso_h > best_siso_h
            best_siso_h = siso_h;
            optimal_beam_pair = [j, i];
        end
    end
end

h_est = best_siso_h * e_r * e_t';

end