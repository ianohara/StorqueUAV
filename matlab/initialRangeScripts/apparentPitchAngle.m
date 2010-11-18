% By: Ian O'Hara Date written: 10/8/2010 Revised:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           Returns apparent pitch angle due
%                    to Vinf
%
%        Arguments: pitch - Pitch of prop (not pitch angle) [m]
%                   r     - radius of prop [m]
%                   rpm   - prop revolutions per minute
%                   velInf - Airspeed [m/s]
%
%
%        Returns: pitchApparent - Apparent pitch (not pitch angle)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pitchApparent = apparentPitchAngle(pitch, r, rpm, velInf)
tipVelocity = r*(rpm*(2*pi))*(1/60);    % [m/s]
pitchAngle = atan(pitch/(2*pi*r));

angleVel = atan(velInf./tipVelocity);

pitchAngleApparent = pitchAngle - angleVel;
pitchApparent = (2*pi*r).*tan(pitchAngleApparent);
end