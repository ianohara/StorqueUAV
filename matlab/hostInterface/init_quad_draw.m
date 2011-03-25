function [handle handle2] = init_quad_draw()

L = .5;  %Arm Length [m]
w = .05; %Arm Width [m]

X = [ -w w w L L w w -w -w -L -L -w];
Y = [  L L w w -w -w -L -L -w -w w w];
Z = zeros(1,12);

Z_shad = -ones(1,12);

handle2 = patch(X,Y,Z_shad,'b');
handle = patch(X,Y,Z,'r');

axis([-1 1 -1 1 -1 1])
grid on


end