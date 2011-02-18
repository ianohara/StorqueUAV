close all;
clear all;

prop = 'MA0970TP\';

Fx = csvread([prop, 'MA0970TP_Fx']);
Fy = csvread([prop, 'MA0970TP_Fy']);
Fz = csvread([prop, 'MA0970TP_Fz']);

Mx = csvread([prop, 'MA0970TP_Tx']);
My = csvread([prop, 'MA0970TP_Ty']);
Mz = csvread([prop, 'MA0970TP_Tz']);

RPM = csvread([prop, 'MA0970TP_w']);

CAN_time = csvread([prop, 'MA0970TP_t_w']);

time = 1:3000;

figure(1);
title('Turnigy Motor with Master Airscrew 9x7 Tri-Blade');
subplot(2,2,1);
plot(CAN_time(:,1),RPM(:,1),'o');
hold on;
grid on;

plot(CAN_time(:,2),RPM(:,2),'ro');
plot(CAN_time(:,3),RPM(:,3),'ko');
plot(CAN_time(:,4),RPM(:,4),'go');

title('RPM');
xlabel('Time [s]')
ylabel('RPM');

subplot(2,2,2);
plot(time, Mz(:,1), '.');
hold on;
grid on;
plot(time, Mz(:,2), 'r.');
plot(time, Mz(:,3), 'k.');

ylabel('Moment [mN*m]');
xlabel('Time [s]');
title('Z-Axis Torque');
plot(time, Mz(:,4), 'g.');

subplot(2,2,3:4);
plot(time, Fz(:,1), '.');
hold on;
grid on;
plot(time, Fz(:,2), 'r.');
plot(time, Fz(:,3), 'k.');

ylabel('Force [N]');
xlabel('Time [s]');
title('Z-Axis (Axial)');
plot(time, Fz(:,4), 'g.');