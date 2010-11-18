% This code was orriginally written by Daniel Mellinger.

%this is script to run the quadrotor simulator

clear all
close all

x = zeros(12,1);
%Initial Conditions
x(1) = 0; %x
x(2) = 0; %y
x(3) = 0; %z
x(4) = 0; %xdot
x(5) = 0; %ydot
x(6) = 0; %zdot
x(7) = 0.0; %phi, roll
x(8) = 0.0; %theta, pitch
x(9) = 0.0; %psi, yaw
x(10) = 0; %p
x(11) = 0; %q
x(12) = 0; %r

endtime = 3.0; %end of simulation in seconds
deltat = .0005; %time step of numerical integration
n = round(endtime/deltat); %number of time steps
xsave = zeros(12,n); %state history
time = zeros(1,n); %time

%step through the simulation
for i= 1:n
    t = (i-1)*deltat; time(i) = t;
    xsave(:,i) = quadstep3d(x,t,deltat); %step by deltat
    x = xsave(:,i);
end


%now plot some stuff
figure(1)
subplot(311)
hold on
plot(time,xsave(1,:),'r.')
ylabel('x position')
subplot(312)
hold on
plot(time,xsave(2,:),'g.')
ylabel('y position')
subplot(313)
hold on
plot(time,xsave(3,:),'b.')
ylabel('z position')

figure(2)
subplot(311)
hold on
plot(time,xsave(4,:),'r.')
ylabel('x velocity')
subplot(312)
hold on
plot(time,xsave(5,:),'g.')
ylabel('y velocity')
subplot(313)
hold on
plot(time,xsave(6,:),'b.')
ylabel('z velocity')

figure(3)
subplot(311)
hold on
plot(time,xsave(7,:),'r.')
ylabel('roll')
subplot(312)
hold on
plot(time,xsave(8,:),'g.')
ylabel('pitch')
subplot(313)
hold on
plot(time,xsave(9,:),'b.')
ylabel('yaw')