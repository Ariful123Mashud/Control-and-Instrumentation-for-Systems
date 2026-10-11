%% HYSTERETIC COMPARATOR = TWO COMPARATORS + SR LATCH (Simulink test bench)
% Upper threshold : Vcmd + Vhys/2   -> comparator output drives R (reset)
% Lower threshold : Vcmd - Vhys/2   -> comparator output drives S (set)
% Latch output Q  = Vpwm  (1 = switch ON, 0 = switch OFF)
%   S = 1 when Vmod < Vcmd - Vhys/2   -> Q goes to 1
%   R = 1 when Vmod > Vcmd + Vhys/2   -> Q goes to 0
%   in between  -> Q holds its value (the hysteresis)
% The SR latch is built from basic blocks: Q(k+1) = S OR ( Q(k) AND NOT R )
% A Relay block is added alongside as a cross-check: both outputs must match.

clear; clc; bdclose all;

%% Parameters
Vcmd = 2;         % command voltage [V]
Vhys = 0.5;       % total hysteresis window [V]  (thresholds at +/- Vhys/2)

m = 'sr_hysteretic_comparator';
new_system(m); open_system(m);

addb = @(lib,name,x,y,varargin) add_block(lib,[m '/' name], ...
        'Position',[x y x+40 y+30],varargin{:});
ln = @(a,b) add_line(m,a,b,'autorouting','on');

%% Sources (test signals)
addb('simulink/Sources/Constant','Vcmd',30,40,'Value','Vcmd');
addb('simulink/Sources/Constant','Vhalf',30,120,'Value','Vhys/2');
% Vmod: sine around Vcmd that sweeps through both thresholds (stand-in for converter signal)
addb('simulink/Sources/Sine Wave','Vmod',30,200,'Amplitude','1','Bias','Vcmd', ...
     'Frequency','2*pi*50');

%% Threshold generation (the two summing junctions in the figure)
addb('simulink/Math Operations/Sum','UpSum',130,50,'Inputs','++');   % Vcmd + Vhys/2
addb('simulink/Math Operations/Sum','LoSum',130,120,'Inputs','+-');  % Vcmd - Vhys/2

%% The two comparators
addb('simulink/Logic and Bit Operations/Relational Operator','CompR',230,50,'Operator','>');  % Vmod > upper
addb('simulink/Logic and Bit Operations/Relational Operator','CompS',230,120,'Operator','<'); % Vmod < lower

%% SR latch from basic blocks: Q = S OR (Qprev AND NOT R)
addb('simulink/Logic and Bit Operations/Logical Operator','NotR',330,50,'Operator','NOT');
addb('simulink/Logic and Bit Operations/Logical Operator','AndG',410,60,'Operator','AND','Inputs','2');
addb('simulink/Logic and Bit Operations/Logical Operator','OrG',490,90,'Operator','OR','Inputs','2');
addb('simulink/Discrete/Memory','Mem',410,160,'InitialCondition','0');   % holds previous Q

%% Cross-check with the Relay block (input = Vcmd - Vmod)
addb('simulink/Math Operations/Sum','RelSum',330,260,'Inputs','+-');
addb('simulink/Discontinuities/Relay','RelayChk',420,260, ...
     'OnSwitchValue','Vhys/2','OffSwitchValue','-Vhys/2', ...
     'OnOutputValue','1','OffOutputValue','0');

%% Scope: 1 = [Vmod, upper, lower], 2 = Q (latch), 3 = Relay output
addb('simulink/Signal Routing/Mux','Mux3',330,200,'Inputs','3');
addb('simulink/Sinks/Scope','Scope',600,120,'NumInputPorts','3');

%% Wiring
ln('Vcmd/1','UpSum/1');   ln('Vcmd/1','LoSum/1');   ln('Vcmd/1','RelSum/1');
ln('Vhalf/1','UpSum/2');  ln('Vhalf/1','LoSum/2');
ln('Vmod/1','CompR/1');   ln('Vmod/1','CompS/1');   ln('Vmod/1','RelSum/2');
ln('Vmod/1','Mux3/1');
ln('UpSum/1','CompR/2');  ln('UpSum/1','Mux3/2');
ln('LoSum/1','CompS/2');  ln('LoSum/1','Mux3/3');

ln('CompR/1','NotR/1');                  % R signal inverted
ln('NotR/1','AndG/2');
ln('Mem/1','AndG/1');                    % previous Q
ln('AndG/1','OrG/2');
ln('CompS/1','OrG/1');                   % S signal
ln('OrG/1','Mem/1');                     % Q fed back through Memory

ln('RelSum/1','RelayChk/1');

ln('Mux3/1','Scope/1');
ln('OrG/1','Scope/2');
ln('RelayChk/1','Scope/3');

%% Solver
set_param(m,'Solver','ode45','StopTime','0.06','MaxStep','1e-4');
save_system(m);
sim(m);
open_system([m '/Scope']);