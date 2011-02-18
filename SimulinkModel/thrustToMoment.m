function M = thrustToMoment(T)
% This function takes in the thrust of a prop and 
% returns the moment due to one of our props when at
% the specific Thrust.

% Quick Hack for Now: Linear response.
K = 1;   % Linear Gain [m]

M = K*T;
end