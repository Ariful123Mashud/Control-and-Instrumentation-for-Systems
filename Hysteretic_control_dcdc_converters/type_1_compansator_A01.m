clc;
clear;
close all;

%% Parameters
f_c = 1e3;                 % Crossover frequency (Hz)
C = 10e-6;                % Capacitance (F)
R = 1/(2*pi*f_c*C);       % Resistance (Ohm)

fprintf('R = %.4f Ohm\n', R);

%% Transfer Function
s = tf('s');
H = -1/(s*R*C);

%% Frequency range
f = logspace(-1, 4, 1000);       % Hz
w = 2*pi*f;                      % rad/s

%% Frequency response
[mag, phase] = bode(H, w);

mag = squeeze(mag);
phase = squeeze(phase);

Mag_dB = 20*log10(mag);
Phase_deg = phase;

%% =========================================================
%  Publication-quality TWO-COLUMN figure
%  Full width: approximately 7.0 inches
% ==========================================================

fig = figure('Units','inches', ...
             'Position',[1 1 7.0 3.8], ...
             'Color','w');

t = tiledlayout(2,1, ...
                'TileSpacing','compact', ...
                'Padding','compact');

%% Magnitude
ax1 = nexttile;

semilogx(f, Mag_dB, ...
         'LineWidth',1.5);

grid on;
box on;

ylabel('Magnitude (dB)', ...
       'FontName','Times New Roman', ...
       'FontSize',10);

title('Type-1 Compensator', ...
      'FontName','Times New Roman', ...
      'FontSize',10, ...
      'FontWeight','normal');

xlim([0.1 1e4]);

% 0 dB reference
hold on;
yline(0,'--','LineWidth',0.8);

% Gain crossover frequency
xline(f_c,'--','LineWidth',0.8);
hold off;

%% Phase
ax2 = nexttile;

semilogx(f, Phase_deg, ...
         'LineWidth',1.5);

grid on;
box on;

xlabel('Frequency (Hz)', ...
       'FontName','Times New Roman', ...
       'FontSize',10);

ylabel('Phase (deg)', ...
       'FontName','Times New Roman', ...
       'FontSize',10);

xlim([0.1 1e4]);
ylim([80 100]);

%% Formatting
set([ax1 ax2], ...
    'FontName','Times New Roman', ...
    'FontSize',9, ...
    'LineWidth',0.8, ...
    'TickDir','out');

%% Export as vector PDF
exportgraphics(fig, ...
    'Type1_Compensator_Bode_TwoColumn.pdf', ...
    'ContentType','vector');