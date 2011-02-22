clear all;
close all;

endTime = 10;
dt = 0.01;

time = 0;



states = zeros(ceil(endTime/0.001),16);
step = 1;
states(1,:) = [1 1 1 0 0 0 0.2 0.3 0 0 0 4 0 0 0 0];
u = [0 0 0 0 0 0];
fprintf('Starting sim...');
while(time < endTime)
   time = time + dt;
   states(step+1,:) = rk4Step(states(step,:),u,@StorqueStep, dt);
   step = step + 1;
end
fprintf('Done!\n');


fig = figure(1);
zAx = plot3([0 0],[0 0], [0 1], 'k','LineWidth',3); % Plot the origin
hold on;
grid on;
yAx = plot3([0 0],[0 1], [0 0], 'k','LineWidth',3); % " "
xAx = plot3([0 1],[0 0], [0 0], 'k','LineWidth',3); % " "

set(zAx,'HandleVisibility','off');
set(yAx,'HandleVisibility','off');
set(xAx,'HandleVisibility','off');

xLab = xlabel('Distance from Start [m]','FontSize',14);
yLab = ylabel('Distance from Start [m]','FontSize',14);
zLab = zlabel('Distance from Start [m]','FontSize',14);

axis([0 2 0 2 0 2]);

for i = 1:size(states,2)
    drawStorque(fig, states(i,1:3), states(i,7:9));
    pause(2*dt);
end