%-------------------------------------------------------------------------
%                    Simulate StorqueUAV Hover
%       
%
%
%      A project by: Ian O'Hara, Uriah Baalke, Sebastian Mauchly,
%                    Alice Yurechko, and Emily Fisher
%
%      This code is a modified version of Daniel Mellinger's code
%      and uses his numerical integration routine.
%-------------------------------------------------------------------------


clear all;
close all;

x = zeros(12,1);
%Initial Conditions
x(1) = 0; %x
x(2) = 0; %y
x(3) = 0; %z
x(4) = 0.5; %xdot
x(5) = 0; %ydot
x(6) = 0; %zdot
x(7) = 0.8; %phi, roll
x(8) = 0.0; %theta, pitch
x(9) = 0.0; %psi, yaw
x(10) = 0; %p
x(11) = 0; %q
x(12) = 0; %r

endtime = 3.0;             % end of simulation in seconds
deltat = .0005;            % time step of numerical integration
n = round(endtime/deltat); % number of time steps
xsave = zeros(12,n);       % state history
time = zeros(1,n);         % time

tic;
for i= 1:n
    t = (i-1)*deltat; time(i) = t;
    xsave(:,i) = quadstep3d(x,t,deltat); %step by deltat
    x = xsave(:,i);
end
simTime = toc;

% step through the simulation while drawing the results in
% real (simulation) time [aka: Not real time, just as fast
% as your computer can compute timesteps]

% To help speed things up, only redraw every drawStep times
drawStep = 100;


% Set up our figure
figure(1);
plot3([0 0],[0 0], [0 1], 'k','LineWidth',3); % Plot the origin
hold on;
grid on;
plot3([0 0],[0 1], [0 0], 'k','LineWidth',3);
plot3([0 1],[0 0], [0 0], 'k','LineWidth',3);


pos = [x(1),x(2),x(3)]; % Holds our position for plotting
dirVec = eulerRotate([0,0,1]', x(7),x(8),x(9)); % Initial direction vector

plot3([pos(1) pos(1) + dirVec(1)], [pos(2) pos(2) + dirVec(2)], [pos(3) pos(3) + dirVec(3)], 'r', 'LineWidth',3);

iterDelay = round(simTime/n);

for i = 1:n
    if (mod(i,drawStep) == 0) 
        pos = [xsave(1,i),xsave(2,i),xsave(3,i)];
        dirVec = eulerRotate([0,0,1]', xsave(7,i),xsave(8,i),xsave(9,i));
        plot3([pos(1) pos(1) + dirVec(1)], [pos(2) pos(2) + dirVec(2)], [pos(3) pos(3) + dirVec(3)], 'r', 'LineWidth',3);
    end
    pause(iterDelay);
end
