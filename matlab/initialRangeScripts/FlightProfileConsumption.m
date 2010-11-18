%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%              Possible Cruise Distance and Time with
%                   different motor setups
%
%
%
%
% By: Ian O'Hara
% Date: 10/7/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

batPow = 5000;       % [mAhr]
numBat = 1;          % Number of batteries [-]

batMass = 0.403+0.071;  % mass of one battery + Thrust 20 motor [kg]
m = 5.71;               % mass of full plane [kg]

powerHov = 301;      % Power consumption at hover [W]
powerCruise = 87.3;  % Power consumption at cruise [W]
numMots = 4;
voltMots = 11.1;

velCruise = 18;      % Cruise speed at powerCruise
timeHov = 6*60;      % Time spent in hover [s]

energyTotal = numBat*voltMots*(batPow/1000)*3600;    % Energy in batteries [J]
energyHover = powerHov*timeHov*numMots;              % Energy used in hover [J]

energyForCruise = energyTotal-energyHover;           % Energy left for cruise [J]

cruiseTime = energyForCruise / powerCruise;        % Total cruise time [s]
cruiseDist = cruiseTime*velCruise;                 % Total cruisable distance [m]

display(sprintf('Using %d batteries (Wf = %f1) rated at %d mAhr we can cruise for:\n\t%f1 minutes\n and fly: \n\t%f1 km',numBat,(batMass*numBat)/m,batPow,cruiseTime/60,cruiseDist/1000));

