% Take a column 3x1 column vector and rotate it according to the
% incoming euler angles.

function newVec = eulerRotate(vec,phi,theta,psi)
    % Define the rotation matrix
    R = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

    newVec = R*vec;
end