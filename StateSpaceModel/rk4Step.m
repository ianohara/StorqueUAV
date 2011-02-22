function s2 = rk4Step(s1, u, fh, dt)
% Fourth Order Runge Kutta Implementation with fixed time step.  Now,
% only implemented for non-time explicit states.
% 
%
% This is specifically implemented for the Storque simulation, so includes
% a static control vector as input as well.
%
% by:
%    Ian O'Hara, Uriah Baalke, Sebastian Mauchly, Alice Yurechko, and
%    Emily Fisher
%
% Arguments:
%   s1 = initial state [n x 1]
%    u = Control input vector [6 x 1]
%   fh = function handle that computes change of state
%        based on a state passed to it.
%        This should accept an [n x 1] vector and return an [n x 1] vector.
%   dt = Time increment into the future for which we should predict the
%        future
% Output:
%   Predicted state at time t1+dt.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the four slopes that will be used as weighted slopes for stepping
% to the next state
mk = fh(s1, u);
nk = fh(s1 + mk*(dt/2), u);
pk = fh(s1 + nk*(dt/2), u);
qk = fh(s1 + pk*dt, u);

% Compute the next state weighting the two middle slopes twice as much
% as the other.
s2 = s1 + ((mk + 2*nk + 2*pk + qk)/6)*dt;
end