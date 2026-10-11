%% HYSTERETIC (BANG-BANG WITH HYSTERESIS) CONTROL - TEACHING DEMO
% Plant : first-order thermal system  tau*dT/dt = -(T - Tamb) + K*u
% Control: heater ON  when T <= Tsp - h
%          heater OFF when T >= Tsp + h
%          otherwise keep previous state (this memory = hysteresis)
% No toolboxes required. Local functions need MATLAB R2016b or later.

clear; clc; close all;

%% Parameters
P.tau  = 50;      % thermal time constant [s]
P.K    = 40;      % temperature rise when heater fully ON [degC]
P.Tamb = 15;      % ambient temperature [degC]
P.Tsp  = 30;      % set-point [degC]
P.dt   = 0.01;    % integration step [s]
P.tEnd = 600;     % simulation time [s]
P.T0   = 15;      % initial temperature [degC]

h = 1.0;          % half-width of hysteresis band [degC]

%% Case 1: main demonstration
[t, T, u] = simulate_hysteretic(P, h);

figure('Name','Hysteretic control','Position',[100 100 1000 700]);

subplot(2,2,1);
plot(t, T, 'b', 'LineWidth', 1.5); hold on;
yline(P.Tsp,     'k--', 'Set-point');
yline(P.Tsp + h, 'r:',  'Upper limit');
yline(P.Tsp - h, 'r:',  'Lower limit');
xlabel('Time [s]'); ylabel('Temperature [^\circC]');
title(sprintf('Output, band = \\pm%.1f ^\\circC', h)); grid on;

subplot(2,2,3);
stairs(t, u, 'm', 'LineWidth', 1.5);
ylim([-0.2 1.2]); xlabel('Time [s]'); ylabel('Heater u');
title('Control signal (ON/OFF)'); grid on;

% Zoom on steady-state cycling
subplot(2,2,2);
idx = t > 300 & t < 400;
plot(t(idx), T(idx), 'b', 'LineWidth', 1.5); hold on;
yyaxis right; stairs(t(idx), u(idx), 'm', 'LineWidth', 1.2); ylim([-0.2 1.2]);
yyaxis left;
yline(P.Tsp + h, 'r:'); yline(P.Tsp - h, 'r:');
xlabel('Time [s]'); ylabel('T [^\circC]'); title('Zoom: limit cycle'); grid on;

% Relay characteristic: u versus T (the hysteresis loop)
subplot(2,2,4);
idx = t > 300;
plot(T(idx), u(idx), 'k', 'LineWidth', 1.2); hold on;
xline(P.Tsp - h, 'r:'); xline(P.Tsp + h, 'r:');
ylim([-0.2 1.2]); xlabel('Temperature [^\circC]'); ylabel('Heater u');
title('Hysteresis loop (u vs T)'); grid on;

%% Case 2: effect of the band width
hList = [0.05 0.25 0.5 1 2 4];
ripple = zeros(size(hList));
fsw    = zeros(size(hList));

for k = 1:numel(hList)
    [tk, Tk, uk] = simulate_hysteretic(P, hList(k));
    ss = tk > P.tEnd/2;                          % steady-state part only
    ripple(k) = max(Tk(ss)) - min(Tk(ss));       % peak-to-peak ripple
    nSw       = sum(abs(diff(uk(ss))));          % number of switchings
    fsw(k)    = nSw / (P.tEnd/2);                % switching frequency [Hz]
end

figure('Name','Band width trade-off','Position',[150 150 900 400]);

subplot(1,2,1);
plot(2*hList, ripple, 'o-', 'LineWidth', 1.5);
xlabel('Band width 2h [^\circC]'); ylabel('Peak-to-peak ripple [^\circC]');
title('Narrower band = smaller ripple'); grid on;

subplot(1,2,2);
plot(2*hList, fsw, 's-', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.1]);
xlabel('Band width 2h [^\circC]'); ylabel('Switching frequency [Hz]');
title('Narrower band = more switching'); grid on;

fprintf('\n  h [degC]   ripple [degC]   f_sw [Hz]\n');
fprintf('  %6.2f     %8.3f      %8.4f\n', [hList; ripple; fsw]);

%% Local function
function [t, T, u] = simulate_hysteretic(P, h)
    t = 0:P.dt:P.tEnd;
    n = numel(t);
    T = zeros(1, n);  u = zeros(1, n);
    T(1) = P.T0;
    u(1) = 1;                                    % start with heater ON
    for k = 1:n-1
        % Hysteretic controller
        if T(k) >= P.Tsp + h
            u(k+1) = 0;
        elseif T(k) <= P.Tsp - h
            u(k+1) = 1;
        else
            u(k+1) = u(k);                       % inside band: hold state
        end
        % Plant (forward Euler)
        dT = (-(T(k) - P.Tamb) + P.K*u(k)) / P.tau;
        T(k+1) = T(k) + P.dt*dT;
    end
end