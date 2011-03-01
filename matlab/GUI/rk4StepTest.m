clear all;
close all;

endTime = 20;
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
kT = 1;          % Gain for omega -> Thrust [kg*m]
kMot = 1;        % Gain on first order motor delay [1/s]

% Unneeded for now.
% % Create struture of physical parameters for passing to runSim()
 params = struct('mass',mass,'armLen',armLen,'Ixx',Ixx,'Iyy',Iyy,'Izz',Izz, ...
                 'g',g,'kM',kM,'kT',kT,'kMot',kMot);
            


u = [0 0 0 0 0 0];
state0 = [1 1 1 0 0 0 0 0 0 0 0 0 8 0 3 5];

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
    pause(2*dt);
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
