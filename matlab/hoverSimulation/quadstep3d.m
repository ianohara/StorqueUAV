function [xnew] = quadstep3d(x,t,deltaT)
%   function xnew = step2(x,t,deltaT)

%   This M-file performs a 2nd-order numerical integration step.
% 
%   INPUTS
%   x           n x 1 vector of state variables at time t
%   t           time
%   deltaT      time step
% 
%   OUTPUTS      
%   xnew        n x 1 vector of state variables at time t + deltaT 
%  Originally written by: Daniel Mellinger
%  Modified with permission by: Ian O'Hara and Uriah Baalke

f1 = statedwm(x,t); deltax1 = deltaT*f1;
f2 = statedwm(x + deltax1,t + deltaT);
xnew = x + 0.5*deltaT*(f1 + f2);
return

function [sdot] = statedwm(s,t)
global cnt controls

cnt=cnt+1;

m = 0.500; %mass
I = [2.32e-3, 0, 0; ...
     0, 2.32e-3, 0; ...
     0, 0, 4e-3]; %moment of inertia matrix
g = 9.81; %gravity

sdot = zeros(12,1);
x = s(1);
y = s(2);
z = s(3);
xdot = s(4);
ydot = s(5);
zdot = s(6);
phi = s(7);
theta = s(8);
psi = s(9);
p = s(10);
q = s(11);
r = s(12);

%these could be the control inputs for your controller
ax_des = 0;
ay_des = 0;
az_des = 0;

%now compute the roll and pitch angles and force which achieves that
%acceleration or something like this
%Fvec = m*[ax_des,ay_des,az_des+g];
%F = sqrt(sum(Fvec.^2));
%theta_des = asin(Fvec(1)/F);
%phi_des = asin(-Fvec(2)/(F*cos(theta_des)));

%%% another simple way
 F = m*g + m*az_des;
 phi_des = -ay_des/g;            % Phi Control
 theta_des = ax_des/g;           % Theta control

% This simulates the onboard attitude controller
psi_des = 0;                    % Psi control
Ixx = I(1,1);
Izz = I(3,3);

t_attitude = 0.2;  % Rise time of the attitude controller [s]
xi_attitude = 1.0; % Damping ratio for attitude controller
kp_roll = 3.24*Ixx/t_attitude^2;           % Transfer function for proportional roll 
kd_roll = 3.6*xi_attitude*Ixx/t_attitude;  % Transfer function for derivative roll

t_yaw =0.2;   % Rise time of yaw controller [s]
xi_yaw = 1.0; % Damping ratio for yaw controller
kp_yaw = 3.24*Izz/t_yaw^2;     % 
kd_yaw = 3.6*xi_yaw*Izz/t_yaw; % 

% Moment
M = zeros(3,1);
M(1) = kp_roll*(phi_des - phi) - kd_roll*p;
M(2) = kp_roll*(theta_des - theta) - kd_roll*q;
M(3) = kp_yaw*(psi_des - psi) - kd_yaw*r;

%rotation matrix
BRW = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

WRB = BRW';

sdot(1) = xdot;
sdot(2) = ydot;
sdot(3) = zdot;

accel = 1/m *(WRB * [0;0;F] - [0;0;m*g]);

sdot(4) = accel(1);
sdot(5) = accel(2);
sdot(6) = accel(3);

J = [cos(theta),0,-cos(phi)*sin(theta);...
    0,1,sin(phi);...
    sin(theta),0,cos(phi)*cos(theta)];
omega = [p;q;r];
    
eulerangledot = inv(J)*omega;

sdot(7) = eulerangledot(1);
sdot(8) = eulerangledot(2);
sdot(9) = eulerangledot(3);

pqrdot = inv(I) *(M - cross(omega,I*omega));

sdot(10) = pqrdot(1);
sdot(11) = pqrdot(2);
sdot(12) = pqrdot(3);