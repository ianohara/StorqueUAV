function success = drawStorque(fh, pos, angles)
    
    curFigure = gcf;  % Store the current figure so that we can give
                       % control back to it after plotting in fh
    figure(fh);
    
    % Set some storqueUAV size parameters
    rotorArmLength = 0.25;
    fuselageLength = 0.5;
    % These vectors define the fuselage and 4 rotor arms sitting at the
    % origin
    
    fuselage = [0 0 fuselageLength];
    rotorArm1 = [rotorArmLength 0 0];
    rotorArm2 = [-rotorArmLength 0 0];
    rotorArm3 = [0 rotorArmLength 0];
    rotorArm4 = [0 -rotorArmLength 0];
    
    fuselageTrans = eulerRotate(fuselage',angles(1),angles(2),angles(3));
    rotorArms1Trans = eulerRotate(rotorArm1',angles(1),angles(2),angles(3));
    rotorArms2Trans = eulerRotate(rotorArm2',angles(1),angles(2),angles(3));
    rotorArms3Trans = eulerRotate(rotorArm3',angles(1),angles(2),angles(3));
    rotorArms4Trans = eulerRotate(rotorArm4',angles(1),angles(2),angles(3));
    
    plot3([pos(1) pos(1) + fuselageTrans(1)], [pos(2) pos(2) + fuselageTrans(2)], [pos(3) pos(3) + fuselageTrans(3)], 'r', 'LineWidth',3);
    plot3([pos(1) pos(1) + rotorArms1Trans(1)], [pos(2) pos(2) + rotorArms1Trans(2)], [pos(3) pos(3) + rotorArms1Trans(3)], 'b', 'LineWidth',3);
    plot3([pos(1) pos(1) + rotorArms2Trans(1)], [pos(2) pos(2) + rotorArms2Trans(2)], [pos(3) pos(3) + rotorArms2Trans(3)], 'b', 'LineWidth',3);
    plot3([pos(1) pos(1) + rotorArms3Trans(1)], [pos(2) pos(2) + rotorArms3Trans(2)], [pos(3) pos(3) + rotorArms3Trans(3)], 'b', 'LineWidth',3);
    plot3([pos(1) pos(1) + rotorArms4Trans(1)], [pos(2) pos(2) + rotorArms4Trans(2)], [pos(3) pos(3) + rotorArms4Trans(3)], 'b', 'LineWidth',3);
    
    figure(curFigure);
end