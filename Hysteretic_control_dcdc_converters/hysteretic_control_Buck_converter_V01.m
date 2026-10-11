%% ============================================================
% Z_D, Z_N, Z_O and Ratio Bode Plots  (corrected)
% =============================================================

clear;
clc;
close all;

s = tf('s');

%% ============================================================
% Converter Parameters
% =============================================================

Vg = 30;            % Input voltage (V)   -- FIX: was missing, needed for G_vd
D  = 0.5;            % Duty ratio
% L  = 100e-6;         % Inductance (H)
% C  = 100e-6;
L  = 100e-6;         % Inductance (H)
C  = 100e-6;         % Capacitance (F)
R  = 3;              % Load resistance (Ohm)
fprintf('========================================\n');