function [sdot] = StorqueStep(s,u)
% s = state vector (16x1)
% sdot = derivative of state at current time
% u = control input (6x1)

% u = [xd_com yd_com zd_com phi_com theta_com psi_com]
% Where com = 'commanded'
xd_com    = u(1);
yd_com    = u(2);
zd_com    = u(3);
phi_com   = u(4);
theta_com = u(5);
psi_com   = u(6);

% Define physical system parameters
mass = 5;        % [kg]
armLen = 0.382;  % [m]
Ixx = 1;         % [kg*m^2]
Iyy = 1;         % [kg*m^2]
Izz = 1;         % [kg*m^2]
g = 9.81;        % [m/s^2]

% Physical system gains
kM = 1;          % Gain for omega -> Moment [kg*m^2]
kT = 1;          % Gain for omega -> Thrust [kg*m]
kMot = 1;        % Gain on first order motor delay [1/s]

% Control gains
kpRoll = 1;
kdRoll = 1;

% Calculate trim angular velocities needed in our artificial quadrotor
% axes (omegaZ,omegaPhi,omegaPsi,omegaTheta)  These get distributed over
% the four motor omegas, which explains the 1/4 factor in omegaZTrim

% These are for hover trim
omegaZTrim = sqrt((mass*g)/(4*kT));
omegaPhiTrim = 0;
omegaPsiTrim = 0;
omegaThetaTrim = 0;

% Define all of the system variables
x = s(1);   % World Position x [m]
y = s(2);   % World position y [m]
z = s(3);   % World position z [m]

u = s(4);   % Body frame velocity xb [m/s]
v = s(5);   % Body frame velocity yb [m/s] 
w = s(6);   % Body frame velocity zb [m/s]

% Euler angles.  The comments are slightly wrong
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
Itens = [Ixx 0  0;...  % Inertial tensor
          0 Iyy 0;...
          0  0 Izz];

 
Mtens = mass * eye(3,3); % Mass tensor

% Define the functions that will give us Moments in the zb axis
% and Thrusts in the zb axis as a function of w (omega)
M = @(w,k)(k.*w.^2);
T = @(w,k)(k.*w.^2);

% Define the inverse of M(w,k) and T(w,k)
Mtow = @(M,k)(sqrt(M./k));
Ttow = @(T,k)(sqrt(T./k));

% Calculate the desired M1-4 and T1-4
% For now, just focuse on controlling attitude.  Bruce suggests
% angular acceleration control, and Dan Mellinger does exactly the same
% so this is a good starting point.

% Moment = (Angular Accel Desired) * Moment of Inertia
momCont(1) = (kpRoll*(phi_com - phi) + kdRoll*p) * Ixx;      % Phi 
momCont(2) = (kpRoll*(theta_com - theta) + kdRoll*q) * Iyy;  % Theta
momCont(3) = 0;  % What's a good idea for yaw?               % Psi

% Spatial Control
thrustCont(1) = 0; % Thrust in x [N]
thrustCont(2) = 0; % Thrust in y [N]
thrustCont(3) = 0; % Thrust in z [N]

% Define and calculate omegas needed
omegaZ     = omegaZTrim + Ttow(thrustCont(3),kT);
omegaPhi   = omegaPhiTrim + Ttow(thrustCont(1),kT) + Mtow(momCont(1),kM);
omegaTheta = omegaThetaTrim + Ttow(thrustCont(2),kT) + Mtow(momCont(2),kM);
omegaPsi   = omegaPsiTrim + Mtow(momCont(3),kM);

% Calculate the desired angular velocities of each motor to achieve
% these results.
% This is more or less exactly copied from Mellinger's work.
% TODO: Good description of this

wDes = zeros(4,1);

% Columnwise contributions are:
% Z, Phi, Theta, Psi
% TODO: Check the signs on Phi and Theta
omegaTransform = [1  1  0   1;...
                  1 -1  0   1;...
                  1  0 -1  -1;...
                  1  0  1  -1];
              
wDes = omegaTransform*[omegaZ omegaPhi omegaTheta omegaPsi]';

% Form the 

% 3x3 Rotation matrix from body to world fram in the Z-X-Y system (Psi, Phi, Theta)
R = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

linAccel = inv(Mtens)*([0 0 mass*g]' + R*[0 0 -(T(w1,kT)+T(w2,kT)+T(w3,kT)+T(w4,kT))]');

omegaDot = inv(Itens)*([armLen*(T(w1,kT)-T(w1,kT)) armLen*(T(w1,kT)-T(w1,kT)) M(w1,kM)+M(w2,kM)-M(w3,kM)-M(w4,kM)]' - cross(s(10:12)', Itens*s(10:12)'));

% Matrix that brings you from your angular accels to derivatives of euler
% angles.
omegaDotToEulerDot = [cos(theta) 0 -cos(phi)*sin(theta);...    
                      0          1      sin(phi);...
                      sin(theta) 0   cos(phi)*cos(theta)];

eulerAngleDot = inv(omegaDotToEulerDot)*omegaDot;

omegaPropsDot = kMot*(wDes' - [w1 w2 w3 w4]);

%s(4:6)
%linAccel'
%eulerAngleDot'
%omegaDot'
%omegaPropsDot'
sdot = [s(4:6) linAccel' eulerAngleDot' omegaDot' omegaPropsDot];
end