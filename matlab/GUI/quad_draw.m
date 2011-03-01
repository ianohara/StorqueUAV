function [] = quad_draw(angles,pwm,pos,h,h2,h_line)

%Scale pwms to range from 0 to .4
pwm = .6*pwm;

%Scale Angles into Radians
psi = (angles(1))*pi/180;
phi = (angles(2))*pi/180;
theta = (angles(3))*pi/180;

hl = h_line';

L = .5;  %Arm Length [m]
w = .05; %Arm Width [m]

X = [ -w w w L L w w -w -w -L -L -w];
Y = [  L L w w -w -w -L -L -w -w w w];
Z = zeros(1,12);

XL = [0 L 0 -L; 0 L 0 -L;];

YL = [L 0 -L 0; L 0 -L 0;];

ZL = [0 0 0 0;pwm];

XL1 = XL(:,1)';
XL2 = XL(:,2)';
XL3 = XL(:,3)';
XL4 = XL(:,4)';

YL1 = YL(:,1)';
YL2 = YL(:,2)';
YL3 = YL(:,3)';
YL4 = YL(:,4)';

ZL1 = ZL(:,1)';
ZL2 = ZL(:,2)';
ZL3 = ZL(:,3)';
ZL4 = ZL(:,4)';

BRW = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

W = BRW*[X; Y; Z;];
W1 = BRW*[XL1; YL1; ZL1;];
W2 = BRW*[XL2; YL2; ZL2;];
W3 = BRW*[XL3; YL3; ZL3;];
W4 = BRW*[XL4; YL4; ZL4;];

Xw = W(1,:) + pos(1);
Yw = W(2,:) + pos(2);
Zw = W(3,:) + pos(3);

Xw1 = W1(1,:) + pos(1);
Yw1 = W1(2,:) + pos(2);
Zw1 = W1(3,:) + pos(3);

Xw2 = W2(1,:) + pos(1);
Yw2 = W2(2,:) + pos(2);
Zw2 = W2(3,:) + pos(3);

Xw3 = W3(1,:) + pos(1);
Yw3 = W3(2,:) + pos(2);
Zw3 = W3(3,:) + pos(3);

Xw4 = W4(1,:) + pos(1);
Yw4 = W4(2,:) + pos(2);
Zw4 = W4(3,:) + pos(3);


set(h,'XData',Xw)
set(h,'YData',Yw)
set(h,'ZData',Zw)

set(hl(1),'XData',Xw1)
set(hl(1),'YData',Yw1)
set(hl(1),'ZData',Zw1)

set(hl(2),'XData',Xw2)
set(hl(2),'YData',Yw2)
set(hl(2),'ZData',Zw2)

set(hl(3),'XData',Xw3)
set(hl(3),'YData',Yw3)
set(hl(3),'ZData',Zw3)

set(hl(4),'XData',Xw4)
set(hl(4),'YData',Yw4)
set(hl(4),'ZData',Zw4)

set(h2,'XData',Xw)
set(h2,'YData',Yw)
set(h2,'ZData',-ones(1,12))

axis_m = 2*[-1 1 -1 1 -1 1] + [pos(1) pos(1) pos(2) pos(2) pos(3) pos(3)];

axis(axis_m)

drawnow();

end