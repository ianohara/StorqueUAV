%% Preliminary Simulation Code for testing the Storque Quadrotor
%{ 
   Sebastian Mauchly, Ian O'Hara, Uriah Baalke, Emily Fisher, Alice Yurechko
   2/28/2011
%}

close all
clear all

%serial = storqueInterface('COM6');

%figure (1)
%axes_hand = axes;
%[h1 h2 h_lines] = init_quad_draw(axes_hand);

%Initialize the quadrotor's 1x16 state s, as defined in StorqueStep
% State values are: x y z u v w phi theta psi p q r initial_motor speeds
x = 0;
y = 0;
z = 0;
u = 0;
v = 0;
w = 0;
phi = pi/16;
theta = 0;
psi = 0;
p = 0;
q = 0;
r = 0;
%634.8297*2
old_state = [x y z, u v w, phi theta psi, p q r, (585) (585) (585) (585)];
%old_state = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 634.8297 0];
%old_state = [0 0 3 0 0 12 0 pi/2 0 5 0 0 634.8297 634.8297 634.8297 634.8297];
%old_state = [0 0 0 3 -6 12 0 pi/2 pi/4 6 0 0 634.8297 634.8297 634.8297 634.8297];
%Initialize the quadrotor's 1x6 control input u, as defined in StorqueStep
control_input = [0 0 0 0 0 0];

%Initialize the timer
tic

runtime = 5;
global time;
global stateMatrix;
time = 0;
stateMatrix = [old_state];

%% Main Loop
while(time(length(time)) < runtime)
    %TODO: A good way to escape this loop easily without Ctrl-C

    % If you want, uncomment this and delete "rcis=[];" to collect input
    % from the controller that is being broadcast by the micro.  You'll
    % also need to uncomment "serial = storqueInterface('COM6') at the very
    % top.
    
    %[angles rcis pwms] = serial.get_data();
    rcis = [];
    if (~isempty(rcis))
        control_input(1:2) = 3*[rcis(1) -rcis(2)];
        control_input(3) = rcis(4) + .2;
        control_input(6) = rcis(3);
    end
    
    %dt = toc;  
    dt = 0.03;
    time = [time; time(length(time)) + dt];
    new_state = rk4Step(old_state,control_input,@StorqueStep,dt);
    tic

    %Enforce periodicity on the angular coordinates
    for j = 7:9
        if new_state(j) > pi
            new_state(j) = new_state(j) - 2*pi;
        elseif new_state(j) < -pi
            new_state(j) = new_state(j) + 2*pi;
        end
    end
    
    %UPDATE THE OLD STATE, DAMNIT
    old_state = new_state;
    
    kT = [3.63737e-5 -0.00770417 0.63139];
    T = @(w,k)(k(1)*w.^2 + k(2).*w + k(3));
    
    % Draw our new quadrotor.  There's some really weird stuff going on
    % here, which should be carefully noted.  Due to some inconsistencies
    % between Ian's development and mine, my quad_draw function needs a
    % funky order for a lot of the inputs.  quad_draw accepts:
    %   3 ZXY Euler Angles in DEGREES, ordered as [psi phi theta]
    %   4 Thrusts of the motors ordered T1, T4, T2, T3 (here we compute them
    %     using the omegas that are output by rk4Step, and their absolute
    %     magnitude is generally not important except that they be visible in
    %     the plot)
    %   3 World Position coordinates x, y and z
    %   1 Handle to a "quadrotor-looking" patch graphics object that is a child of
    %     the current figure
    %   1 Handle to a "quadrotor's-shadow-looking" patch
    %   1 Vector of Handles to 4 Line Objects that will be drawn as the
    %     thrusts   
    
    %quad_draw(180*new_state([9 7 8])/pi,T(new_state([13, 16, 14, 15])/2.5, kT),new_state(1:3),h1,h2,h_lines);
    stateMatrix = [stateMatrix; new_state];   

end

figure(); 
subplot(3,1,1); plot(time, stateMatrix(:, 7:9));
title('Phi, Theta, Psi');
legend('Phi', 'Theta', 'Psi', 'Location', 'NorthEast');
xlabel('Time [sec]');
ylabel('Angle [rad]');

subplot(3,1,2); plot(time, stateMatrix(:, 10:12));
title('p, q, r');
legend('p', 'q', 'r', 'Location', 'NorthEast');
xlabel('Time [sec]');
ylabel('Angular Rate [rad/s]');

subplot(3,1,3); plot(time, stateMatrix(:, 13:16));
title('Motor Omegas');
legend('Motor0', 'Motor1', 'Motor3', 'Motor4', 'Location', 'NorthEast');
xlabel('Time [sec]');
ylabel('Angular Rate [rad/s]');

%{
subplot(4,1,4); plot(time, stateMatrix(:, 1:3));
title('Position');
legend('X', 'Y', 'Z', 'Location', 'NorthEast');
xlabel('Time [sec]');
ylabel('Position [m]');
%}

draw = 1;
i = 1;
figure();
axes_hand = axes;
[h1 h2 h_lines] = init_quad_draw(axes_hand);
tic
while(draw),    
    if (toc > time(i + 1))
        quad_draw(180*stateMatrix(i,[9 7 8])/pi,T(stateMatrix(i,[13, 16, 14, 15])/2.5, kT),stateMatrix(i,1:3),h1,h2,h_lines);
        i = i + 1;        
    end
    if (i == length(time) - 1),
        draw = 0;
    end    
end

%serial.close();