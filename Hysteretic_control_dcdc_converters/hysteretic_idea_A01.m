%% HYSTERESIS BLOCK (SCHMITT TRIGGER / RELAY WITH HYSTERESIS) - SIMPLE DEMO
% Output switches to 1 when input rises above +h
% Output switches to 0 when input falls below -h
% Between -h and +h the output keeps its previous value (memory).

clear; clc; close all;

h  = 1;                          % switching thresholds are +h and -h
t  = linspace(0, 4*pi, 2000);
x  = 2*sin(t);                   % input: slow sine sweeping up and down
y  = zeros(size(x));             % output
y(1) = 0;

for k = 2:numel(x)
    if x(k) >= h
        y(k) = 1;                % rose above upper threshold
    elseif x(k) <= -h
        y(k) = 0;                % fell below lower threshold
    else
        y(k) = y(k-1);           % inside the band: hold previous output
    end
end

% For comparison: ordinary comparator (no hysteresis)
y_nohys = double(x >= 0);

%% Plots
figure('Position',[100 100 1000 650]);

subplot(2,2,1);
plot(t, x, 'b', 'LineWidth', 1.5); hold on;
yline(h, 'r--', '+h'); yline(-h, 'r--', '-h');
title('Input'); xlabel('Time'); grid on;

subplot(2,2,3);
stairs(t, y, 'm', 'LineWidth', 1.5); ylim([-0.2 1.2]);
title('Output with hysteresis'); xlabel('Time'); grid on;

subplot(2,2,2);
plot(x, y_nohys, 'k', 'LineWidth', 1.5); ylim([-0.2 1.2]);
title('No hysteresis: single threshold'); xlabel('Input x'); ylabel('Output y'); grid on;

subplot(2,2,4);
plot(x, y, 'm', 'LineWidth', 1.5); hold on;
xline(h, 'r--'); xline(-h, 'r--'); ylim([-0.2 1.2]);
title('With hysteresis: loop'); xlabel('Input x'); ylabel('Output y'); grid on;

%% Noise robustness: why hysteresis is useful
figure('Position',[150 150 1000 400]);
xn = 0.3*sin(2*pi*0.5*t) + 0.15*randn(size(t));   % slow signal + noise near zero
yn_nohys = double(xn >= 0);
yn_hys = zeros(size(xn));
hn = 0.3;
for k = 2:numel(xn)
    if xn(k) >= hn,      yn_hys(k) = 1;
    elseif xn(k) <= -hn, yn_hys(k) = 0;
    else,                yn_hys(k) = yn_hys(k-1);
    end
end

subplot(1,3,1); plot(t, xn, 'b'); title('Noisy input'); grid on;
subplot(1,3,2); stairs(t, yn_nohys, 'k'); ylim([-0.2 1.2]);
title('Comparator: chatters'); grid on;
subplot(1,3,3); stairs(t, yn_hys, 'm'); ylim([-0.2 1.2]);
title('Hysteresis: clean switching'); grid on;