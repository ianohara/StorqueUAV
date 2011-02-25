%%
clear all;
close all;

endTime = 40;
dt = 0.01;

time = 0;

% Define physical system parameters
mass = 5;          % [kg]
armLen = 0.382;    % [m]
Ixx = 0.2;         % [kg*m^2]
Iyy = 0.2;         % [kg*m^2]
Izz = 0.2;         % [kg*m^2]
g = 9.81;          % [m/s^2]


% Physical system gains
kM = 1;          % Gain for omega -> Moment [kg*m^2]
kT = 10;          % Gain for omega -> Thrust [kg*m]
kMot = 1;        % Gain on first order motor delay [1/s]

% Unneeded for now.
% % Create struture of physical parameters for passing to runSim()
 params = struct('mass',mass,'armLen',armLen,'Ixx',Ixx,'Iyy',Iyy,'Izz',Izz, ...
                 'g',g,'kM',kM,'kT',kT,'kMot',kMot);
            


u = [0 0 0 0 0 0];
motTrim0 = sqrt((mass*g)/(4*kT));
state0 = [1 1 1 0 0 0 0 0 0 0 0 0 motTrim0 motTrim0 motTrim0 motTrim0];

fprintf('Starting Sim...');
[states, steps, simTime] = runSim(state0, u, params, endTime, dt);
fprintf('Done!\n');
% I've run this thing 10 thousand times...entertainment.
fprintf('\tRan %d steps covering %2.1f [s] of simulation in %2.3f [s]\n', steps, time, simTime);


fig = figure(1);
zAx = plot3([0 0],[0 0], [0 1], 'k','LineWidth',3); % Plot the origin
hold on;
grid on;
yAx = plot3([0 0],[0 1], [0 0], 'k','LineWidth',3); % " "
xAx = plot3([0 1],[0 0], [0 0], 'k','LineWidth',3); % " "

set(zAx,'HandleVisibility','off');
set(yAx,'HandleVisibility','off');
set(xAx,'HandleVisibility','off');

set(gca,'ZDIR','Reverse');

xLab = xlabel('Distance from Start [m]','FontSize',14);
yLab = ylabel('Distance from Start [m]','FontSize',14);
zLab = zlabel('Distance from Start [m]','FontSize',14);


axis([0 2 0 2 0 2]);

for i = 1:size(states,2)
    drawStorque(fig, states(i,1:3), states(i,7:9));
    pause(0.02);
end


% NOTE FOR TESTS: All variables' suffixes should be the number of the test
% they belong to.  No underscore.

%% Test 1 - Hover
%
% At hover we want trim conditions.  This corresponds to everything = 0 
% except for the motor omegas which should be at their trim condition.
%

motTrim1 = sqrt((mass*g)/(4*kT));

state1 = zeros(1,16);
state1(13:16) = motTrim1;

u1 = zeros(1,6);

fprintf('Starting Test 1...');
[states1, steps1, simTime1] = runSim(state1, u1, params, endTime, dt);
fprintf('Done! (%2.2f [s])\n',simTime);
fprintf('\tSummary:\n');

test1Diff = testDiff(states1);

fprintf('\t  Least Sq Dist: %2.2g\n',test1Diff);

%% Test 2 - Sebastian's random ICs

state2 = zeros(1,16);
state2(7:8) = 0.6;
u2 = zeros(1,6);

fprintf('Starting Test 2...');
[states2, steps2, simTime2] = runSim(state2, u2, params, endTime, dt);
fprintf('Done! (%2.2f [s])\n',simTime2);
fprintf('\tSummary:\n');

test2Diff = testDiff(states2);

fprintf('\t  Least Sq Dist: %2.2g\n',test2Diff);

%% Test 3 - Roll from trim test
%  Give motor 1 twice trim, 2 nothing, and both 3 and 4 will have trim.
% This should result in a hard roll in the Positive Theta direction.

state3 = zeros(1,16);
state3(13) = 2*motTrim0;
state3(14) = 0;
state3(15:16) = motTrim0;

u3 = zeros(1,6);

fprintf('Starting Test 3...');
[states3, steps3, simTime3] = runSim(state3, u3, params, endTime, dt);
fprintf('Done! (%2.2f [s])\n',simTime3);
fprintf('\tSummary:\n');

test2Diff = testDiff(states2);

fprintf('\t  Theta is: %2.2f',state3(size(state3,1),8));