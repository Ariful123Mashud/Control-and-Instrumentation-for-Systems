clc;
clear;
close all;

Q = [0.2 0.5 0.8 2 4 8];

s = tf('s');
w0 = 1;                 % rad/s

% Frequency vector
w = logspace(-1,1,1000);

figure;
hold on;

for k = 1:length(Q)

    G_sec = 1/(1 + s/(Q(k)*w0) + (s/w0)^2);

    bodeplot(G_sec,w);

end

grid on;

% Make lines bold
set(findall(gcf,'Type','line'),'LineWidth',2.5);

% Make axes bold
set(findall(gcf,'Type','axes'),...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',1.5);

% Legend
legend('Q = 0.2','Q = 0.5','Q = 0.8','Q = 2',...
    'Location','southwest');

% Overall title
sgtitle('Bode Plot of Second-Order System for Different Q Values',...
    'FontSize',18,'FontWeight','bold');


%%--------------------------------------


Q = [0.2 0.5 0.8 2];

s = tf('s');
w0 = 1;

figure;
hold on;
grid on;

for k = 1:length(Q)

    G_sec = 1/(1 + s/(Q(k)*w0) + (s/w0)^2);

    step(G_sec);

end

% Formatting
set(findall(gcf,'Type','line'),'LineWidth',2.5);

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',1.5);

xlabel('Time (s)','FontSize',14,'FontWeight','bold');
ylabel('Amplitude','FontSize',14,'FontWeight','bold');
title('Step Responses for Different Q Values',...
      'FontSize',18,'FontWeight','bold');

legend('Q = 0.2','Q = 0.5','Q = 0.8','Q = 2',...
       'Location','best');