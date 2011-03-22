%% Matlab Host Storque Host Interface
%{ 
    Authors:
        Uriah Baalke
        Emily Fisher
        Sebastian Mauchly
        Ian O'hara       
        Alice Yurechko        

    Purpose:
        A storque interfacing class and GUI for interacting with the
        storque
%}

classdef storqueInterface < handle

    properties
        ser
        serialPort
        serialBaud
        serialData
        serialExists
        logFile
        stream
        dataIn
        errorCount
    end
    
    methods        
        %% Initialize Interface, currently user passes serialPort                
        function self = storqueInterface(serialPort)
                       
            self.serialPort = serialPort;
            self.serialBaud = 57600; % We will fix this for now
            self.serialData = '';
            self.logFile = makeLogFile();
            self.errorCount = 0;
            self.dataIn = [];
            
            if (isempty(self.serialPort))
                self.serialExists = false;
            else
                self.serialExists = true;
            end
            
            %Initialize Serial Connection
            instrreset % Reset all connected instruments
            if (self.serialExists)
                self.ser = serial(self.serialPort);
                self.ser.BaudRate = self.serialBaud;            
                % Timeout can probably equal zero once we add more code
                self.ser.Timeout = 0.005;
                % Disable timout warning
                warning('off', 'MATLAB:serial:fgets:unsuccessfulRead')
                fopen(self.ser);
                disp(strcat('Serial Port', [' ', self.serialPort(1:4)], ' Initialized'));
            else                                
                disp('No Serial Initialized');
            end
            disp('Storque Interface Initialized')
        end       
        
        %% Close Interface
        function close(self)
            disp('Storque Interface Shutting Down')
            
            % If serial Existed ... Close Serial
            if (self.serialExists)                
                fclose(self.ser);
                delete(self.ser);
                clear self.ser;
                instrreset;
            end
            
            % Close logFile
            fclose(self.logFile);  
            
            % Re-enable Timoutwarning
            warning('on', 'MATLAB:serial:fgets:unsuccessfulRead')            
            disp('Successful Shutdown');
        end
        
        
        %% Retrieve Serial Data and Parse It
        function [angles rcis pwms batvs] = get_data(self)
            
            if (self.serialExists)
                
                %Initialize return values to 0 - if a full packet is found
                %the appropriate return will be set.
                angles = [];
                pwms = [];
                rcis = [];
                batvs = [];
                pwm_max = 1930;
                pwm_min = 1050;
                max_angle_com = .4;
                
                temp_data = fgets(self.ser);
                terminator_indices = strfind(temp_data, sprintf('\n'));
                
                %If the read detects no newlines, then simply add it to the
                %existing read data.  We'll keep adding until we get a full
                %packet, as indicated by the newline.
                if (isempty(terminator_indices))
                    self.dataIn = strcat(self.dataIn,temp_data);

                
                %Otherwise, we have a complete packet.  Take in the
                %appropriate data, parse it, and set this functions return
                %values (angles, pwms, etc.).  Take the remaining data left
                %after the first terminator and stick it in dataIn
                else
                    for i = 1:length(terminator_indices)
                        next_terminator = terminator_indices(i);
                        self.dataIn = strcat(self.dataIn,temp_data(1:next_terminator));

                        %Parse It!!

                        %IMU Packet
                        if strcmp(self.dataIn(1:4),'IMU_')
                            if self.dataIn(5) == 'd'
                                %IMU Data Packet
                                len = length(self.dataIn);
                                
                                %To avoid errors with our concatenation,
                                %underscores are used as delimeters.  Since
                                %str2num wants spaces, we replace them.
                                self.dataIn(strfind(self.dataIn(1,:),'_')) = ' ';
                                imu_data = str2num(self.dataIn(10:len));
                                if (~isempty(imu_data))
                                    angles = imu_data(1:3);
                                else
                                    self.errorCount = self.errorCount + 1;
                                    disp('Errors: ')
                                    disp(self.errorCount)
                                end
                            end

                        %RC Input Packet
                        elseif strcmp(self.dataIn(1:4),'RCI_')
                            if self.dataIn(5) == 'd'
                                %RC Input Data Packet
                                len = length(self.dataIn);
                                
                                self.dataIn(strfind(self.dataIn(1,:),'_')) = ' ';
                                rci_data = str2num(self.dataIn(10:len));
                                if (~isempty(rci_data))
                                    %disp(rci_data(1,:))
                                    rcis = rci_data(1:4);%-pwm_min)/(pwm_max-pwm_min)) - 1;
                                    %rcis = rcis * max_angle_com;% * (180/pi);
                                    %rcis(3) = pi*rcis(3) / max_angle_com;
                                else
                                    self.errorCount = self.errorCount + 1;
                                    disp('Errors: ')
                                    disp(self.errorCount)
                                end
                            end
                        %PID Packet    
                        elseif strcmp(self.dataIn(1:4),'PID_')
                            if self.dataIn(5) == 'd'
                                %PID PWMS Packet
                                len = length(self.dataIn);
                                
                                self.dataIn(strfind(self.dataIn(1,:),'_')) = ' ';
                                pid_data = str2num(self.dataIn(9:len));
                                if (~isempty(pid_data))
                                    pwms = (pid_data(1:4));%-pwm_min)/(pwm_max-pwm_min);
                                else
                                    self.errorCount = self.errorCount + 1;
                                    disp('Errors: ')
                                    disp(self.errorCount)
                                end
                            end                                                    
                        % Battery Packet
                        elseif strcmp(self.dataIn(1:4),'BAT_')
                            if self.dataIn(5) == 'd'
                                %PID PWMS Packet
                                len = length(self.dataIn);
                                
                                self.dataIn(strfind(self.dataIn(1,:),'_')) = ' ';
                                bat_data = str2num(self.dataIn(9:len));
                                if (~isempty(bat_data))
                                    battery_voltage_scale_factor = 2.44;
                                    batvs = bat_data(1:4).*battery_voltage_scale_factor;
                                else
                                    self.errorCount = self.errorCount + 1;
                                    disp('Errors: ')
                                    disp(self.errorCount)
                                end
                            end                            
                        end

                        %Now we've used dataIn, so replace whatever is in there
                        %with any of the extra data that was after the
                        %terminator
                        self.dataIn = temp_data(next_terminator+1:length(temp_data));
                    end
                end
            end
                    
            
        end
    
    end
end

%% Handle Log Directory and Creation of Log Files
function logFile = makeLogFile()
    
    if not (isdir('log'))
        mkdir ('log')
    end
    
    % Get Current Time/Date and write that into a logfilename string
    c = fix(clock);
    dir_filename = 'log/logFile';
    for n = 1:length(c)
        dir_filename = strcat(dir_filename, '-', num2str(c(n)));
    end
        
    % Create Log file with current time in name    
    logFile = fopen(dir_filename, 'w');    
end