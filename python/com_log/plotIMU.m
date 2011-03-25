function success = plotIMU(log)
% Plot IMU data from data logging

close all;

imuTimeStep = 0.200;   % [s]

if (exist(log,'file') ~= 7)
    disp('File does not exist');
    success = 0;
    return;
end

data = csvread([log '/IMU.csv']);
dataRCI = csvread([log '/RCI.csv']);
dataPID = csvread([log '/PID.csv']);

success = data;

disp(sprintf('We have %d different IMU log lines.\n\tAnd each is %d data pieces.\n', size(data,1), size(data, 2)));
disp(sprintf('We have %d different RCI log lines.\n\tAnd each is %d data pieces.\n', size(dataRCI,1), size(dataRCI, 2)));
disp(sprintf('We have %d different PID log lines.\n\tAnd each is %d data pieces.\n', size(dataPID,1), size(dataPID, 2)));

% psi phi theta r p q zddot=15

psi = data(:,1);
phi = data(:,2);
theta = data(:,3);
r = data(:,4);
p = data(:,5);
q = data(:,6);

time = imuTimeStep:imuTimeStep:size(data,1)*imuTimeStep;

%rciChan0 = interp1(1:size(dataRCI,1), dataRCI(:,1), time);
%rciChan1 = interp1(1:size(dataRCI,1), dataRCI(:,2), time);
%rciChan2 = interp1(1:size(dataRCI,1), dataRCI(:,3), time);
%rciChan3 = interp1(1:size(dataRCI,1), dataRCI(:,4), time);

rciChan0 = dataRCI(:,1)';
rciChan1 = dataRCI(:,2)';
rciChan2 = dataRCI(:,3)';
rciChan3 = dataRCI(:,4)';

% So we can plot RCI input as percentages of max
rciRange = 2100-920;

rciTimeStep = max(time)/size(dataRCI,1);
rciTime = rciTimeStep:rciTimeStep:size(dataRCI,1)*rciTimeStep;

pidMot1 = dataPID(:,1);
pidMot2 = dataPID(:,2);
pidMot3 = dataPID(:,3);
pidMot4 = dataPID(:,4);

% So we can plot the duty cycle sent to the ESCs
pidMotTimer = 20000;

pidTimeStep = max(time)/size(dataPID,1);
pidTime = pidTimeStep:pidTimeStep:size(dataPID,1)*pidTimeStep;


figure(1);
subplot(3,1,1);
hold on;

plot(time, phi,'g.');
plot(time, theta, 'r.');
plot(time, psi, '.');

title('Euler Angles','FontSize',14);
xlabel('Time [s]','FontSize',13);
ylabel('Angle [deg]','FontSize',13);
legend('Phi','Theta','Psi','Location','SouthWest');
grid on;

subplot(3,1,2);
hold on;

plot(rciTime, rciChan0/rciRange,'.');
plot(rciTime, rciChan1/rciRange, 'r.');
plot(rciTime, rciChan2/rciRange, 'g.');
plot(rciTime, rciChan3/rciRange, 'm.');

title('Pilot Control Inputs','FontSize',14);
legend('Roll Com', 'Pitch Com', 'Collective Thrust Com', 'Yaw Com', 'Location', 'SouthWest');
xlabel('Time [s]','FontSize',13);
ylabel('% of Max Command','FontSize',13);
grid on;

subplot(3,1,3);
hold on;

plot(pidTime, pidMot1/pidMotTimer*100, '.');
plot(pidTime, pidMot2/pidMotTimer*100, '.r');
plot(pidTime, pidMot3/pidMotTimer*100, '.g');
plot(pidTime, pidMot4/pidMotTimer*100, '.m');
title('Duty Cycles Sent to Motor ESCs','FontSize',14);
legend('Mot 1','Mot 2','Mot 3','Mot 4','Location','SouthWest');
xlabel('Time [s]','FontSize',13);
ylabel('Duty Cycle To ESC [%]','FontSize',13);
grid on;

end

