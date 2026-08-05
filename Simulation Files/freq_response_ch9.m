clc;
clear;
close all;

s = tf('s');

%% Parameters
D = 0.6;
R = 10;
V_g = 30;
L = 160e-6;
C = 160e-6;

D_dash = 1-D;

V = -D/D_dash*V_g;
I = -V/(D_dash*R);

fp2 = 20000;

wp2 = 2*pi*fp2;

V_M = 1;

%% Control-to-Output Transfer Function
G_vd = -((V_g-V)/D_dash)* ...
    ((1 - s*(L*I)/(D_dash*(V_g-V))) / ...
    (1 + s*(L/(D_dash^2*R)) + s^2*(L*C/(D_dash^2))));

G_c = (1+s/wp2);
H = 1;

T = H*G_c*G_vd/V_M

wp1 = D_dash/sqrt(L*C);                    % LC double pole (rad/s)
fp1 = wp1/(2*pi);

wz = D_dash*(V_g - V)/(L*I);               % RHP zero (rad/s)
% fz = wz/(2*pi);
% fprintf('LC Pole (fp1)      = %.2f Hz\n',fp1)
% fprintf('RHP Zero (fz)      = %.2f Hz\n',fz)
% fprintf('HF Pole (fp2)      = %.2f Hz\n',fp2)
%% ===============================
% Bold Publication Quality Bode Plot
% ================================

% Frequency range (10 Hz to 1 MHz)
f = logspace(1,6,3000);
w = 2*pi*f;

% Frequency response
[mag,phase] = bode(T,w);

mag = squeeze(20*log10(mag));
phase = squeeze(phase);

figure('Color','w','Position',[100 100 900 700])




%% Magnitude
subplot(2,1,1)

semilogx(f,mag,'k','LineWidth',3)

grid on
grid minor

ylabel('Magnitude (dB)',...
    'FontSize',16,...
    'FontWeight','bold')

title('T(s)--Open loop TF',...
    'FontSize',18,...
    'FontWeight','bold')

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)

xlim([10 1e6])

%% Phase
subplot(2,1,2)

semilogx(f,phase,'b','LineWidth',3)

grid on
grid minor

xlabel('Frequency (Hz)',...
    'FontSize',16,...
    'FontWeight','bold')

ylabel('Phase (deg)',...
    'FontSize',16,...
    'FontWeight','bold')

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)
hold on

% xline(fp1,'--r','f_{p1}',...
%     'LineWidth',2,...
%     'FontSize',12,...
%     'FontWeight','bold');
% 
% xline(fz,'--m','f_{z}',...
%     'LineWidth',2,...
%     'FontSize',12,...
%     'FontWeight','bold');
% 
% xline(fp2,'--g','f_{p2}',...
%     'LineWidth',2,...
%     'FontSize',12,...
%     'FontWeight','bold');

xlim([10 1e6])

%% ==========================================
% Bode Plot of Sensitivity Function S(s)
% ==========================================

S = 1/(1+T);
% Frequency response
[magS,phaseS] = bode(S,w);

magS = squeeze(20*log10(magS));
phaseS = squeeze(phaseS);

figure('Color','w','Position',[120 120 900 700])

%% Magnitude
subplot(2,1,1)

semilogx(f,magS,'r','LineWidth',3)

grid on
grid minor

ylabel('Magnitude (dB)',...
    'FontSize',16,...
    'FontWeight','bold')

title('Sensitivity Function, S(s)=1/(1+T(s))',...
    'FontSize',18,...
    'FontWeight','bold')

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)

xlim([10 1e6])

% hold on
% xline(fp1,'--k','f_{p1}','LineWidth',2);
% xline(fz,'--m','f_{z}','LineWidth',2);
% xline(fp2,'--g','f_{p2}','LineWidth',2);

%% Phase
subplot(2,1,2)

semilogx(f,phaseS,'b','LineWidth',3)

grid on
grid minor

xlabel('Frequency (Hz)',...
    'FontSize',16,...
    'FontWeight','bold')

ylabel('Phase (deg)',...
    'FontSize',16,...
    'FontWeight','bold')

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)

xlim([10 1e6])

% hold on
% xline(fp1,'--k','f_{p1}','LineWidth',2);
% xline(fz,'--m','f_{z}','LineWidth',2);
% xline(fp2,'--g','f_{p2}','LineWidth',2);


%% ==========================================
% Bode Plot of Complementary Sensitivity Function
% Tc(s) = T(s)/(1+T(s))
% ==========================================
Tc = T/(1+T)
[magTc,phaseTc] = bode(Tc,w);

magTc = squeeze(20*log10(magTc));
phaseTc = squeeze(phaseTc);

figure('Color','w','Position',[140 140 900 700])

%% Magnitude
subplot(2,1,1)

semilogx(f,magTc,'m','LineWidth',3)

grid on
grid minor

ylabel('Magnitude (dB)',...
    'FontSize',16,...
    'FontWeight','bold')

title('Closed loop TF: T(s)/(1+T(s))',...
    'FontSize',18,...
    'FontWeight','bold')

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)

xlim([10 1e6])

% hold on
% xline(fp1,'--k','f_{p1}','LineWidth',2);
% xline(fz,'--r','f_{z}','LineWidth',2);
% xline(fp2,'--g','f_{p2}','LineWidth',2);

%% Phase
subplot(2,1,2)

semilogx(f,phaseTc,'b','LineWidth',3)

grid on
grid minor

xlabel('Frequency (Hz)',...
    'FontSize',16,...
    'FontWeight','bold')

ylabel('Phase (deg)',...
    'FontSize',16,...
    'FontWeight','bold')

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)

xlim([10 1e6])

% hold on
% xline(fp1,'--k','f_{p1}','LineWidth',2);
% xline(fz,'--r','f_{z}','LineWidth',2);
% xline(fp2,'--g','f_{p2}','LineWidth',2);