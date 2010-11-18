%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Create Thrust and Power Required versus Velocity
%       Plot via method in Anderson, Intro to Flight
%
%   By: Ian O'Hara
%   Date: 10/7/2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Needed Information
m = 5.71;     % Mass [kg]
b = 2;     % Wing span [m]
c = 0.33;   % Average chord [m]
e = 0.7;    % Oswald efficiency factor
S = 2*0.25; % Reference wing area (m^2)
rho = 1.18; % Density of air (kg/m^3)
Cdo = 0.025; % Profile drag of aircraft
g = 9.81;   % Gravitational acceleration (m/s^2)

% Velocity Range
V = 1:50;   % [m/s]

% Values calculated from needed info (Don't modify!)
W = m*g;
AR = b^2 / (c*b);
%% Thrust Required
thrustR = [];     % Thrust required for each V [N];

Cl = W./(0.5*rho.*V.^2*S);
Cd = Cdo + Cl.^2./(pi*e*AR);

thrustR = W ./ (Cl./Cd);

% Plot resuts
figure;
close all;
grid on;
hold on;

plot(V,thrustR,'o','MarkerFaceColor','b','MarkerSize',10);

title({'Thrust Required Curve', '(with conservatively estimated values)'},'FontSize',14);
xlabel('V_i_n_f [m/s]','FontSize',14);
ylabel('Thrust required [N]','FontSize',14);
axis([0 50 0 60]);

%% Power Required %%
powerR = thrustR .* V;

figure;

grid on;
hold on;

plot(V,powerR,'o','MarkerFaceColor','b','MarkerSize',10);

title({'Power Required Curve', '(with conservatively estimated values)'},'FontSize',14);
xlabel('V_i_n_f [m/s]','FontSize',14);
ylabel('Power required [W]','FontSize',14);
axis([0 50 0 1000]);