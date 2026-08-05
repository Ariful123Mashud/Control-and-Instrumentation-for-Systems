clc;
clear;
close all;

%% Parameters
fs = 100e3;              % Switching frequency
Ts = 1/fs;

fc = fs/10;                % Control signal frequency
Vm = 2;                  % Ramp peak voltage

dt = Ts/500;             % Simulation time step
t = 0:dt:2e-3;           % 2 ms simulation

%% Continuous controller output
vc = 1 + 0.5*sin(2*pi*fc*t);

%% Sawtooth carrier
carrier = mod(t,Ts)/Ts*Vm;

%% PWM generation
gate = vc > carrier;

%% Duty cycle sampled every switching period
ts = 0:Ts:2e-3;
vc_sample = 1 + 0.5*sin(2*pi*fc*ts);
duty = vc_sample/Vm;

%% Plot
figure('Position',[100 100 1000 700])

subplot(3,1,1)
plot(t,vc,'b','LineWidth',2)
hold on
plot(t,carrier,'r')
ylabel('Voltage (V)')
title('Control Voltage and Sawtooth Carrier')
legend('v_c(t)','Carrier')
grid on

subplot(3,1,2)
stairs(ts,duty,'LineWidth',2)
ylim([0 1])
ylabel('Duty Cycle')
title('Duty Cycle (Updated Every Switching Period)')
grid on

subplot(3,1,3)
plot(t,gate,'k','LineWidth',1.5)
ylim([-0.2 1.2])
xlabel('Time (s)')
ylabel('Gate')
title('MOSFET ON/OFF Switching Signal')
grid on