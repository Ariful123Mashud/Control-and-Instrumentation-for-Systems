clear all;
close all;
s=tf('s');
f1=100;
f2=1000;
w1=2*pi*f1;
w2=2*pi*f2;
G_o=40;
G_comb=G_o/((1+s/w1)*(1+s/w2));

% Frequency vector (rad/s)
w = logspace(1,5,1000);

%% Bode Plot
figure;

h = bodeplot(G_comb,w);
grid on;

% Bode options
opt = getoptions(h);
opt.Grid = 'on';
opt.FreqUnits = 'Hz';      % Display frequency in Hz
opt.MagUnits = 'dB';
opt.PhaseVisible = 'on';
setoptions(h,opt);

% Make all lines bold
set(findall(gcf,'Type','line'),'LineWidth',2.5);

set(findall(gcf,'Type','axes'),...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',1.5);

title('Bode plot of combination','FontSize',16,'FontWeight','bold');