function [] = quad_draw(psi,phi,theta,h,h2)

%curFigure = gcf;  % Store the current figure so that we can give
                      % control back to it after plotting in fh
                      
                      
%figure(h);       % Set the current figure to the storque figure
%cla(h);
%cla(h2);


L = .5;  %Arm Length [m]
w = .05; %Arm Width [m]

theta = theta*pi/180;
phi = phi*pi/180;
psi = psi*pi/180;

X = [ -w w w L L w w -w -w -L -L -w];
Y = [  L L w w -w -w -L -L -w -w w w];
Z = zeros(1,12);

BRW = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

W = BRW*[X; Y; Z;];
Xw = W(1,:);
Yw = W(2,:);
Zw = W(3,:);


set(h,'XData',Xw)
set(h,'YData',Yw)
set(h,'ZData',Zw)

set(h2,'XData',Xw)
set(h2,'YData',Yw)
set(h2,'ZData',-ones(1,12))

drawnow();
%figure(curFigure);


end