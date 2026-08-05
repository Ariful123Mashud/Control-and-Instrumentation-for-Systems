clc;
clear;
close all;

s = tf('s');

%% Gain values
K_values = [0.2 0.5 1 2];

colors = lines(length(K_values));

%% Figure for Closed-Loop Step Responses

figure('Color','w')
hold on
grid on
grid minor

title('Closed-Loop Step Responses',...
    'FontSize',18,...
    'FontWeight','bold')

xlabel('Time (s)',...
    'FontSize',16,...
    'FontWeight','bold')

ylabel('Output',...
    'FontSize',16,...
    'FontWeight','bold')

set(gca,...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)

%% Plot each response

for i = 1:length(K_values)

    K = K_values(i);

    % Open-loop transfer function
    G = K/(s*(s+1)^2);

    % Closed-loop transfer function
    T = feedback(G,1);

    % Step response
    [y,t] = step(T,50);

    plot(t,y,...
        'LineWidth',3,...
        'Color',colors(i,:));

end

legend("K="+string(K_values),...
    'Location','best',...
    'FontSize',12)

figure('Color','w')

%% Magnitude
subplot(2,1,1)
hold on
grid on
grid minor

%% Phase
subplot(2,1,2)
hold on
grid on
grid minor

for i = 1:length(K_values)

    K = K_values(i);

    G = K/(s*(s+1)^2);

    w = logspace(-2,0.2,1000);

    [mag,phase] = bode(G,w);

    mag = squeeze(20*log10(mag));
    phase = squeeze(phase);

    %% Magnitude
    subplot(2,1,1)
    semilogx(w,mag,...
        'LineWidth',3,...
        'Color',colors(i,:));

    %% Phase
    subplot(2,1,2)
    semilogx(w,phase,...
        'LineWidth',3,...
        'Color',colors(i,:));

end

%% ===============================
% Magnitude Formatting
%% ===============================
subplot(2,1,1)

yline(0,'k--','0 dB',...
    'LineWidth',2,...
    'FontWeight','bold');

ylabel('Magnitude (dB)',...
    'FontSize',16,...
    'FontWeight','bold')

title('Open-Loop Bode Plot',...
    'FontSize',18,...
    'FontWeight','bold')

legend("K="+string(K_values),...
    'Location','best')

%% ===============================
% Phase Formatting
%% ===============================
subplot(2,1,2)

yline(-180,'k--','-180^\circ',...
    'LineWidth',2,...
    'FontWeight','bold');

xlabel('Frequency (rad/s)',...
    'FontSize',16,...
    'FontWeight','bold')

ylabel('Phase (deg)',...
    'FontSize',16,...
    'FontWeight','bold')

legend("K="+string(K_values),...
    'Location','best')

%% ===============================
% Common Formatting
%% ===============================
set(findall(gcf,'Type','axes'),...
    'FontSize',14,...
    'FontWeight','bold',...
    'LineWidth',2)

fprintf('\n=============================================================\n');
fprintf('   K      GM(dB)    PM(deg)    Wgc(rad/s)    Wpc(rad/s)\n');
fprintf('=============================================================\n');

for i = 1:length(K_values)

    K = K_values(i);

    G = K/(s*(s+1)^2);

    % Stability margins
    [GM,PM,Wcg,Wcp] = margin(G);

    % Gain Margin in dB
    if isinf(GM)
        GM_dB = Inf;
    else
        GM_dB = 20*log10(GM);
    end

    fprintf('%6.2f   %8.2f   %8.2f   %12.4f   %12.4f\n',...
        K,GM_dB,PM,Wcp,Wcg);

end

fprintf('=============================================================\n');


%%%%%%%%%%%%%%%%%%%%%%%%
% s = tf('s');
% 
% K_values = linspace(0.2,10,40);
% f = logspace(-2,1,300);
% w = 2*pi*f;
% 
% Mag = zeros(length(K_values),length(f));
% 
% for i=1:length(K_values)
% 
%     G = K_values(i)/(s*(s+1)^2);
% 
%     [mag,~] = bode(G,w);
% 
%     Mag(i,:) = squeeze(20*log10(mag));
% 
% end
% 
% [F,K] = meshgrid(f,K_values);
% 
% figure
% surf(F,K,Mag)
% 
% set(gca,'XScale','log')
% 
% xlabel('Frequency (Hz)','FontWeight','bold')
% ylabel('Gain K','FontWeight','bold')
% zlabel('Magnitude (dB)','FontWeight','bold')
% 
% title('Open Loop Magnitude Surface')
% 
% shading interp
% grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = linspace(0,20,600);
% 
% Y = zeros(length(K_values),length(t));
% 
% for i=1:length(K_values)
% 
%     G = K_values(i)/(s*(s+1)^2);
% 
%     T = feedback(G,1);
% 
%     Y(i,:) = step(T,t);
% 
% end
% 
% [TIME,K] = meshgrid(t,K_values);
% 
% figure
% 
% surf(TIME,K,Y)
% 
% xlabel('Time (s)')
% ylabel('Gain K')
% zlabel('Output')
% 
% title('Closed Loop Step Response')
% 
% shading interp
% grid on