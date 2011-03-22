function varargout = testGUI(varargin)
% TESTGUI M-file for testGUI.fig
%      TESTGUI, by itself, creates a new TESTGUI or raises the existing
%      singleton*.
%
%      H = TESTGUI returns the handle to a new TESTGUI or the handle to
%      the existing singleton*.
%
%      TESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI.M with the given input arguments.
%
%      TESTGUI('Property','Value',...) creates a new TESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testGUI

% Last Modified by GUIDE v2.5 21-Feb-2011 23:51:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before testGUI is made visible.
function testGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testGUI (see VARARGIN)

% Choose default command line output for testGUI
handles.output = hObject;
handles.serial_interface = [];
handles.stop = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2
state = get(hObject,'Value');
if (state == 1)
    set(hObject,'BackgroundColor','r')
    set(hObject,'String','Stop')
    
    handles.serial_interface = storqueInterface('/dev/tty.usbserial-A700eCpR');
    
    cla(handles.axes1)
    set(handles.axes1,'Visible','on')
    
    [h1 h2 h_lines] = init_quad_draw(handles.axes1);
    [h1_sim h2_sim h_lines_sim] = init_quad_draw(handles.axes2);
    
    old_angles = [0 0 0];
    old_pwms = [1100 1100 1100 1100];
    old_state = zeros(1,16); old_state(7) = .4;
    control_input = [0 0 0 0 0 0];
    
    kT = 1;
    tic
    
    while ishandle(handles.axes1)

        str = get(hObject,'String');
        if strcmp(str,'Start')
            guidata(hObject,handles);
            break;
        end
        
        [angles rcis pwms bat] = handles.serial_interface.get_data();
        
        if (~isempty(angles))
            set(handles.psi,'String',num2str(angles(1)));
            set(handles.phi,'String',num2str(angles(2)));
            set(handles.theta,'String',num2str(angles(3)));
            guidata(hObject,handles);
            
            quad_draw(angles,(old_pwms([2 3 1 4]) - 1000)/1100,[0 0 0],h1,h2,h_lines)
            old_angles = angles;
        end
        
        if (~isempty(pwms))
            set(handles.PWM1,'String',strcat(num2str(pwms(1),'%4.3f'),'%'));
            set(handles.PWM2,'String',strcat(num2str(pwms(2),'%4.3f'),'%'));
            set(handles.PWM3,'String',strcat(num2str(pwms(3),'%4.3f'),'%'));
            set(handles.PWM4,'String',strcat(num2str(pwms(4),'%4.3f'),'%'));
            guidata(hObject,handles);

            quad_draw(old_angles,(pwms([2 3 1 4]) - 1000)/(1100),[0 0 0],h1,h2,h_lines);
            old_pwms = pwms;
        end
        
        if (~isempty(rcis))
            control_input(4:6) = rcis([1, 2, 4]);
        end
        
        %dt = toc;
        %new_state = rk4Step(old_state,control_input,@StorqueStep,dt);
        %tic
    
        %Enforce periodicity on the angular coordinates
        %for j = 7:9
            %if new_state(j) > pi
                %new_state(j) = new_state(j) - 2*pi;
            %elseif new_state(j) < -pi
                %new_state(j) = new_state(j) + 2*pi;
            %end
        %end
    
        %UPDATE THE OLD STATE, DAMNIT
        %old_state = new_state;

        % Draw our new quadrotor.  There's some really weird stuff going on
        % here, which should be carefully noted.  Due to some inconsistencies
        % between Ian's development and mine, my quad_draw function needs a
        % funky order for a lot of the inputs.  quad_draw accepts:
        %   3 ZXY Euler Angles in DEGREES, ordered as [psi phi theta]
        %   4 Thrusts of the motors ordered T1, T4, T2, T3 (here we compute them
        %     using the omegas that are output by rk4Step, and their absolute
        %     magnitude is generally not important except that they be visible in
        %     the plot)
        %   3 World Position coordinates x, y and z
        %   1 Handle to a "quadrotor-looking" patch graphics object that is a child of
        %     the current figure
        %   1 Handle to a "quadrotor's-shadow-looking" patch
        %   1 Vector of Handles to 4 Line Objects that will be drawn as the
        %     thrusts
        %quad_draw(180*new_state([9 7 8])/pi,kT*(new_state([13, 16, 14, 15]).^2),new_state(1:3),h1,h2,h_lines);

    end

else
    set(hObject,'BackgroundColor','g')
    set(hObject,'String','Start')

end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isempty(handles.serial_interface))
    handles.serial_interface.close();
    handles.serial_interface = [];
    guidata(hObject,handles);
    
end

fig = handles.figure1;
close(fig)
