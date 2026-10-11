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
R_f = 1;             % Filter damping resistance (Ohm)   -- FIX: added missing semicolon
C_b = 4700e-6;
C_f = 370e-6;
L_f = 430e-6;



%% ============================================================
% Resonant Frequency
% =============================================================

w_o = 1/sqrt(L*C);              % rad/s
f_o = w_o/(2*pi);                % Hz

fprintf('\n========================================\n');
fprintf('Converter Parameters\n');
fprintf('========================================\n');

fprintf('Vg      = %.2f V\n', Vg);
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
% Impedances
% =============================================================

% ------------------------------------------------------------
% Z_D
%
% Z_D = (1/D^2) [sL + R/(1+sRC)]
% ------------------------------------------------------------

Z_D = (1/D^2) * (s*L + R/(1 + s*R*C));

% ------------------------------------------------------------
% Z_N
%
% Z_N = -R/D^2   (scalar, negative real -> phase = 180 deg)
% ------------------------------------------------------------

Z_N = -R/D^2;

% ------------------------------------------------------------
% Z_O_undamp  (source impedance seen by converter, no
%                  dedicated input filter installed)
%
% Z_O_undamp = sL || 1/(sC) = sL/(1+s^2LC)
% ------------------------------------------------------------

Z_O_undamp = (s*L_f)/(1 + s^2*L_f*C_f);

% % ------------------------------------------------------------
% % Z_O_damp (output impedance of the actual input filter:
% %                L_f in series with [C_f || (R_f + 1/(sC_b))] )
% % ------------------------------------------------------------
% 
% Z_Cf   = 1/(s*C_b);
% Z_RfCb = R_f + Z_Cf;
% Z_parallel = 1/(s*C_f+1/Z_RfCb);
% 
% Z_O_damp = 1/(1/(s*L_f)+1/Z_parallel);   % L_f || shunt branch

% Z_f1 = R_f+1/(s*C_b);
% Z_f11 = 1/(s*C_f+Z_f1);
% Z_O_damp = s*L_f*Z_f11;

%=====================================================
   % Bode plot of original filter Z_O
%=====================================================
Z_ori = 1/(s*C_f+1/(s*L_f));

%% ============================================================
% Extra-Element-Theorem Correction Ratio
%
% H(s) = (1 + Z_O/Z_N) / (1 + Z_O/Z_D)
% =============================================================

H_ratio_undamp = (1 + Z_O_undamp/Z_N) / (1 + Z_O_undamp/Z_D);
% H_ratio_damp = (1 + Z_O_damp/Z_N)   / (1 + Z_O_damp/Z_D);

%% ============================================================
% Converter Control-to-Output Transfer Function
%
% G_vd(s) = Vg / (1 + (L/R)s + LC s^2)          -- FIX: uses Vg, not D
% G_vd_filter(s) = G_vd(s) * H_ratio_filtered(s) -- FIX: no more overwrite
% =============================================================

G_vd        = Vg/(1 + (L/R)*s + s^2*L*C);
G_vd_undamp = G_vd * H_ratio_undamp;   
% G_vd_damp = G_vd * H_ratio_damp; 

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

disp('Z_O_undamp(s) = ');
Z_O_undamp

% disp('Z_O_damp(s) = ');
% Z_O_damp

disp('H(s)_undamp = ');
H_ratio_undamp

% disp('H(s)_damp = ');
% H_ratio_damp

%% ============================================================
% Frequency Range
% =============================================================

f = logspace(0,6,2000);      % Hz
w = 2*pi*f;                  % rad/s


%% ============================================================
% Z_ori
% =============================================================
[mag_ori,phase_ori] = bode(Z_ori,w);
mag_ori   = squeeze(mag_ori);
phase_ori = squeeze(phase_ori);
%% ============================================================
% Z_D Bode Data
% =============================================================
[mag_D,phase_D] = bode(Z_D,w);
mag_D   = squeeze(mag_D);
phase_D = squeeze(phase_D);

%% ============================================================
% Z_N Bode Data  (constant, so build vectors manually)
% =============================================================

mag_N = abs(Z_N) * ones(size(f));
phase_N = 180 * ones(size(f));       % negative real impedance -> +180 deg
mag_N_dB = 20*log10(mag_N);

%% ============================================================
% Z_O Bode Data (unfiltered and filtered)
% =============================================================

[mag_O_undamp,phase_O_undamp] = bode(Z_O_undamp,w);
mag_O_undamp   = squeeze(mag_O_undamp);
phase_O_undamp = squeeze(phase_O_undamp);
% 
% [mag_O_damp,phase_O_damp] = bode(Z_O_damp,w);
% mag_O_damp   = squeeze(mag_O_damp);
% phase_O_damp = squeeze(phase_O_damp);

%% ============================================================
% H Ratio Bode Data (unfiltered and filtered)          -- FIX
% =============================================================

[mag_H_undamp,phase_H_undamp] = bode(H_ratio_undamp,w);
mag_H_undamp   = squeeze(mag_H_undamp);
phase_H_undamp = squeeze(phase_H_undamp);

% [mag_H_damp,phase_H_damp] = bode(H_ratio_damp,w);
% mag_H_damp   = squeeze(mag_H_damp);
% phase_H_damp = squeeze(phase_H_damp);

%% ============================================================
% G_vd Bode Data (with and without filter)
% =============================================================

[mag_G_vd,phase_G_vd] = bode(G_vd,w);
mag_G_vd   = squeeze(mag_G_vd);
phase_G_vd = squeeze(phase_G_vd);

[mag_G_vd_undamp,phase_G_vd_undamp] = bode(G_vd_undamp,w);
mag_G_vd_undamp  = squeeze(mag_G_vd_undamp);
phase_G_vd_undamp = squeeze(phase_G_vd_undamp);

% [mag_G_vd_damp,phase_G_vd_damp] = bode(G_vd_damp,w);
% mag_G_vd_damp   = squeeze(mag_G_vd_damp);
% phase_G_vd_damp = squeeze(phase_G_vd_damp);

%% ============================================================
% Convert Magnitude to dB                              -- FIX
% =============================================================
mag_ori_dB = 20*log10(mag_ori)
mag_D_dB              = 20*log10(mag_D);
mag_O_undamp_dB   = 20*log10(mag_O_undamp);
% mag_O_damp_dB     = 20*log10(mag_O_damp);
mag_H_undamp_dB   = 20*log10(mag_H_undamp);
% mag_H_damp_dB     = 20*log10(mag_H_damp);
mag_G_vd_dB           = 20*log10(mag_G_vd);
mag_G_vd_undamp_dB    = 20*log10(mag_G_vd_undamp);
% mag_G_vd_damp_dB    = 20*log10(mag_G_vd_damp);



%% ============================================================
% FIGURE 1: Z_D
% =============================================================

figure('Name','Bode Plot - Impedences','Color','w');

% subplot(2,1,1)

semilogx(f,mag_D_dB,'LineWidth',1.8);
hold on;
semilogx(f,mag_N_dB,'LineWidth',1.8);
hold on
semilogx(f,mag_O_undamp_dB,'LineWidth',1.8);

xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
grid on;
ylabel('Magnitude (dB)');
title('Bode Plot of Impedances');
legend('Z_D: no input filter','Z_N: with input filter','Z_O: filter impedance','Location','best');

xlim([min(f) max(f)]);

% subplot(2,1,2)
% semilogx(f,phase_D,'LineWidth',1.8);
% hold on;
% semilogx(f,phase_N,'LineWidth',1.8);
% xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
% grid on;
% xlabel('Frequency (Hz)');
% ylabel('Phase (deg)');
% xlim([min(f) max(f)]);
% legend('Z_D: no input filter','Z_N: with input filter','Location','best');

% %% ============================================================
% % FIGURE 2: Z_N
% % =============================================================
% 
% figure('Name','Bode Plot - Z_N','Color','w');
% 
% subplot(2,1,1)
% semilogx(f,mag_N_dB,'LineWidth',1.8);
% grid on;
% ylabel('Magnitude (dB)');
% title('Bode Plot of Z_N(s)');
% xlim([min(f) max(f)]);
% 
% subplot(2,1,2)
% semilogx(f,phase_N,'LineWidth',1.8);
% grid on;
% xlabel('Frequency (Hz)');
% ylabel('Phase (deg)');
% xlim([min(f) max(f)]);

% %% ============================================================
% % FIGURE 3: Z_O (unfiltered vs filtered)                -- FIX: both shown
% % =============================================================
% 
% figure('Name','Bode Plot - Z_O','Color','w');
% 
% subplot(2,1,1)
% semilogx(f,mag_O_unfiltered_dB,'LineWidth',1.5);
% hold on;
% semilogx(f,mag_O_filtered_dB,'LineWidth',1.5);
% xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
% grid on;
% ylabel('Magnitude (dB)');
% title('Bode Plot of Z_O(s)');
% legend('Z_O: no input filter','Z_O: with input filter','Location','best');
% xlim([min(f) max(f)]);
% 
% subplot(2,1,2)
% semilogx(f,phase_O_unfiltered,'LineWidth',1.5);
% hold on;
% semilogx(f,phase_O_filtered,'LineWidth',1.5);
% xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
% grid on;
% xlabel('Frequency (Hz)');
% ylabel('Phase (deg)');
% legend('Z_O: no input filter','Z_O: with input filter','Location','best');
% xlim([min(f) max(f)]);

%% ============================================================
% FIGURE 4: H(s) Ratio (unfiltered vs filtered)         -- FIX: both shown
% =============================================================

figure('Name','Bode Plot - Ratio H(s)','Color','w');

subplot(2,1,1)
semilogx(f,mag_H_undamp_dB,'LineWidth',1.5);
hold on;
% semilogx(f,mag_H_damp_dB,'LineWidth',1.8);
xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
yline(0,'--k','LineWidth',1);
grid on;
ylabel('Magnitude (dB)');
title('Bode Plot of H(s)');
legend('H: input filter','H: with damped input filter','Location','best');
xlim([min(f) max(f)]);

subplot(2,1,2)
semilogx(f,phase_H_undamp,'LineWidth',1.5);
hold on;
% semilogx(f,phase_H_damp,'LineWidth',1.8);
xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
yline(0,'--k','LineWidth',1);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (deg)');
legend('H: with filter undamp','H: with filter damped','Location','best');
xlim([min(f) max(f)]);

% %% ============================================================
% % FIGURE 5: Combined Bode Plots (Z_D, Z_N, Z_O, H) -- filtered case
% % =============================================================
% 
% figure('Name','Combined Bode Plots - Impedances and H(s)','Color','w');
% 
% subplot(2,1,1)
% semilogx(f,mag_D_dB,'LineWidth',1.5);
% hold on;
% semilogx(f,mag_N_dB,'LineWidth',1.5);
% semilogx(f,mag_O_filtered_dB,'LineWidth',1.5);
% semilogx(f,mag_H_filtered_dB,'LineWidth',1.8);
% xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
% grid on;
% ylabel('Magnitude (dB)');
% title('Bode Magnitude Plot');
% legend('Z_D','Z_N','Z_O (with filter)','H(s) (with filter)','Location','best');
% xlim([min(f) max(f)]);
% 
% subplot(2,1,2)
% semilogx(f,phase_D,'LineWidth',1.5);
% hold on;
% semilogx(f,phase_N,'LineWidth',1.5);
% semilogx(f,phase_O_filtered,'LineWidth',1.5);
% semilogx(f,phase_H_filtered,'LineWidth',1.8);
% xline(f_o,'--r',sprintf('f_o = %.2f Hz',f_o),'LineWidth',1.5);
% grid on;
% xlabel('Frequency (Hz)');
% ylabel('Phase (deg)');
% title('Bode Phase Plot');
% legend('Z_D','Z_N','Z_O (with filter)','H(s) (with filter)','Location','best');
% xlim([min(f) max(f)]);

%% ============================================================
% FIGURE 6: G_vd -- With vs Without Input Filter        -- FIX: legend
% =============================================================

figure('Name','Gvd Comparison - With vs Without Input Filter','Color','w');

subplot(2,1,1)
semilogx(f,mag_G_vd_dB,'LineWidth',1.5);
hold on;
semilogx(f,mag_G_vd_undamp_dB,'LineWidth',1.5);
hold on;
% semilogx(f,mag_G_vd_damp_dB,'LineWidth',1.5);
grid on;
ylabel('Magnitude (dB)');
title('G_{vd} Magnitude: With vs Without Input Filter');
legend('G_{vd}: original','G_{vd}: with filter undamped','G_{vd}:with filter damped','Location','best');
xlim([min(f) max(f)]);

subplot(2,1,2)
semilogx(f,phase_G_vd,'LineWidth',1.5);
hold on;
semilogx(f,phase_G_vd_undamp,'LineWidth',1.5);
hold on;
% semilogx(f,phase_G_vd_damp,'LineWidth',1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (deg)');
title('G_{vd} Phase: With vs Without Input Filter');
% legend('G_{vd}: original','G_{vd}: with filter undamped','with filter damped','Location','best');
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