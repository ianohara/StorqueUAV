function [sdot] = StorqueStep(s,u)
% s = state vector (12x1)
% sdot = derivative of state at current time
% u = control input (6x1)
% Define all of the system variables

x = s(1);
y = s(2);
z = s(3);

u = s(4);
v = s(5);
w = s(6);

phi = s(7);
theta = s(8);
psi = s(9);

p = s(10);
q = s(11);
r = s(12);

Itens = [1 0 0;...  % Inertial tensor
     0 1 0;...
     0 0 1];

 
Mtens = m * eye(3,3); % Mass tensor

% Calculate M1-4 and T1-4 from our control model

% Apply motor response delay

% 3x3 Rotation matrix from body to world fram in the Z-X-Y system (Psi, Phi, Theta)
R = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

linAccel = inv(Mtens)*([0 0 m*g]' + R*[0 0 -(T1+T2+T3+T4)]');

omegaDot = inv(Itens)*([armLen(T4-T3) armLen(T1-T2) M1+M2+M3+M4] - cross(s(10:12)', Itens*s(10:12)'));

% Matrix that brings you from your angular accels to derivatives of euler
% angles.
omegaDotToEulerDot = [cos(theta) 0 -cos(phi)*sin(theta);...    
                      0          1      sin(phi);...
                      sin(theta) 0   cos(phi)*cos(theta)];

eulerAngleDot = inv(omegaDotToEulerDot)*omegaDot;

sdot = [s(4:6) linAccel' eulerAngleDot' omegaDot'];
end