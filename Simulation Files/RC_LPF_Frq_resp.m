clear all;
close all;
s=tf('s');
RC =1/(2*pi)
G_lpf=1/(1+s*RC);
%% ---------------- Bode Plot ----------------




%% ------------ Separate Magnitude & Phase ----------------
w = logspace(-2,3,1000);
f=w/(2*pi);

figure;

h = bodeplot(G_lpf,w);
grid on;
[mag,phase] = bode(G_lpf,w);
% Bode plot options
opt = getoptions(h);
opt.Grid = 'on';
opt.FreqUnits = 'Hz';
opt.MagUnits = 'dB';
opt.PhaseVisible = 'on';
setoptions(h,opt);

% Make all lines bold
set(findall(gcf,'Type','line'),'LineWidth',2.5);

set(findall(gcf,'Type','axes'),...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',1.5);

title('Single pole response or LPF','FontSize',16,'FontWeight','bold');


mag = squeeze(mag);
phase = squeeze(phase);

%% Magnitude Plot
% figure;
% semilogx(f,20*log10(mag),'b','LineWidth',3);
% grid on;
% xlabel('Frequency (Hz)','FontSize',14,'FontWeight','bold');
% ylabel('Magnitude (dB)','FontSize',14,'FontWeight','bold');
% title('Magnitude Response','FontSize',16,'FontWeight','bold');
% set(gca,'FontSize',13,'FontWeight','bold','LineWidth',1.5);
% 
% %% Phase Plot
% figure;
% semilogx(f,phase,'r','LineWidth',3);
% grid on;
% xlabel('Frequency (Hz)','FontSize',14,'FontWeight','bold');
% ylabel('Phase (deg)','FontSize',14,'FontWeight','bold');
% title('Phase Response','FontSize',16,'FontWeight','bold');
% set(gca,'FontSize',13,'FontWeight','bold','LineWidth',1.5);


%%%Single zero reponse
G_hpf=(1+s*RC);
w = logspace(-2,3,1000);
f=w/(2*pi);

figure;

h = bodeplot(G_hpf,w);
grid on;
% Bode plot options
opt = getoptions(h);
opt.Grid = 'on';
opt.FreqUnits = 'Hz';
opt.MagUnits = 'dB';
opt.PhaseVisible = 'on';
setoptions(h,opt);

% Make all lines bold
set(findall(gcf,'Type','line'),'LineWidth',2.5);

set(findall(gcf,'Type','axes'),...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',1.5);

title('Single zero response or HPF','FontSize',16,'FontWeight','bold');












