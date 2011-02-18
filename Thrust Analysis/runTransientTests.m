%{
Propellor Thrust Testing Script
Nov 11, 2010
Sebastian Mauchly, Ian O'Hara, Uriah Baalke
%}

%%

close all;

repository_filepath = 'C:\Users\Sebastian\Documents\School\Senior Year\Senior Design\Thrust Testing\Modlab Repository Files\prop_speed\';
path(path,repository_filepath)


motor_name = 'TAC3542-1000';
prop_name = 'MA1260TP';
trial = '_4';
trial_path = ['Trial' trial];

raw_data_folder = ['C:\Users\Sebastian\Documents\School\Senior Year\Senior Design\Thrust Testing\Raw Motor Data\',motor_name,...
    '\',prop_name, '\', trial_path,'\'];


%Test Parameters

num_tests = 1; %DO NOT CHANGE
dur_test = 10; %[s]
sample_rate = 1000;
dc_timer_max = 20000;
power_source = 0; %0 = battery, 1 = power supply
voltage = 11.1;

%ESC Limits
max_pwm = 2000;
min_pwm = 1000;
pwm_range = 2000;

%Current Sensing Calibration Factors
curSlope = .0388;
curIntercept = -3.1646;

%Initialize Force Data Arrays
F_x = zeros(dur_test*sample_rate,num_tests); % [N] Time variant force in X direction over test duration
F_y = zeros(dur_test*sample_rate,num_tests); % [N] Time variant force in Y direction over test duration
F_z = zeros(dur_test*sample_rate,num_tests); % [N] Time variant force in Z direction over test duration

T_x = zeros(dur_test*sample_rate,num_tests); % [N] Time variant moment about X axis over test duration
T_y = zeros(dur_test*sample_rate,num_tests); % [N] Time variant moment about Y axis over test duration
T_z = zeros(dur_test*sample_rate,num_tests); % [N] Time variant moment about Z axis over test duration

t_F = zeros(dur_test*sample_rate,num_tests); % [s] Timestamps of DAQ force data collection

dc_timer_nums = zeros(1,num_tests);

%USB Connection
newobj = instrfind;
if (size(newobj,1) ~= 0)
    port_statuses = newobj(:,1).status; %Read in status of all COM ports
    if (port_statuses ~= zeros(size(port_statuses)))
        fclose(newobj);
    end
end
handle = serial('COM4','Baudrate', 9600);
fopen(handle);

%Zero the DAQ
[ai, calibration, dataZero] = initAndZeroDaq;

pwm = '1';
fprintf(handle,pwm); %Set PWM to min
fprintf(handle,'u');

%PCAN Connection
CAN_Init(284); %Start CAN connection
CAN_Write(357,0,8,[0, 0, 0, 0, 0, 0, 0, 0]); %Initiate data transfer through CAN of current sensor

%%

w = [];
cur = [];
t_w = [];

for j = 1:num_tests
    
    pause(3);
    
    dc_timer_nums(1,j) = 1110 + (j-1)*50;
    dc_timer_nums(1,j)
        
    [speedTimeData speedData currentData forceTimeData forceData] = collectTestDataTrans(dur_test,sample_rate,ai,calibration,dataZero, j, handle);
    
    F_x(:,j) = forceData(:,1);
    F_y(:,j) = forceData(:,2);
    F_z(:,j) = forceData(:,3);
    
    T_x(:,j) = forceData(:,4);
    T_y(:,j) = forceData(:,5);
    T_z(:,j) = forceData(:,6);
    
    t_F(:,j) = forceTimeData;
    
    
    
    
    largest_col = size(t_w,1);
    width = size(t_w,2);
    size_of_incoming = length(speedTimeData);
    if (size_of_incoming > largest_col) %Check if we need to resize our non-pre-allocated arrays
        w = [w;zeros((size_of_incoming - largest_col),width)];
        cur = [cur;zeros((size_of_incoming - largest_col),width)];
        t_w = [t_w;zeros((size_of_incoming - largest_col),width)];
    elseif (size_of_incoming < largest_col)
        speedData = [speedData, zeros(1,(largest_col - size_of_incoming))];
        speedTimeData = [speedTimeData, zeros(1,(largest_col - size_of_incoming))];
        currentData = [currentData, zeros(1,(largest_col - size_of_incoming))];
    end
    
    w(:,j) = speedData;
    cur(:,j) = currentData;
    t_w(:,j) = speedTimeData;
    
    
    w_avg = sum(speedData)./length(speedData);
    disp(sprintf('The average RPM of the last trials was %6.2f\n',w_avg));
    answer = input(' Would you like to continue? (y/n)','s');
    if answer == 'n'
        break;
    end
    
end

fprintf(handle,'k');
fclose(handle);

CAN_Write(101,0,8,[0, 0, 0, 0, 0, 0, 0, 0]); %End data transfer through CAN of current sensor
CAN_Close; %Close CAN connection

setup = [num_tests, j, dur_test, sample_rate, dc_timer_max, power_source, voltage];

    % Note: Current data is given to us in voltage across
    %       a hall effect sensor.  So, we need a calibration factor
    %       to convert from voltage -> amps.  Luckily this
    %       is a linear relationship.
%Calibrate current data

cur = curSlope*cur + curIntercept; %[A]


csvwrite([raw_data_folder prop_name trial '_Fx' '_trans'],F_x(:,1:j));
csvwrite([raw_data_folder prop_name trial '_Fy' '_trans'],F_y(:,1:j));
csvwrite([raw_data_folder prop_name trial '_Fz' '_trans'],F_z(:,1:j));

csvwrite([raw_data_folder prop_name trial '_Tx' '_trans'],T_x(:,1:j));
csvwrite([raw_data_folder prop_name trial '_Ty' '_trans'],T_y(:,1:j));
csvwrite([raw_data_folder prop_name trial '_Tz' '_trans'],T_z(:,1:j));

csvwrite([raw_data_folder prop_name trial '_w' '_trans'],w);
csvwrite([raw_data_folder prop_name trial '_cur' '_trans'],cur);
csvwrite([raw_data_folder prop_name trial '_t_w' '_trans'],t_w);

csvwrite([raw_data_folder prop_name trial '_setup' '_trans'],setup);
csvwrite([raw_data_folder prop_name trial '_dc_nums' '_trans'],dc_timer_nums);



rmpath(repository_filepath)