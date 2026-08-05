clear all;
close all;

G=0.5:0.1:1000;
mag_G=20*log10(G);

figure
plot(G,mag_G,'LineWidth',2);
title('mag\_G vs G\_dB')
grid on;
xlabel('mag\_G'); ylabel('20log10(mag\_G)')


%-------------------------------------------
f_o=1;
f=1:0.1:1000;
mag = log10(f./f_o);

figure
subplot(2,1,1)
plot(f./f_o,mag,'LineWidth',2);
title('f/f_o vs log10(f/f_o)')
grid on;
xlabel('f/f_o'); ylabel('log10(f/f_o)')

