%% Check results of networks

%% AOA and AOD
figure(1);
hold on;
plot(y_test(:, 1), '.');
plot(y_test(:, 2), '.');
plot(y_pred(:, 1), 'x');
plot(y_pred(:, 2), 'x');
hold off;
xlim([0 t_p]);
ylim([0 pi]);
legend('AOA: Exhaustive Search', 'AOD: Exhaustive Search', 'AOA: LSTM-based', 'AOD: LSTM-based');

% % h_siso
% h_siso_est = test_others.h_siso_est_list(end - t_p + 1 : end);
% 
% figure(2);
% hold on;
% plot((abs(h_siso_pred) - abs(h_siso_est)) ./ abs(h_siso_est), '.');
% hold off;
% xlim([0 t_p]);
% ylim([-1 0]);

%% SNR
figure(3);
hold on;
plot(SNR_est, 'LineWidth', 1);
plot(SNR_pred, 'LineWidth', 1);
plot([0 t_p], [SNR_est_mean SNR_est_mean], 'LineWidth', 1.5);
plot([0 t_p], [SNR_pred_mean SNR_pred_mean], 'LineWidth', 1.5);
plot([0 t_p], [param.SNR_threshold param.SNR_threshold], 'LineWidth', 1.5);
hold off;
xlim([0 t_p]);
legend('Exhaustive Search', 'LSTM-based', ...
    'Average SNR of Exhaustive Search', 'Average SNR of LSTM-based', ...
    'SNR Threshold');

%% CDF of SNR
figure(4);
hold on;
cdf_h1 = cdfplot(SNR_est);
cdf_h2 = cdfplot(SNR_pred);
set(cdf_h1, 'LineWidth', 1.5);
set(cdf_h2, 'LineWidth', 1.5);
plot([param.SNR_threshold param.SNR_threshold], [0 1], 'LineWidth', 1.5);
hold off;
legend('Exhaustive Search', 'LSTM-based', 'Threshold');

%% Network performances
nrmse = sqrt(mean((y_pred(:, 2) - y_test(:, 2)) .^ 2) / mean(y_test(:, 2) .^2));
% RMSE
figure(5);
hold on;
box on;
plot(info.TrainingRMSE, 'linewidth', 1);
xlabel('Training epochs', 'Fontname', 'Times New Roman');
ylabel('RMSE (rad)', 'Fontname', 'Times New Roman');
hold off;
set (gcf,'Position',[400,400,500,150])
% Loss
figure(6);
hold on;
box on;
plot(info.TrainingLoss, 'linewidth', 1);
xlabel('Training epochs', 'Fontname', 'Times New Roman');
ylabel('Loss (rad^2)', 'Fontname', 'Times New Roman');
hold off;
set (gcf,'Position',[400,400,500,150])