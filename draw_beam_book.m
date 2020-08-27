clear;

theta = [0: 0.001 * pi: 2*pi];
n_a = 4;
n_p = n_a * 2;
beam_list = [pi / n_p / 2: pi / n_p: pi];% acos([1 - 2/n_p : -2/n_p : -1]);
n = numel(theta);
e_l = zeros(n, 1);

% w = 1i.^((([0:n_a-1]' * [0:n_p-1])-n_p/2) / (n_p/4));

for j = 1:n_p
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



%%
nt = 16;
bn = 2 * nt;
M = zeros(nt, bn);
beam_angles = [0: pi/bn: pi-pi/bn];
theta = [0: 0.001 * pi: 2*pi];

for i = 1 : bn
    M(:, i) = get_eMatrix(nt, beam_angles(i));
end

r = 2;
u = kron(randi(2, bn / r, 1) - 1, ones(r, 1));
v = inv(M*M')*M*u;
v(9:end) = 0;
vv = inv(M*M')*M*(u-1)*(-1);

for i = 1 : numel(theta)
    e_l_i = get_eMatrix(nt, theta(i));
    e_l(i) = v' * e_l_i;
    e_ll(i) = vv' * e_l_i;
end
polarplot(theta, abs(e_l));
hold on;
polarplot(theta, abs(e_ll));
polarplot(beam_angles, u, 'o');
hold off;

%% loss º¯ÊýµÄ±Æ½ü

for j = 4 %1:n_p
    e_t = get_eMatrix(n_a, beam_list(j));
    for i = 1 : n
        e_l_i = get_eMatrix(n_a, theta(i));
        e_x = e_t' * e_l_i;
        e_l(i) = e_x;
    end
    plot(theta, abs(e_l));
    hold on;
    plot(theta, interp1(e_l));
end
hold off;