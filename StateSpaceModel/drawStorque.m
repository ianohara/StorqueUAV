function success = drawStorque(fh, pos, angles)
    
    curFigure = gcf;  % Store the current figure so that we can give
                      % control back to it after plotting in fh
                      
                      
    figure(fh);       % Set the current figure to the storque figure
    
    if (strcmp(get(fh,'NextPlot'),'replaceChildren')) 
       set(gh,'NextPlot','replaceChildren'); 
    end
    
    cla(fh);
    
    % Initialize the graphics objects we'll use to represent the storque
    % Later on we can get fancy with these.
    fuselageLine = line([0 1], [0 0], [0 0]);
    rotor1Line = line([0 0], [0 0], [0 0]);
    rotor2Line = line([0 0], [0 0], [0 0]);
    rotor3Line = line([0 0], [0 0], [0 0]);
    rotor4Line = line([0 0], [0 0], [0 0]);
    
    % Set the graphics objects properties for the storque
    set(fuselageLine,'LineWidth',8);
    
    set(rotor1Line,'LineWidth',4);
    set(rotor1Line,'MarkerSize',10);
    
    set(rotor2Line,'LineWidth',4);
    set(rotor2Line,'MarkerSize',10);
    
    set(rotor3Line,'LineWidth',4);
    set(rotor3Line,'MarkerSize',10);
    
    set(rotor4Line,'LineWidth',4);
    set(rotor4Line,'MarkerSize',10);

    % Set some storqueUAV size parameters
    rotorArmLength = 0.53;
    fuselageLength = 0.914;
    
    % These vectors define the fuselage and 4 rotor arms sitting at the
    % origin in the world frame (pre-translation and pre-rotation)
    
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
    
    % Now change the line data for our 4 lines to match the updated
    % position and orientation
    
    set(fuselageLine, 'XDATA',[pos(1) pos(1) + fuselageTrans(1)], ... 
        'YDATA', [pos(2) pos(2) + fuselageTrans(2)], ...
        'ZDATA', [pos(3) pos(3) + fuselageTrans(3)]);
    
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