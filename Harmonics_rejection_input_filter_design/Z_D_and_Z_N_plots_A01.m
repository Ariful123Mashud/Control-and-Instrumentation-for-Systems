%% ============================================================
% Z_D, Z_N, Z_O and Ratio Bode Plots
% =============================================================

clear;
clc;
close all;

%% ============================================================
% Converter Parameters
% =============================================================

D = 0.5;            % Duty ratio
L = 100e-6;         % Inductance (H)
C = 100e-6;         % Capacitance (F)
R = 3; % Load resistance (Ohm)
R_f = 1% resistance (Ohm)
C_b = 4700e-6;
C_f = 370e-6;
L_f = 430e-6;

%% ============================================================
% Resonant Frequency
% =============================================================

w_o = 1/sqrt(L*C);              % rad/s
f_o = w_o/(2*pi);               % Hz

fprintf('\n========================================\n');
fprintf('Converter Parameters\n');
fprintf('========================================\n');

fprintf('D       = %.3f\n', D);
fprintf('L       = %.2e H\n', L);
fprintf('C       = %.2e F\n', C);
fprintf('R       = %.2f Ohm\n', R);

fprintf('\nResonant frequency:\n');
fprintf('wo      = %.2f rad/s\n', w_o);
fprintf('fo      = %.2f Hz\n', f_o);

%% ============================================================
% Q Factor and Damping Ratio
% =============================================================

Q = w_o * R * C;
zeta = 1/(2*Q);

fprintf('\nQ factor       = %.3f\n', Q);
fprintf('Damping ratio  = %.4f\n', zeta);

%% ============================================================
% Laplace Variable
% =============================================================

s = tf('s');

%% ============================================================
% Impedances
% =============================================================

% ------------------------------------------------------------
% Z_D
%
% Z_D = (1/D^2) [sL + R/(1+sRC)]
% ------------------------------------------------------------

Z_D = (1/D^2) * ...
      (s*L + R/(1 + s*R*C));


% ------------------------------------------------------------
% Z_N
%
% Z_N = -R/D^2
% ------------------------------------------------------------

Z_N = -R/D^2;


% ------------------------------------------------------------
% Z_O
%
% Z_O = sL || 1/(sC)
%
% Z_O = sL/(1+s^2LC)
% ------------------------------------------------------------

% Z_O = (s*L)/(1 + s^2*L*C);
Z_O = (s*L_f)/(1 + s^2*L_f*C_f);

%% ============================================================
% Ratio
%
% H(s) = (1 + Z_O/Z_N)/(1 + Z_O/Z_D)
% =============================================================

H_ratio = (1 + Z_O/Z_N) / ...
          (1 + Z_O/Z_D);

%% ============================================================
% Ratio
%
% G_vd = G_vd*H(s)  ============Transfer function with input filter 
% =============================================================
G_vd = D/(1+L/R*s+s^2*L*C);
H_ratio = (1 + Z_O/Z_N) / ...
          (1 + Z_O/Z_D);
G_vd_filter = G_vd*H_ratio;


%% ============================================================
% Display Transfer Functions
% =============================================================

fprintf('\n========================================\n');
fprintf('Transfer Functions\n');
fprintf('========================================\n');

disp('Z_D(s) = ');
Z_D

disp('Z_N(s) = ');
Z_N

disp('Z_O(s) = ');
Z_O

disp('H(s) = ');
H_ratio

%% ============================================================
% Frequency Range
% =============================================================

f = logspace(0,6,2000);      % Hz
w = 2*pi*f;                  % rad/s

%% ============================================================
% Z_D Bode Data
% =============================================================

[mag_D,phase_D] = bode(Z_D,w);

mag_D = squeeze(mag_D);
phase_D = squeeze(phase_D);

%% ============================================================
% Z_N Bode Data
% =============================================================
%
% Z_N is a CONSTANT.
% Therefore create vectors having the same length as f.
% =============================================================

mag_N = abs(Z_N) * ones(size(f));

% Negative real impedance has phase = +180 degrees
phase_N = 180 * ones(size(f));

mag_N_dB = 20*log10(mag_N);

%% ============================================================
% Z_O Bode Data
% =============================================================

[mag_O,phase_O] = bode(Z_O,w);

mag_O = squeeze(mag_O);
phase_O = squeeze(phase_O);

%% ============================================================
% H Ratio Bode Data
% =============================================================

[mag_H,phase_H] = bode(H_ratio,w);

mag_H = squeeze(mag_H);
phase_H = squeeze(phase_H);

%% ============================================================
% H Ratio Bode Data
% =============================================================

[mag_G_vd,phase_G_vd] = bode(G_vd,w);

mag_G_vd = squeeze(mag_G_vd);
phase_G_vd = squeeze(phase_G_vd);

[mag_G_vd_filter,phase_G_vd_filter] = bode(G_vd_filter,w);

mag_G_vd_filter = squeeze(mag_G_vd_filter);
phase_G_vd_filter = squeeze(phase_G_vd_filter);


%% ============================================================
% Convert Magnitude to dB
% =============================================================

mag_D_dB = 20*log10(mag_D);
mag_O_dB = 20*log10(mag_O);
mag_H_dB = 20*log10(mag_H);
mag_G_vd_dB = 20*log10(mag_G_vd);
mag_G_vd_filter_dB = 20*log10(mag_G_vd_filter);



%% ============================================================
% FIGURE 1: Z_D
% =============================================================

figure('Name','Bode Plot - Z_D','Color','w');

subplot(2,1,1)

semilogx(f,mag_D_dB,'LineWidth',1.8);

hold on;

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

grid on;

ylabel('Magnitude (dB)');
title('Bode Plot of Z_D(s)');

xlim([min(f) max(f)]);


subplot(2,1,2)

semilogx(f,phase_D,'LineWidth',1.8);

hold on;

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

grid on;

xlabel('Frequency (Hz)');
ylabel('Phase (deg)');

xlim([min(f) max(f)]);

%% ============================================================
% FIGURE 2: Z_N
% =============================================================

figure('Name','Bode Plot - Z_N','Color','w');

subplot(2,1,1)

semilogx(f,mag_N_dB,'LineWidth',1.8);

grid on;

ylabel('Magnitude (dB)');
title('Bode Plot of Z_N(s)');

xlim([min(f) max(f)]);


subplot(2,1,2)

semilogx(f,phase_N,'LineWidth',1.8);

grid on;

xlabel('Frequency (Hz)');
ylabel('Phase (deg)');

xlim([min(f) max(f)]);

%% ============================================================
% FIGURE 3: Z_O
% =============================================================

figure('Name','Bode Plot - Z_O','Color','w');

subplot(2,1,1)

semilogx(f,mag_O_dB,'LineWidth',1.8);

hold on;

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

grid on;

ylabel('Magnitude (dB)');
title('Bode Plot of Z_O(s)');

xlim([min(f) max(f)]);


subplot(2,1,2)

semilogx(f,phase_O,'LineWidth',1.8);

hold on;

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

grid on;

xlabel('Frequency (Hz)');
ylabel('Phase (deg)');

xlim([min(f) max(f)]);

%% ============================================================
% FIGURE 4: Ratio
% =============================================================

figure('Name','Bode Plot - Ratio','Color','w');

subplot(2,1,1)

semilogx(f,mag_H_dB,'LineWidth',1.8);

hold on;

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

yline(0,'--k','LineWidth',1);

grid on;

ylabel('Magnitude (dB)');
title('Bode Plot of H(s)');

xlim([min(f) max(f)]);


subplot(2,1,2)

semilogx(f,phase_H,'LineWidth',1.8);

hold on;

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

yline(0,'--k','LineWidth',1);

grid on;

xlabel('Frequency (Hz)');
ylabel('Phase (deg)');

xlim([min(f) max(f)]);

%% ============================================================
% FIGURE 5: Combined Bode Plots
% =============================================================

figure('Name','Combined Bode Plots','Color','w');

%% Magnitude

subplot(2,1,1)

semilogx(f,mag_D_dB,'LineWidth',1.5);
hold on;

semilogx(f,mag_N_dB,'LineWidth',1.5);

semilogx(f,mag_O_dB,'LineWidth',1.5);

semilogx(f,mag_H_dB,'LineWidth',1.8);

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

grid on;

ylabel('Magnitude (dB)');
title('Bode Magnitude Plot');

legend('Z_D','Z_N','Z_O','H(s)', ...
       'Location','best');

xlim([min(f) max(f)]);

%% Phase

subplot(2,1,2)

semilogx(f,phase_D,'LineWidth',1.5);
hold on;

semilogx(f,phase_N,'LineWidth',1.5);

semilogx(f,phase_O,'LineWidth',1.5);

semilogx(f,phase_H,'LineWidth',1.8);

xline(f_o,'--r', ...
    sprintf('f_o = %.2f Hz',f_o), ...
    'LineWidth',1.5);

grid on;

xlabel('Frequency (Hz)');
ylabel('Phase (deg)');

title('Bode Phase Plot');

legend('Z_D','Z_N','Z_O','H(s)', ...
       'Location','best');

xlim([min(f) max(f)]);

%% ============================================================
% FIGURE 5: Unfiltered and filterd system  
% =============================================================

figure('Name','Combined Bode Plots','Color','w');

%% Magnitude

subplot(2,1,1)

semilogx(f,mag_G_vd_dB,'LineWidth',1.5);
hold on;

semilogx(f,mag_G_vd_filter_dB,'LineWidth',1.5);
% 
% xline(f_o,'--r', ...
%     sprintf('f_o = %.2f Hz',f_o), ...
%     'LineWidth',1.5);

grid on;

ylabel('Magnitude (dB)');
title('Bode Magnitude Plot');

legend('Z_D','Z_N','Z_O','H(s)', ...
       'Location','best');

xlim([min(f) max(f)]);

%% Phase

subplot(2,1,2)

semilogx(f,phase_G_vd,'LineWidth',1.5);
hold on;

semilogx(f,phase_G_vd_filter,'LineWidth',1.5);

% xline(f_o,'--r', ...
%     sprintf('f_o = %.2f Hz',f_o), ...
%     'LineWidth',1.5);

grid on;

xlabel('Frequency (Hz)');
ylabel('Phase (deg)');

title('Bode Phase Plot');

legend('G_{vd}: without filter','G_{vd}: with filter', ...
       'Location','best');

xlim([min(f) max(f)]);

%% ============================================================
% Numerical Values
% =============================================================

fprintf('\n========================================\n');
fprintf('Important Numerical Values\n');
fprintf('========================================\n');

fprintf('|Z_N| = %.4f Ohm\n',abs(Z_N));
fprintf('Phase(Z_N) = 180 degrees\n');

fprintf('Resonant angular frequency = %.2f rad/s\n',w_o);
fprintf('Resonant frequency = %.2f Hz\n',f_o);

fprintf('========================================\n');
