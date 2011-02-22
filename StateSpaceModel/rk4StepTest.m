clear all;
close all;

endTime = 20;
dt = 0.01;

time = 0;

% Define physical system parameters
mass = 5;        % [kg]
armLen = 0.382;  % [m]
Ixx = 0.2;         % [kg*m^2]
Iyy = 0.2;         % [kg*m^2]
Izz = 0.2;         % [kg*m^2]
g = 9.81;        % [m/s^2]


% Physical system gains
kM = 1;          % Gain for omega -> Moment [kg*m^2]
kT = 1;          % Gain for omega -> Thrust [kg*m]
kMot = 1;        % Gain on first order motor delay [1/s]


% Preallocate our large state matrix.  We want to keep track of the
% state at each timestep for later plotting.
states = zeros(ceil(endTime/0.001),16);
step = 1;

% Define the initial conditions
states(step,:) = [1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0];

% Initial control conditions.  Without joystick implementation of some sort
% this doesn't make much sense when not 0.
u = [0 0 0 0 0 0];

fprintf('Starting sim...');
tic;
while(time < endTime)
   time = time + dt;
   states(step+1,:) = rk4Step(states(step,:),u,@StorqueStep, dt);
   step = step + 1;
end
simTime = toc;
fprintf('Done!\n');
% I've run this thing 10 thousand times...entertainment.
fprintf('\tRan %d steps covering %2.1f [s] of simulation in %2.3f [s]\n', step, time, simTime);


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