close all;
clear all;

% Make sure that numerical integration of a first order with both
% my RungeKutta implementation and ode45 match each other.

steady = 10;

dsdt = @(s,u)(steady-s);
dsdt2 = @(t,s)(steady-s);

endTime = 20;
dt = 0.025;
times = 0:dt:endTime-dt;
states = zeros(1,floor(endTime/dt));
size(states);

[t,y] = ode45(dsdt2, [0 endTime], 0);
 
for i = 1:length(states)-1;
     states(1,i+1) = rk4Step(states(i), [0 0 0 0 0 0], dsdt, dt);
end

% Use the variable time steps used by ODE45 so we can compute
% the Euclidean distance between the two easily.
states2 = zeros(1,length(t));
states2(1) = 0;
for i = 2:length(t)
   states2(i) = rk4Step(states2(i-1), [0 0 0 0 0 0], dsdt, t(i)-t(i-1));
end

figure(1);

plot(times, states(:),'o');
hold on;
grid on;
plot(t,y,'r','LineWidth',2);
xlabel('Time [s]','FontSize',14);
ylabel('X(t)','FontSize',14);
title('Validity Check of Custom Runge Kutta Function','FontSize',14);

% Euclidean distance between the two resulting vectors
eucDistNum = sqrt(sum((states2(:)-y(:)).^2));

% Euclidean Distance between both my result and ODE45's result and the real thing
expFunc = @(t)(steady.*(1-exp(-t)));

eucDistActMe = sqrt(sum((states2(:)-expFunc(t)).^2));
eucDistActOde = sqrt(sum((y(:) - expFunc(t)).^2));

text(10,3.5, sprintf('Euclidean Dist Numerical: %2.3f\nEuclidean Dist Me Actual: %2.3f\nEuclidean Dist Ode45 Actual: %2.3f',eucDistNum, eucDistActMe,eucDistActOde));
text(10,5.5,sprintf('dx/dt = %2.2f - x',steady),'FontSize',14);