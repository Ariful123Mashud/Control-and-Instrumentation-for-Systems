%% ============================================================
% BUCK CONVERTER - PEAK CURRENT-MODE CONTROL (CPM) DESIGN
% Continuation of buck PD/PID voltage-mode script.
% Paste at the end of that script (reuses V_g, V, L, C, R, fs, H, s, f, w)
% or run standalone - all needed variables are redefined below.
% =============================================================

clear;
close all;
clc;

%% ============================================================
% STEADY-STATE VALUES (same converter as voltage-mode design)
% =============================================================

V_g = 28;
V   = 15;
V_ref = 5;
% fs  = 100e3;
% Ts  = 1/fs;

L = 50e-6;
C = 500e-6;
R = 3;
R_f = 0.2;
Vref = 5;
Vhys = 0.01;
Kp =80;
Ki  = 100;

