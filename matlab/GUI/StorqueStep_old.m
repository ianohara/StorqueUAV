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
phi   = s(7);    % Euler Angle on body axis x
theta = s(8);    % Euler angle on body axis y 
psi   = s(9);    % Euler Angle on body axis z

p = s(10);  % Angular rate around body axis x
q = s(11);  % Angular rate around body axis y
r = s(12);  % Angular rate around body axis z

% Angular rates of props 1-4
w1 = s(13);   % [rad/s]
w2 = s(14);   % [rad/s]
w3 = s(15);   % [rad/s]
w4 = s(16);   % [rad/s]

%% Control Laws Start Here

%----Constants, Function Definitions----%
% Define physical system parameters
mass = 3.76;        % [kg]
armLen = 0.382;  % [m]
Ixx = 0.2;       % [kg*m^2]
Iyy = 0.2;       % [kg*m^2]
Izz = 0.2;       % [kg*m^2]
g = 9.81;        % [m/s^2]

% Physical system gains
max_thrust = 1.5*g; % Maximum thrust we can get from a rotor [kg*m/s^2]
kM = (1.0*g) / 537345;             % Gain for omega -> Moment               [kg*m^2]
kT = max_thrust / 537345;         % Gain for omega -> Thrust               [kg*m]
kMot = 5;           % Gain on first order motor delay        [1/s]
kRatio = kM/kT;     % Ratio of how much Moment [kg*m^2] is exerted by a motor 
                    %  for every [kg*m] of Thrust that would be exerted by the
                    %  same motor speed w.  Units are [m]

% Form the 3x3 Rotation matrix from body to world frame in the Z-X-Y system (Psi, Phi, Theta)
R = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

% Control gains
kpRoll = (10);  
kdRoll = (6.2);

kpYaw = 10;
kdYaw = 6.2;

kdZTrans = 10;

% Define the function that will give us thrusts in the zb axis as a 
% of w (omega)
T = @(w,k)(k.*w.^2);
M = @(w,k)(k.*w.^2);

% Define the inverse of T(w,k)
Ttow = @(T,k)(sqrt(T./k));

% Calculate trim forces and moments needed to maintain hover
forceZTrim =   mass*g / (cos(phi)*cos(theta));
momPhiTrim =   0;
momPsiTrim =   0;
momThetaTrim = 0;

%----Dynamic Controls Calculations----%
% Moment = (Angular Accel Desired) * Moment of Inertia
momCont(1) = (kpRoll*(  phi_com -   phi) - kdRoll*p) * Ixx;  % Phi 
momCont(2) = (kpRoll*(theta_com - theta) - kdRoll*q) * Iyy;  % Theta
momCont(3) = (kpYaw *(  psi_com -   psi) - kdYaw *r) * Izz;  % Psi

% Spatial Control
thrustCont(1) = 0; % Thrust in x [N]
thrustCont(2) = 0; % Thrust in y [N]
thrustCont(3) = (kdZTrans*(zd_com - w))*mass ; %+ kdZTrans*world_vel(3))*mass*g; % Thrust in z [N]  <-- Not working properly right now

% Define and calculate the vertical force and the three body-axis moments that we want
forceZ   = forceZTrim   + thrustCont(3);
momPhi   = momPhiTrim   + momCont(1);
momTheta = momThetaTrim + momCont(2);
momPsi   = momPsiTrim   + momCont(3);

% Determine the required motor forces we desire to achieve these force /
% moments by applying these constraints in order.  First, we distribute the
% required z force evenly between all the motors.  Then, we use any
% remaining flexibility in the thrusts to exert moments about the x and y
% axes, up to the actual momPhi and momTheta values we've just calculated.
% Finally, if the motors are still not max-ed or min-ed out, we can put a
% yaw moment on the vehicle with any remaining thrust flexibility.
fDes = (forceZ/4)*([1 1 1 1]');
fDes = fDes - max( ((forceZ/4) - max_thrust), 0);

if max(0,forceZ) < (1.1*forceZTrim)
    forceZCheck = forceZ;
else
    forceZCheck = 1.1*forceZTrim;
end

if forceZCheck > max_thrust*4
    max_attitude_force_increase2 = max([abs(momPhi/(2*armLen)),abs(momTheta/(2*armLen))]);
    max_attitude_force_increase = min(max_attitude_force_increase2, (max_thrust/2));
    fDes = (max_thrust - max_attitude_force_increase)*([1 1 1 1]');
end

clip_force1 = max_thrust - fDes(1);
clip_force2 = fDes(1) - 0;

clip_force = min(clip_force1, clip_force2);

if ((clip_force) < abs(momPhi/(2*armLen)))
    fDes(1) = fDes(1) + (clip_force*sign(momPhi));
    fDes(2) = fDes(2) - (clip_force*sign(momPhi));
else
    fDes(1) = fDes(1) + (momPhi/(2*armLen));
    fDes(2) = fDes(2) - (momPhi/(2*armLen));
end

if ((clip_force) < abs(momTheta/(2*armLen)))
    fDes(3) = fDes(3) + (clip_force*sign(momTheta));
    fDes(4) = fDes(4) - (clip_force*sign(momTheta));
else
    fDes(3) = fDes(3) + (momTheta/(2*armLen));
    fDes(4) = fDes(4) - (momTheta/(2*armLen));
end

ab = [3 4];
cd = [1 2];

if sign(momPsi) > 0
    ab = [1 2];
    cd = [3 4];
end

yaw_clip1 = max_thrust - max(fDes(ab));
yaw_clip2 = max(fDes(cd)) - 0;

yaw_clip = min(yaw_clip1, yaw_clip2);

if ( (kRatio*yaw_clip) < abs(momPsi/4) )
    fDes(ab) = fDes(ab) + yaw_clip;
    fDes(cd) = fDes(cd) - yaw_clip;
else
    fDes(ab) = fDes(ab) + abs(momPsi/kRatio)/4;
    fDes(cd) = fDes(cd) - abs(momPsi/kRatio)/4;
end

%This matrix describes the mapping from: The desired moments and vertical
%force that we've just calculated -to- the thrust required from each motor
%to achieve those total force / moments.
%{
A =        [1       1       1        1;...
            armLen -armLen  0        0;...
            0       0       armLen  -armLen;...
            kRatio  kRatio -kRatio  -kRatio];
%}
%We solve our matrix equation [forceZ momPhi momTheta momPsi]' = A*fDes by
%multiplying both sides by the inverse of M.  Though M is a constant matrix
%for a given physical configuration with fixed motor characteristics, we
%may tune these during testing.  For now, it is calculated every time
%StorqueStep is run, though in the future it could be pre-computed to
%improve speed.
%fDes = A\[forceZ momPhi momTheta momPsi]';

%Constrain the forces to a physically possible ranges.  The rotors only
%spin one way, so we cannot exert a negative force.  Also, the rotors have
%a maximum thrust they can attain, so we can't ask for more than that.
for b = 1:4
    if fDes(b) > max_thrust
        fDes(b) = max_thrust;
    elseif fDes(b) < 0
        fDes(b) = 0;
    end
end

%Convert the final desired thrusts into desired prop speeds
wDes = Ttow(fDes,kT);

%In the embedded code, we would now convert wDes to required PWM output, and
%this would conclude the controls code.  The quadrotor's motors will not
%instantly respond to the PWM that we command, but our controls will be
%robust enough to keep it stable despite this, as we prove with this
%simulation.

%% Physical Modeling Starts Here

% Build the tensors that describe the quadrotor dynamics
Itens = [Ixx 0  0;...  % Inertial tensor
          0 Iyy 0;...
          0  0 Izz];
 
Mtens = mass * eye(3,3); % Mass tensor


%----Calculate the Dynamics----%
% Linear Acceleration
linAccel = (Mtens)\([0 0 -mass*g]' + R*[0 0 (T(w1,kT)+T(w2,kT)+T(w3,kT)+T(w4,kT))]');

% Angular Acceleration
omegaDot = (Itens)\([armLen*(T(w1,kT)-T(w2,kT)) armLen*(T(w3,kT)-T(w4,kT)) M(w1,kM)+M(w2,kM)-M(w3,kM)-M(w4,kM)]' - cross(s(10:12)', Itens*s(10:12)'));

% Matrix that brings you from your angular velocities to derivatives of euler
% angles.
omegaDotToEulerDot = [cos(theta) 0 -cos(phi)*sin(theta);...    
                      0          1      sin(phi);...
                      sin(theta) 0   cos(phi)*cos(theta)];

eulerAngleDot = (omegaDotToEulerDot)\[p q r]';

% First order motor response.
omegaPropsDot = kMot*(wDes' - [w1 w2 w3 w4]);

% Construct the output vector sdot that contains the derivatives of the
% input state s
sdot = [s(4:6) linAccel' eulerAngleDot' omegaDot' omegaPropsDot];
end