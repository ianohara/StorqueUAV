function [states, steps, simTime] = runSim(initState, controlVec, params, endTime, dt)
% Run a storque simuation for a set amount of time returning the time
% it took to run the simulation and the final state.
% 
% This is used in the testing script for the storque simulator.
%
% initState - [1x16] state vector
% controlVec - [1x6] control vector
% params - structure containing the physical system parameters
%
% endTime - Simulation will run from time 0 to endTime
% dt - Timestep to use for the numerical integration.
%
%
%
%

states = zeros(ceil(endTime/dt),16);
steps = 1;

% Record the initial conditions.
states(steps,:) = initState;

tic;
time = 0;
while(time < endTime)
   time = time + dt;
   states(steps+1,:) = rk4Step(states(steps,:),controlVec, @StorqueStep, dt);
   steps = steps + 1;
end
simTime = toc;

end