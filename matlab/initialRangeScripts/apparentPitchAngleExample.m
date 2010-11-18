% By:Ian O'Hara Date:10/8/2010 Revised:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Demonstrate how pitch angle limits flight velocity due
%        to an effective decrease in pitch angle with
%          increasing flight velocity.
%
%    Needs: apparentPitchAngle.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% SET THESE %%%
pitches = [2.8 3.8 4.8 5.8 6.8 7.8];   % [in]
vels = 0:20;                           % [m/s]
r = 5.5;                               % [in]
rpm = 6000;                            % [rev/min]
styles = ['bo' 'ro' 'go' 'ko' 'mo' 'r+'];

%%% DON'T TOUCH THESE %%%
pitches = pitches .* 0.0254;           % [m]
r = r*0.0254;

figure(1);
close all;
grid on;
hold on;

title({'Apparent Prop Pitch VS Flight Velocity','(for flat plate prop)'},'FontSize',14);
xlabel('V_i_n_f [m/s]','FontSize',14);
ylabel('Pitch (Theoretical Advancement/Rev) [in]','FontSize',14);

plot(vels, apparentPitchAngle(pitches(1),r,rpm,vels),'bo','MarkerFaceColor','b');
plot(vels, apparentPitchAngle(pitches(2),r,rpm,vels),'ro','MarkerFaceColor','r');
plot(vels, apparentPitchAngle(pitches(3),r,rpm,vels),'go','MarkerFaceColor','g');
plot(vels, apparentPitchAngle(pitches(4),r,rpm,vels),'ko','MarkerFaceColor','k');
plot(vels, apparentPitchAngle(pitches(5),r,rpm,vels),'mo','MarkerFaceColor','m');
plot(vels, apparentPitchAngle(pitches(6),r,rpm,vels),'r+');

legend('p = 2.8','p = 3.8','p = 4.8','p = 5.8','p = 6.8','p = 7.8')