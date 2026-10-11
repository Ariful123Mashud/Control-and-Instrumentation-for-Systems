%% ============================================================
% FFT Analysis of Grid Current
% Comparison: Unfiltered vs Filtered
% =============================================================

% clear;
% clc;
% close all;

%% ============================================================
% Load simulation data
% =============================================================

% load('i_g_current_A01.mat');

%% ============================================================
% Extract grid currents and time
% =============================================================

i_g_unfiltered = out.i_g_unfiltered;

t_out = out.tout;

% Convert to column vectors
i_g_unfiltered = i_g_unfiltered(:);
t_out          = t_out(:);

%% ============================================================
% Sampling Parameters
% =============================================================

Fs = 1 / mean(diff(t_out));      % Sampling frequency
N  = length(t_out);              % Number of samples

fprintf('Sampling frequency = %.2f Hz\n', Fs);
fprintf('Number of samples  = %d\n', N);

%% ============================================================
% Remove DC Component
% =============================================================

i_g_unfiltered_ac = i_g_unfiltered - mean(i_g_unfiltered);


%% ============================================================
% FFT - UNFILTERED CURRENT
% =============================================================

Y_unfiltered = fft(i_g_unfiltered_ac);

P2_unfiltered = abs(Y_unfiltered/N);

P1_unfiltered = P2_unfiltered(1:floor(N/2)+1);

P1_unfiltered(2:end-1) = ...
    2*P1_unfiltered(2:end-1);

%% ============================================================
% Frequency Axis
% =============================================================

f = Fs*(0:floor(N/2))/N;



%% FFT of i_g — Unfiltered (top) vs Filtered (bottom), two subplots

figure('Color','w');

% --- Subplot 1: Unfiltered ---
subplot(2,1,1)
plot(f, P1_unfiltered, 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)', 'FontWeight','bold');
ylabel('Magnitude (A)', 'FontWeight','bold');
title('FFT Spectrum of Unfiltered Grid Current i_g', 'FontWeight','bold');
xlim([0 50e3]);
set(gca, 'FontSize',12, 'FontWeight','bold');

