function [Fx,Fy,Fz,Mx,My,Mz] = ThrustToBodyReaction(T1,T2,T3,T4)
% This function takes in the thrusts of each of the four props
% and outputs the resulting forces and moments in each of the three
% body axes of the quadrotor. (Traditional Z-axis down coordinates)

% Props 1 and 2 (T1 and T2) are attached to the x-axis
% Props 3 and 4n (T3 and T4) are attached to the y-axis

% **Improvements Needed**:
%  As it is now, Fx and Fy will always be 0.  We need 
%  this function to eventually also take spatial variables
%  as input.
%
%

% Physical system Parameters
L = 0.382;  % Length from CG to Prop [m]

LinTransMatrix = [0 0 0 0; 0 0 0 0; -1/4 -1/4 -1/4 -1/4; 0 0 -L L; L -L 0 0];

Result = LinTransMatrix*[T1, T2, T3, T4]';

% This is nasty.  To improve this, we might want to make a simulink block
% that takes in all of these inputs and outputs a vector of the inputs that
% we can then pass to this block.  Then we can just deal with vectors, so
% it'd be nice and short.
Fx =  Result(1);
Fy = Result(2);
Fz = Result(3);
Mx = Result(4);
My = Result(5);
Mz = thrustToMoment(T1) + thrustToMoment(T2) - thrustToMoment(T3) - thrustToMoment(T4);
end