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
    end
    
    methods        
        %% Initialize Interface, currently user passes serialPort                
        function self = storqueInterface(serialPort)
                       
            self.serialPort = serialPort;
            self.serialBaud = 57600; % We will fix this for now
            self.serialData = '';
            self.logFile = makeLogFile();           
            
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
                warning('off', 'MATLAB:serial:fgetl:unsuccessfulRead')            
                fopen(self.ser);
                disp(strcat('Serial Port ', self.serialPort, 'Initialized'));
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
            end
            
            % Close logFile
            fclose(self.logFile);  
            
            % Re-enable Timoutwarning
            warning('off', 'MATLAB:serial:fgetl:unsuccessfulRead')            
            disp('Successful Shutdown');
        end
        
        %% Run Interface Main Loop
        function loop(self)
            % This is just a little prototype
            quit = false;
            tic
            while not(quit)
                % If serialExists :
                % Check to see if there is any serial data available
                % Note: this assumes that there are no errors in data
                %   transmission, which is probably a bad thing
                if (self.serialExists)
                    dataIn = fgetl(self.ser);
                    disp(size(dataIn));
                    if (dataIn)
                        disp(dataIn)
                        fprintf(self.logFile, dataIn);
                        tic                     
                    else
                        if (toc > 1.1)
                            % Eventually this will just be some sort of 
                            % data link update
                            disp('No More Data to read')
                            quit = true;
                        end
                    end
                else
                    % Just drop out of the loop
                    disp('No Serial to read Data')
                    quit = true;
                end
            end
            %self.close
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