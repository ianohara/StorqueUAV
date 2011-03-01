function [handle handle2 line_handle] = init_quad_draw(axes_handle)

L = .5;  %Arm Length [m]
w = .05; %Arm Width [m]

pwm = [.4 .4 .4 .4];

X = [ -w w w L L w w -w -w -L -L -w];
Y = [  L L w w -w -w -L -L -w -w w w];
Z = zeros(1,12);

XL = [0 L 0 -L; 0 L 0 -L;];

YL = [L 0 -L 0; L 0 -L 0;];

ZL = [0 0 0 0;pwm];

Z_shad = -ones(1,12);

axes(axes_handle)

handle = patch(X,Y,Z,'r');
handle2 = patch(X,Y,Z_shad,'b');
line_handle = line(XL,YL,ZL);
set(line_handle,'LineWidth',2)

axis_matrix = 10*[-1 1 -1 1 -1 1];

axis(axis_matrix)
grid on


end