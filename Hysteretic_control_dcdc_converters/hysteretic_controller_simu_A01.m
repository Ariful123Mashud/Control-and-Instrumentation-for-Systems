%% BUILD THE HYSTERETIC-COMPARATOR CONTROL LOOP IN SIMULINK
% Reproduces the block diagram: error amplifier -> hysteretic comparator
% -> power converter, with Vmod fed back from the converter.
% Power converter = ideal buck (built from basic blocks, no toolbox needed).
%   Vmod = Rs * iL  (inductor-current sensing), vo fed back to error amp.

clear; clc; bdclose all;

%% Parameters (live in base workspace, used by the block dialogs)
Vin  = 12;        % input voltage [V]
L    = 100e-6;    % inductance [H]
C    = 100e-6;    % capacitance [F]
R    = 5;         % load resistance [ohm]
Vref = 5;         % output voltage reference [V]
Rs   = 1;         % current sense gain [V/A]  -> Vmod = Rs*iL
Kp   = 1;         % error amplifier (PI) proportional gain
Ki   = 1000;      % error amplifier (PI) integral gain
Vhys = 0.2;       % total hysteresis window [V]  (+/- Vhys/2)

m = 'hysteretic_buck';
new_system(m); open_system(m);

%% Helper to place blocks
addb = @(lib,name,x,y,varargin) add_block(lib,[m '/' name], ...
        'Position',[x y x+40 y+30],varargin{:});

%% ---- Error amplifier (PI) ----
addb('simulink/Sources/Constant','Vref',30,40,'Value','Vref');
addb('simulink/Math Operations/Sum','ErrSum',120,50,'Inputs','+-');
addb('simulink/Math Operations/Gain','Gain_Kp',200,20,'Gain','Kp');
addb('simulink/Math Operations/Gain','Gain_Ki',200,90,'Gain','Ki');
addb('simulink/Continuous/Integrator','Int_err',270,90);
addb('simulink/Math Operations/Sum','PIsum',350,50,'Inputs','++');   % output = Vcmd

%% ---- Hysteretic comparator ----
addb('simulink/Math Operations/Sum','CmpSum',440,50,'Inputs','+-');  % Vcmd - Vmod
addb('simulink/Discontinuities/Relay','HystComp',520,50, ...
     'OnSwitchValue','Vhys/2','OffSwitchValue','-Vhys/2', ...
     'OnOutputValue','1','OffOutputValue','0');                      % output = Vpwm (0/1)

%% ---- Power converter (ideal buck) ----
addb('simulink/Sources/Constant','Vin',520,130,'Value','Vin');
addb('simulink/Math Operations/Product','Vsw',600,80);               % switch-node voltage
addb('simulink/Math Operations/Sum','LSum',680,80,'Inputs','+-');    % Vsw - vo
addb('simulink/Math Operations/Gain','Gain_invL',750,80,'Gain','1/L');
addb('simulink/Continuous/Integrator','Int_iL',820,80);              % iL
addb('simulink/Math Operations/Sum','CSum',900,80,'Inputs','+-');    % iL - vo/R
addb('simulink/Math Operations/Gain','Gain_invC',970,80,'Gain','1/C');
addb('simulink/Continuous/Integrator','Int_vo',1040,80);             % vo
addb('simulink/Math Operations/Gain','Gain_invR',900,170,'Gain','1/R');

%% ---- Current sensing: Vmod ----
addb('simulink/Math Operations/Gain','Gain_Rs',760,170,'Gain','Rs');

%% ---- Scopes ----
addb('simulink/Signal Routing/Mux','Mux_cmd',1100,180,'Inputs','2');
addb('simulink/Sinks/Scope','Scope',1180,120,'NumInputPorts','3');

%% ---- Wiring ----
ln = @(a,b) add_line(m,a,b,'autorouting','on');

% Error amplifier
ln('Vref/1','ErrSum/1');
ln('Int_vo/1','ErrSum/2');              % vo fed back (dashed path in the figure)
ln('ErrSum/1','Gain_Kp/1');
ln('ErrSum/1','Gain_Ki/1');
ln('Gain_Ki/1','Int_err/1');
ln('Gain_Kp/1','PIsum/1');
ln('Int_err/1','PIsum/2');              % PIsum/1 output = Vcmd

% Comparator
ln('PIsum/1','CmpSum/1');               % Vcmd on + input
ln('Gain_Rs/1','CmpSum/2');             % Vmod on - input
ln('CmpSum/1','HystComp/1');

% Converter
ln('HystComp/1','Vsw/1');
ln('Vin/1','Vsw/2');
ln('Vsw/1','LSum/1');
ln('Int_vo/1','LSum/2');
ln('LSum/1','Gain_invL/1');
ln('Gain_invL/1','Int_iL/1');
ln('Int_iL/1','CSum/1');
ln('Int_vo/1','Gain_invR/1');
ln('Gain_invR/1','CSum/2');
ln('CSum/1','Gain_invC/1');
ln('Gain_invC/1','Int_vo/1');

% Sensing
ln('Int_iL/1','Gain_Rs/1');

% Scope: 1 = [Vcmd Vmod], 2 = vo, 3 = Vpwm
ln('PIsum/1','Mux_cmd/1');
ln('Gain_Rs/1','Mux_cmd/2');
ln('Mux_cmd/1','Scope/1');
ln('Int_vo/1','Scope/2');
ln('HystComp/1','Scope/3');

%% ---- Solver settings ----
set_param(m,'Solver','ode23tb','StopTime','5e-3','MaxStep','1e-6');

save_system(m);
sim(m);
open_system([m '/Scope']);