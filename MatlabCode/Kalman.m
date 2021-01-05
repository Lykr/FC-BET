clear; % 清理数据
clf; % 清理图像

%% 参数
n = 100; % 仿真次数
nt = 16; % 发送端天线数
nr = 16; % 接收端天线数
f = 60e9; % 载波频率
L = 3; % 路径数
SNR = 15; % 观察信号信噪比 dB
var_u = (pi / 360) ^ 2; % 运动方差

%% 仿真初始化
var_v = nt * nr / 10 ^ (SNR / 10); % 噪声方差
lenc = physconst('LightSpeed') / f; % 载波波长
init_theta = rand(2 * L, 1) * pi; % 路径出发角和到达角 U(0, pi)
alpha = sqrt(nt * nr / 2) * (randn(L, 1) + 1i * randn(L, 1)); % 路径增益 CN(0, nt * nr)
beam_angle = [0 : pi / nt : pi - pi / nt, 0 : pi / nr : pi - pi / nr]; % 波束角度集合

% 论文中路径增益实际未采用下方方式，而是直接假设增益符合正态分布
% dl = ;
% pl = ;
% alpha = zeros(1, L);
% 
% for i = 1 : L
%     alpha(i) = pl(i) * sqrt(nt * nr) * exp(-1i * 2 * pi * dl(i) / lenc);
% end

%% 卡尔曼滤波过程
% 算法初始化
guess_var_u = (pi / 90) ^ 2;
act_theta = init_theta;
last_theta = init_theta;
last_M = zeros(2 * L, 2 * L);
rec_act_theta = zeros(2 * L, n); % 储存实际结果
rec_pre_theta = zeros(2 * L, n); % 储存预测结果
rec_dir_theta = zeros(2 * L, n); % 储存直接观测结果

rec_act_theta(:, 1) = init_theta;
rec_pre_theta(:, 1) = init_theta;
rec_dir_theta(:, 1) = init_theta;

for i = 2 : n
    act_theta = next_theta(L, act_theta, var_u); % 信道变动
    
    % 预测
    pre_theta = last_theta; % 预测估计
    pre_M = last_M + eye(2 * L) * var_v; % 协方差估计
    
    % 更新
    C = get_C(nt, nr, L, alpha, pre_theta, beam_angle); % 观察矩阵 nt * nr, 2 * L
    S = C * pre_M * C' + eye(nr * nt) * var_v; % 预测余量协方差
    K = pre_M * C' / S; % 最优卡尔曼增益
    g = get_g(nt, nr, L, pre_theta, alpha, beam_angle); % 理想观察信号
    y = get_y(nt, nr, g, C, act_theta, pre_theta, var_v); % 观察信号
    res_y = y - g; % 测量余量
    
    last_theta = pre_theta + K * res_y; % 更新预测估计
    last_M = (eye(2 * L) - K * C) * pre_M; % 更新协方差估计
    
    % 记录角度数据
    rec_act_theta(:, i) = act_theta;
    rec_pre_theta(:, i) = last_theta;
    rec_dir_theta(:, i) = C \ (y - g + C * pre_theta);
end

%% 仿真结果

figure(1);

h = 2;
w = 3;

for i = 1 : 2 * L
    subplot(h, w, i);
    hold on;
    plot(rec_act_theta(i, :));
    plot(abs(rec_pre_theta(i, :)));
    plot(abs(rec_dir_theta(i, :)));
    title(['路径 ' num2str(i)]);
    if i == 1
        legend('实际角度', '估计角度', '观测角度');
        xlabel('时刻');
        ylabel('角度(rad)');
    end
end

% plot(mean(rec_act_theta));
% plot(abs(mean(rec_pre_theta)));
% plot(abs(mean(rec_dir_theta)));
% legend('实际角度', '估计角度', '观测角度');

% 计算 NMSE
NMSE_no_pre = 0;
NMSE_no_dir = 0;
NMSE_deno = 0;

for i = 1 : n
    pre_channel = create_channel(nt, nr, L, rec_pre_theta(:, i), alpha);
    dir_channel = create_channel(nt, nr, L, rec_dir_theta(:, i), alpha);
    act_channel = create_channel(nt, nr, L, rec_act_theta(:, i), alpha);
    
    res_pre = pre_channel - act_channel;
    res_dir = dir_channel - act_channel;
    NMSE_no_pre = NMSE_no_pre + sum(abs(res_pre) .^ 2, 'all') / n;
    NMSE_no_dir = NMSE_no_dir + sum(abs(res_dir) .^ 2, 'all') / n;
    NMSE_deno = NMSE_deno + sum(abs(act_channel) .^ 2, 'all') / n;
end

NMSE = 10 * log10(NMSE_no_pre / NMSE_deno);

%% 观察信号 y(n) = C(n) * theta + v(n) + d(n)
function y = get_y(nt, nr, g, C, act_theta, pre_theta, var_v)
    v = get_v(nt, nr, var_v);
    y = C * act_theta + v + g - C * pre_theta;
end

%% 观测矩阵 C
function C = get_C(nt, nr, L, alpha, theta, beam_angle)
    C = zeros(nt * nr, 2 * L);
    
    for i = 1 : nt * nr
        q = mod((i - 1), nr) + 1;
        p = fix((i - 1) / nr) + 1;
        
        for j = 1 : L
            omiga_r = (cos(theta(L + j)) - cos(beam_angle(nt + q)));
            omiga_t = (cos(theta(j)) - cos(beam_angle(p)));
            
            % g_qp 关于 AOD_l 的偏导数
            a = -alpha(j) * sin(theta(j)) / nt / nr;
            b = (1 - exp(-1i * pi * nr * omiga_r)) / (1 - exp(-1i * pi * omiga_r));
            c = (1i * pi * exp(1i * pi * omiga_t) - 1i * pi * nt * exp(1i * pi * nt * omiga_t) + 1i * pi * (nt - 1) * exp(1i * pi * (nt + 1) * omiga_t)) / (1 - exp(1i * pi * omiga_t)) ^ 2;
            
            C(i, j) = a * b * c;
            
            % g_qp 关于 AOA_l 的偏导数
            a = -alpha(j) * sin(theta(L + j)) / nt / nr;
            b = (1 - exp(1i * pi * nt * omiga_t)) / (1 - exp(1i * pi * omiga_t));
            c = (-1i * pi * exp(-1i * pi * omiga_r) + 1i * pi * nr * exp(-1i * pi * nr * omiga_r) - 1i * pi * (nr - 1) * exp(-1i * pi * (nr + 1) * omiga_r)) / (1 - exp(-1i * pi * omiga_r)) ^ 2;
            
            C(i, L + j) = a * b * c;
        end
    end
end

%% 信道变动 theta(n) = theta(n-1) + u(n)
function next_theta = next_theta(L, theta, var_u)
    next_theta = zeros(2 * L, 1);
    
    for i = 1 : 2 * L
        while true
            r = randn * sqrt(var_u);
            t = theta(i) + r;
            if 0 <= t && t <= pi
                next_theta(i) = t;
                break;
            end
        end
    end
end

%% 信号 g 矩阵
function g = get_g(nt, nr, L, theta, alpha, beam_angle)
    g = zeros(nr, nt);
    
    for i = 1 : nr
        for j = 1 : nt
            g(i, j) = get_gqp(i, j, nt, nr, L, theta, alpha, beam_angle);
        end
    end
    
    g = g(:); % 矩阵一维化
end

%% 信号 g_qp
function g_qp = get_gqp(q, p, nt, nr, L, theta, alpha, beam_angle)
    g_qp = 0;
    
    for i = 1 : L
        omiga_r = cos(theta(L + i)) - cos(beam_angle(nt + q));
        omiga_t = cos(theta(i)) - cos(beam_angle(p));
        g_qp = g_qp + (alpha(i) * (1 - exp(-1i * pi * nr * omiga_r)) * (1 - exp(1i * pi * nt * omiga_t))) / ...
            (nt * nr * (1 - exp(-1i * pi * omiga_r)) * (1 - exp(1i * pi * omiga_t)));
    end
end

%% 观察噪声 v
function v = get_v(nt, nr, var_v)
    v = sqrt(var_v / 2) * (randn(nr * nt, 1) + 1i * randn(nr * nt, 1));
end

%% 信道矩阵 H
function channel = create_channel(nt, nr, L, theta, alpha)
    channel = zeros(nr, nt);
    
    for i = 1 : L
        et = create_eMatrix(nt, theta(i));
        er = create_eMatrix(nr, theta(i + L));
        
        channel = channel + alpha(i) * er * et';
    end
end

%% 响应矩阵 e_t/r
function eMatrix = create_eMatrix(n, angle)
    eMatrix = ones(n,1);
    
    for i = 1 : n
        eMatrix(i) = exp(-1i * pi * (i - 1) * cos(angle));
    end
    
    eMatrix = 1 / sqrt(n) .* eMatrix;
end