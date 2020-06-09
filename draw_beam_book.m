clear;

theta = [0: 0.001 * pi: 2 * pi];
n_a = 4;
n_p = n_a * 2;
beam_list = acos([1 : -2/n_p : -1 + 2/n_p]);
n = numel(theta);
e_l = zeros(n, 1);

% w = 1i.^((([0:n_a-1]' * [0:n_p-1])-n_p/2) / (n_p/4));

for j = 1 : n_p
e_t = get_eMatrix(n_a, beam_list(j));
for i = 1 : n
    e_l_i = get_eMatrix(n_a, theta(i));
    e_x = e_t' * e_l_i;
    e_l(i) = e_x;
end
polarplot(theta, abs(e_l));
hold on;
end
hold off;