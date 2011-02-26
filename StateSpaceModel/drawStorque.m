function success = drawStorque(fh, pos, angles)
    
    curFigure = gcf;  % Store the current figure so that we can give
                      % control back to it after plotting in fh
                      
                      
    figure(fh);       % Set the current figure to the storque figure
    
    if (strcmp(get(fh,'NextPlot'),'replaceChildren')) 
       set(gh,'NextPlot','replaceChildren'); 
    end
    
    cla(fh);
    
    fuselage = [0 0 -fuselageLength];
    rotorArm1 = [rotorArmLength 0 0];
    rotorArm2 = [-rotorArmLength 0 0];
    rotorArm3 = [0 rotorArmLength 0];
    rotorArm4 = [0 -rotorArmLength 0];
    
    xPatchDat = [-0.05; ...
                 0.05; ...
                 0.05; ...
                 -0.05];
    yPatchDat = [0.382; ...
                 0.382; ...
                 -0.382; ...
                 -0.382];
    zPatchDat = [0;0;0;0];
    
    patch = patch(xPatchDat, yPatchDat, zPatchDat,'r');
    
    rotorArms1Trans = eulerRotate(rotorArm1',angles(1),angles(2),angles(3));
    rotorArms2Trans = eulerRotate(rotorArm2',angles(1),angles(2),angles(3));
    rotorArms3Trans = eulerRotate(rotorArm3',angles(1),angles(2),angles(3));
    rotorArms4Trans = eulerRotate(rotorArm4',angles(1),angles(2),angles(3));
    
    % Now change the line data for our 4 lines to match the updated
    % position and orientation
    
    set(rotor1Line, 'XDATA',[pos(1) pos(1) + rotorArms1Trans(1)], ...
        'YDATA', [pos(2) pos(2) + rotorArms1Trans(2)], ... 
        'ZDATA', [pos(3) pos(3) + rotorArms1Trans(3)]);
    
    set(rotor2Line, 'XDATA',[pos(1) pos(1) + rotorArms2Trans(1)], ...
        'YDATA',[pos(2) pos(2) + rotorArms2Trans(2)], ...
        'ZDATA', [pos(3) pos(3) + rotorArms2Trans(3)]);
    
    set(rotor3Line,'XDATA',[pos(1) pos(1) + rotorArms3Trans(1)], ...
        'YDATA',[pos(2) pos(2) + rotorArms3Trans(2)],... 
        'ZDATA',[pos(3) pos(3) + rotorArms3Trans(3)]);
    
    set(rotor4Line,'XDATA',[pos(1) pos(1) + rotorArms4Trans(1)], ... 
        'YDATA',[pos(2) pos(2) + rotorArms4Trans(2)], ...
        'ZDATA',[pos(3) pos(3) + rotorArms4Trans(3)]);
    
    drawnow();   % Draw the updates
    figure(curFigure); % Set the current figure back to what it was
end