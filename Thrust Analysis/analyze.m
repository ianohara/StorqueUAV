% Copyright 2011. Ian O'Hara, Uriah Baalke, Emily Fisher, Alice Yurechko,
%                 and Sebastian Mauchly.
%------------------------------------------------------------------------
%         Propeller Thrust Analysis Script (Static Only)
%           Purpose: Take data in 9 .csv files generated
%                    by running our thrust test setup for
%                    a certain propeller on a certain
%                    motor and generate pretty plots
%                    of:
%                       1) Fz vs RPM
%                       2) Mz vs RPM
%                       3) |Fz + Fy + Fx| vs Time (point for each duty fac)
%                       4) |Mz + My + Mx| vs Time (point for each duty fac)
%                       5) Motor Efficiency vs RPM
%                       6) Prop Figure of Merit vs RPM (ideal power for thrust /
%                               actual power for thrust)
%                       7) |F| vs duty cycle sent to ESC
%                       8) |M| vs duty cycle sent to ESC
%
%   Calling procedure:
%     analyze('motorFolder', 'propName', trialNum) % Pretty self explanatory
%           Note: Don't include trailing backslashes.
%           - motorFolder is the folder in which the there are sub folders
%               that are Prop Names.
%           - propName is the name of the prop used both as the prop folder
%               name and the prefix of the .csv files contained in said
%               folder.
%   
%       Calling options (specified after the 3 necessary args as '-<char>':
%               -c : Don't clear/close all figures when called.  Useful
%                    for laying different trials on top of each other
%               -v : Verbose (Does nothing! TODO)
%               -d : Debug mode (Does nothing! TODO)
%       
%  Notes: Right now, you need to manually enter the diameter of each prop
%  you run.  This is horrible.  If we decide on a common naming technique
%  such as 2 letters for the company, 2 digits for prop length, 1 digit for
%  prop pitch, and whatever after then we can just pull this out of
%  motorFolder. (This naming convention would be the same as the example
%  cited above, MA0970TP.)
%
%  Second Note/PLEA:  This guy is getting ugly, huge, and repetative. If
%                     anyone has the desire to refactor the hell out of it
%                     by breaking it down into read/analyze/plot functions
%                     of reasonable size, please do.
%------------------------------------------------------------------------

function success = analyze(motorFolder, propName, trialNum, varargin)
    
    % Initialize success to a failure state (>0 = success)
    success = 0;

    % Parse optional arguments and make sure there are at least 3
    % arguments.
    
    % Set all optional options to false first
    verboseOpt = 0; % Turn on a lot of matlab command window output.
    debugOpt = 0;   % Turn on debugging (Currently does nothing).
    closeOpt = 0;   % '-c' specified says that we shouldn't close previously
                    % existing features.  Useful for laying multiple trials
                    % of data on top of each other.
    if (nargin > 3)
        for i = 1:(nargin-3)
            switch(varargin{i})
                case '-c'
                    closeOpt = 1;
                case '-v'
                    verboseOpt = 1;
                case '-d'
                    debugOpt = 1;
                otherwise
                    fprintf('Unknown option: "%s"\n',varargin{i});
            end
        end
    elseif (nargin < 3)
        disp('Error: Incorrect arguments passed. See source for usage.');
    end
    
    if (~closeOpt)
        close all;
    end
    
    %------------------------------------------------------------------
    % Quick Current Calibration Stuff: This should be moved, erased, or
    % at least given more data eventually.
    
    calibrateCur = [0.52 1.01 1.93 2.84];
    calibrateCurCAN = [92.8544 105.9064 128.3618 152.2740];
    
    P = polyfit(calibrateCurCAN,calibrateCur,1);
    avgSlope = P(1);
    avgIntercept = P(2);
    
    %------- DEFINES ----------%
    ampSlope = avgSlope;  %[A/V] -> Convert amp readings from volts->amps
    ampIntercept = avgIntercept;
    
    % Construct strings from the arguments that will be used as directory
    % locations and as a quick method of constructing the names of the
    % various data files we need to access.
    
    % Folder containing data folders for each trial run with this
    % motor/prop combo
    trialFolder = [motorFolder '/' propName];
    
    trialString = ['Trial_' num2str(trialNum)];
    
    dataFolder = [trialFolder '/' trialString];
    
    fileNameStub = [dataFolder '/' propName '_' sprintf('%d',trialNum)];
    
    rho = 1.2;           % [kg/m^3];
    diam = 0.3048;       % [m] THIS NEEDS TO BE PULLED OUT OF propName eventually
    voltage = 11.1;      % [V]
    % END DEFINES %
    
    if (exist(trialFolder,'file') ~= 7)
        disp(sprintf('Error: Folder "%s" does not exist.',trialFolder));
        success = -1;
        return;
    end
    
    if (exist(dataFolder,'file') ~= 7)
        disp(sprintf('Error: Folder "%s" does not exist.',dataFolder));
        success = -2;
        return;
    end
    
    % Check to see if there are data files for transient tests.
    staticTests = 0;
    if (exist([fileNameStub '_Fx'],'file') == 2)
        staticTests = 1;
    end
    
    % Check to see if there are data files for transient tests.
    transientTests = 0;
    if (exist([fileNameStub '_Fx_trans'],'file') == 2)
        transientTests = 1;
    end
    
    % Construct a string that represents the directory path to the folder
    % containing all of the CSV files.
    
    if (staticTests == 1)
        disp('Loading static test data...');
        % Load all of our data from .csv files
        dataFx = csvread([fileNameStub '_Fx']);     % [N]
        dataFy = csvread([fileNameStub '_Fy']);     % [N]
        dataFz = csvread([fileNameStub '_Fz']);     % [N]
        dataTx = csvread([fileNameStub '_Tx']);     % [mN*m]
        dataTy = csvread([fileNameStub '_Ty']);     % [mN*m]
        dataTz = csvread([fileNameStub '_Tz']);     % [mN*m]
        
        % Number given to the timer in the Maevarm as the switch low point
        % in the duty cycle.  
        dataOCR1A = csvread([fileNameStub '_dc_nums']);    
                                
        % Note: Current data is given to us in voltage across
        %       a hall effect sensor.  So, we need a calibration factor
        %       to convert from voltage -> amps.  Luckily this
        %       is a linear relationship.
        dataCur = csvread([fileNameStub '_cur']);   % [V]
        
        % Convert current data to amps from our calibration data
        dataCur = ampSlope*dataCur + ampIntercept;                             % [A]

        dataRPM = csvread([fileNameStub '_w']);       % [RPM]
        dataRPMTime = csvread([fileNameStub '_t_w']); % [s]

        setup = csvread([fileNameStub '_setup']);

        numTests = setup(1,1);
        durTests = setup(1,2);
        sampleRate = setup(1,3);
        dcTimerMax = setup(1,4);

        % Duty cycles of each section of data.  dcTimerMax is the
        % max number Timer1 on the maevarm counts to, dataOCR1A is the
        % value at which the timer is set low and it is set high
        % again when the timer rolls over (ie: 20000+1).
        % THIS TIMER SETUP NEEDS TO BE VERIFIED!!!!!
        dataPwmCom = dataOCR1A ./ dcTimerMax;
        
        % The DAC takes 0.5 seconds to start giving valid readings every
        % time you pull data from it, so we need to know how many data
        % points to ignore at the beginning of each new trial
        dacIgnore = sampleRate * 0.5;                                      %[1/s * s = index]

        % Now, construct the average values for each duty factor (ignoring the
        % values during the 0.5s DAC recalibrate.
        avgFx = sum(dataFx(dacIgnore:size(dataFx,1),:))./(size(dataFx,1)-dacIgnore); %[N]: 1 x numTests
        avgFy = sum(dataFy(dacIgnore:size(dataFy,1),:))./(size(dataFy,1)-dacIgnore); %[N]: 1 x numTests
        avgFz = sum(dataFz(dacIgnore:size(dataFz,1),:))./(size(dataFz,1)-dacIgnore); %[N]: 1 x numTests

        avgTx = sum(dataTx(dacIgnore:size(dataTx,1),:))./(size(dataTx,1)-dacIgnore);
        avgTy = sum(dataTy(dacIgnore:size(dataTy,1),:))./(size(dataTy,1)-dacIgnore);
        avgTz = sum(dataTz(dacIgnore:size(dataTz,1),:))./(size(dataTz,1)-dacIgnore);

        avgRPM = sum(dataRPM)./size(dataRPM,1);                     % [RPM]
        avgCur = sum(dataCur)./size(dataCur,1);                     % [A]

% Linear fit was misguided        
%         % Perform a linear fit on the magnitude of thrust for
%         % purposes of our first linear simulink model.  (It looks
%         % more like a 2nd order polynomial)
        avgFMag = sqrt(avgFx.^2 + avgFy.^2 + avgFz.^2);
        magnitudeM = sqrt(avgTx.^2 + avgTy.^2 + avgTz.^2);

        % TODO: ALERT: DEBUG: These are specific to the data set
        % available on 2/22/2011.  This should be removed
        % for new data
        % Now perform a 2nd order fit on the magnitude of thrust versus
        % dataPwmCom
        coeffsFitF2nd = polyfit(dataPwmCom(1:length(avgFMag)-3), avgFMag(1:length(avgFMag)-3),2);
        coeffsFitF2ndOmeg = polyfit(avgRPM(1:length(avgFMag)-3), avgFMag(1:length(avgFMag)-3),2);
        
        % Perform a second order fit on the moment data IGNORING the last
        % four points because they are current limited.
        coeffsFitM2nd = polyfit(dataPwmCom(1:length(magnitudeM)-4),magnitudeM(1:length(magnitudeM)-4),2);
        coeffsFitM2ndOmeg = polyfit(avgRPM(1:length(magnitudeM)-4),magnitudeM(1:length(magnitudeM)-4),2);
        % Perform a linear fit on the  moment magnitude data
        
        coeffsFitM = polyfit(avgRPM, magnitudeM,1);

        
        % Perform a linear fit on the magnitude of thrust versus PWM
        % commanded
        coeffsFitPwm = polyfit(dataPwmCom,avgFMag,1);
        
        % Perform a linear fit on the magnitude of moment versus PWM
        coeffsFitPwmMom = polyfit(dataPwmCom, magnitudeM,1);
        
      disp('Plotting Static test data...');
     
      % Average Fz
      figure(1);
      title(sprintf('Static Tests for Prop: %',propName),'FontSize',14);

      subplot(2,2,1);
      plot(avgRPM,avgFz,'o','MarkerFaceColor','b');
      grid on;
      hold on;
      title('Average F_z','FontSize',14);
      xlabel('\omega [RPM]','FontSize',14);
      ylabel('F_z [N]','FontSize',14);

      % Average Mz
      subplot(2,2,2);
      plot(avgRPM,avgTz,'o','MarkerFaceColor','b');
      grid on;
      hold on;
      title('Average M_z','FontSize',14);
      xlabel('\omega [RPM]','FontSize',14);
      ylabel('T_z [mN*m]','FontSize',14);

      % Magnitude of F
      subplot(2,2,3);
      plot(avgRPM,avgFMag,'o','MarkerFaceColor','b');
      grid on;
      hold on;
      forceFitDataOmeg = coeffsFitF2ndOmeg(1).*avgRPM.^2 + coeffsFitF2ndOmeg(2).*avgRPM + coeffsFitF2ndOmeg(3);
      plot(avgRPM,forceFitDataOmeg,'r','LineWidth',2);
       legend('Raw Data',sprintf('2nd Order Poly Fit: %2.5g x^2',coeffsFitF2ndOmeg(1)));
      title('Magnitude of F Vector','FontSize',14);
      xlabel('\omega [RPM]','FontSize',14);
      ylabel('|F| [N]','interpreter','tex','FontSize',14);

      % Magnitude of M
      subplot(2,2,4);
      grid on;
      hold on;
      plot(avgRPM,magnitudeM,'o','MarkerFaceColor','b');
      momFitDataOmeg = coeffsFitM2ndOmeg(1).*avgRPM.^2 + coeffsFitM2ndOmeg(2).*avgRPM + coeffsFitM2ndOmeg(3);
      plot(avgRPM,momFitDataOmeg,'r','LineWidth',2);
      
      legend('Raw Data',sprintf('2nd Order Poly Fit: %2.5g x^2',coeffsFitM2ndOmeg(1)),'Location','NorthWest');
      title('Magnitude of M Vector','FontSize',14);
      xlabel('\omega [RPM]','FontSize',14);
      ylabel('|M| [mN*m]','interpreter','tex','FontSize',14);
    
      %legend('Average Moment', sprintf('Linear fit (M = %2.4f * w + %2.1f)', coeffsFitM(1), coeffsFitM(2)),'Location','NorthWest');
      % Now Calculate our power numbers (All in [W])
      powerThrust = avgFz.*sqrt(avgFz./(2*rho*(diam/2)^2));          % Theoretical power required for the thrust we made
                                                                     % --Essentially
                                                                     % power out

      powerElecIn = avgCur * voltage;                                % Electrical power put into the system
      powerRotMech = avgTz ./ 1000 .* (avgRPM .* 2*pi ./ 60);        % [N*m * rpm * (2pi rad/1rev) / (60 s / 1 min)]

      coeffThrust = avgFz ./ (rho .* (avgRPM./60).^2 .* diam^4);
      coeffPower = powerElecIn ./ (rho .* (avgRPM./60).^3 .* diam^5);

      % Now calculate whatever efficiencies we can
      effMot = powerRotMech./powerElecIn;
      figureMerit = powerThrust ./ powerElecIn;

      % Plot Some efficiencies versus RPM
      figure(2);
      title(sprintf('Static Tests for Prop: %',propName), 'FontSize',14);
      subplot(2,2,1);
      plot(avgRPM, effMot,'o','MarkerFaceColor','b');
      grid on;
      hold on;

      title('Motor Efficiency','FontSize',14);
      xlabel('\omega [RPM]','FontSize',14);
      ylabel('\eta [-]','FontSize',14);

      subplot(2,2,2);
      plot(avgRPM, figureMerit,'o','MarkerFaceColor','b');
      grid on;
      hold on;

      title('Figure of Merit','FontSize',14);
      xlabel('\omega [RPM]','FontSize',14);
      ylabel('FM','FontSize',14);
      
      % Plot |F| vs pwm commanded to ESC
      subplot(2,2,3);
      grid on;
      hold on;
      forceFitData = coeffsFitF2nd(1).*dataPwmCom.^2 + coeffsFitF2nd(2).*dataPwmCom + coeffsFitF2nd(3);
      plot(dataPwmCom,avgFMag,'o','MarkerFaceColor','b');
      plot(dataPwmCom,forceFitData,'-r','LineWidth',2);
      
      title('Commanded PWM Duty Cycle versus Magnitude of Thrust','FontSize',14);
      xlabel('PWM Duty Cycle [%]','FontSize',14);
      ylabel('|F| [N]','FontSize',14);
      legend('Magnitude of F', sprintf('2nd Order Poly: ~ %2.2f * x^2', coeffsFitF2nd(1)),'Location','NorthWest');
    
      % Plot |Mz| vs pwm commanded to ESC
      subplot(2,2,4);
      grid on;
      hold on;
      plot(dataPwmCom,magnitudeM,'o','MarkerFaceColor','b');
      momFitData = coeffsFitM2nd(1).*dataPwmCom.^2 + coeffsFitM2nd(2).*dataPwmCom + coeffsFitM2nd(3);
      plot(dataPwmCom,momFitData,'-r','LineWidth',2);

      title('Commanded PWM Duty Cycle versus Magnitude of Moment in Z','FontSize',14);
      xlabel('PWM Duty Cycle [%]','FontSize',14);
      ylabel('|M| [mN*m]','FontSize',14);
      legend('Magnitude of M', sprintf('2nd Order Poly: ~ %2.2f * x^2', coeffsFitM2nd(1)),'Location','NorthWest');

      figure(3);
      grid on;
      hold on;
      
      plot(dataPwmCom,avgRPM,'o','MarkerFaceColor','b');
      xlabel('Commanded PWM Duty Cycle','FontSize',14);
      ylabel('\Omega [RPM]','FontSize',14);
      title('Angular speed versus commanded PWM Duty Cycle to ESC','FontSize',14);
    end
    
    % If transient test data exists for this trial, load it as well.
    % TODO: Refactor the data reading into a function, because the whole
    %       transient section is literally copy and pasted.
    
    if (transientTests == 1)
        disp('Loading transient test data...');
        % Load all of our data from .csv files
        dataTranFx = csvread([fileNameStub '_Fx_trans']);     % [N]
        dataTranFy = csvread([fileNameStub '_Fy_trans']);     % [N]
        dataTranFz = csvread([fileNameStub '_Fz_trans']);     % [N]
        dataTranTx = csvread([fileNameStub '_Tx_trans']);     % [mN*m]
        dataTranTy = csvread([fileNameStub '_Ty_trans']);     % [mN*m]
        dataTranTz = csvread([fileNameStub '_Tz_trans']);     % [mN*m]
        dataTranDuty = csvread([fileNameStub '_dc_nums_trans']);
        
        % Note: Current data is given to us in voltage across
        %       a hall effect sensor.  So, we need a calibration factor
        %       to convert from voltage -> amps.  Luckily this
        %       is a linear relationship.
        dataTranCur = csvread([fileNameStub '_cur_trans']);   % [V]
        % Convert current data to amps
        dataTranCur = ampSlope*dataTranCur + ampIntercept;                             % [A]

        dataTranRPM = csvread([fileNameStub '_w_trans']);     % [RPM]
        dataTranRPMTime = csvread([fileNameStub '_t_w_trans']); % [s]

        setupTran = csvread([fileNameStub '_setup_trans']);

        numTestsTran = setupTran(1,2);
        durTestsTran = setupTran(1,3);
        sampleRateTran = setupTran(1,4);
        dcTimerMaxTran = setupTran(1,5);   % Highest number sent to the M1 as an OCR1A value
                                           % This is apparently
                                           % wrong...everywhere
        powerSupplyTran = setupTran(1,6);
        powerVoltTran = setupTran(1,7);

        % The DAC takes 0.5 seconds to start giving valid readings every
        % time you pull data from it, so we need to know how many data
        % points to ignore at the beginning of each new trial
        dacIgnoreTran = sampleRateTran * 0.5;                                      %[1/s * s = index]

        % Now, construct the average values for each duty factor (ignoring the
        % values during the 0.5s DAC recalibrate.
        avgTranFx = sum(dataTranFx(dacIgnoreTran:size(dataTranFx,1),:))./(size(dataTranFx,1)-dacIgnoreTran); %[N]: 1 x numTests
        avgTranFy = sum(dataTranFy(dacIgnoreTran:size(dataTranFy,1),:))./(size(dataTranFy,1)-dacIgnoreTran); %[N]: 1 x numTests
        avgTranFz = sum(dataTranFz(dacIgnoreTran:size(dataTranFz,1),:))./(size(dataTranFz,1)-dacIgnoreTran); %[N]: 1 x numTests

        avgTranTx = sum(dataTranTx(dacIgnoreTran:size(dataTranTx,1),:))./(size(dataTranTx,1)-dacIgnoreTran);
        avgTranTy = sum(dataTranTy(dacIgnoreTran:size(dataTranTy,1),:))./(size(dataTranTy,1)-dacIgnoreTran);
        avgTranTz = sum(dataTranTz(dacIgnoreTran:size(dataTranTz,1),:))./(size(dataTranTz,1)-dacIgnoreTran);

        avgTranRPM = sum(dataTranRPM)./size(dataTranRPM,1);                     % [RPM]
        avgTranCur = sum(dataTranCur)./size(dataTranCur,1);                     % [A]




      disp('Plotting transient response data...');
      % Plot the magnitude of the force vector versus time and pull out
      % some important response data.

      % But first, make a time vector that will align with our data points
      % properly
      tTran = 1/sampleRateTran:1/sampleRateTran:durTestsTran;
      tTran = tTran';

      figure(4);
      title(sprintf('Transient Test for Prop: %s',propName), 'FontSize',14);
      plot(tTran,sqrt(dataTranFx.^2+dataTranFy.^2+dataTranFz.^2),'.');
      grid on;
      hold on;
      xlabel('Time [s]','FontSize',14);
      ylabel('|F| [N]', 'FontSize',14);
    end
    
    success = 1;  % Success!
end