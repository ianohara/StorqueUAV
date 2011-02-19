function [sdot] = StorqueStep(s,u)
% s = state vector (16x1)
% sdot = derivative of state at current time
% u = control input (6x1)

% u = [xd_com yd_com zd_com phi_com theta_com psi_com]
% Where com = 'commanded'
xd_com = u(1);
yd_com = u(2);
zd_com = u(3);



% Define physical system parameters
mass = 5;   % [kg]
armLen = 0.382;  % [m]
Ixx = 1;    % [kg*m^2]
Iyy = 1;    % [kg*m^2]
Izz = 1;    % [kg*m^2]
g = 9.81;

% Define all of the system variables

x = s(1);   % World Position x [m]
y = s(2);   % World position y [m]
z = s(3);   % World position z [m]

u = s(4);   % Body frame velocity x [m/s]
v = s(5);   % Body frame velocity y [m/s] 
w = s(6);   % Body frame velocity z [m/s]

% Euler angles.  The names are slightly wrong
% because really only psi is on z, while phi and theta are on
% the transformed versions of themselves. (X' and Y'')
phi = s(7);    % Euler Angle on body axis x
theta = s(8);  % Euler angle on body axis y 
psi = s(9);    % Euler Angle on body axis z


p = s(10);  % Angular rate around body axis x
q = s(11);  % Angular rate around body axis y
r = s(12);  % Angular rate around body axis z

% Angular rates of props 1-4
w1 = s(13);   % [rad/s]
w2 = s(14);   % [rad/s]
w3 = s(15);   % [rad/s]
w4 = s(16);   % [rad/s]

% TODO: Fill in correct values here.
Itens = [Ixx 0 0;...  % Inertial tensor
         0 Iyy 0;...
         0 0 Izz];

 
Mtens = mass * eye(3,3); % Mass tensor

% Calculate the desired M1-4 and T1-4
% For now, just focuse on controlling attitude.  Bruce suggests
% angular acceleration control, and Dan Mellinger does exactly the same
% so this is a good starting point.

% Moment = (Angular Accel Desired) * Moment of Inertia
MomCont(1) = (kpRoll*(phi_com - phi) + kdRoll*p) * Ixx;     % 
MomCont(2) = (kpRoll*(theta_com - theta) + kdRoll*q) * Iyy; % 
MomCont(3) = 0;  % What's a good idea for yaw?

% Spatial Control

% Calculate the desired angular velocities to achieve these results.

% Form the 

% 3x3 Rotation matrix from body to world fram in the Z-X-Y system (Psi, Phi, Theta)
R = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

linAccel = inv(Mtens)*([0 0 mass*g]' + R*[0 0 -(T1(w1)+T2(w2)+T3(w3)+T4(w4))]');

omegaDot = inv(Itens)*([armLen*(T4(w1)-T3(w1)) armLen*(T1(w1)-T2(w1)) sum(Mom)]' - cross(s(10:12)', Itens*s(10:12)'));

% Matrix that brings you from your angular accels to derivatives of euler
% angles.
omegaDotToEulerDot = [cos(theta) 0 -cos(phi)*sin(theta);...    
                      0          1      sin(phi);...
                      sin(theta) 0   cos(phi)*cos(theta)];

eulerAngleDot = inv(omegaDotToEulerDot)*omegaDot;

sdot = [s(4:6) linAccel' eulerAngleDot' omegaDot'];
end