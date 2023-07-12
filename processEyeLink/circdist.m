function dist = circdist(a1,a2,rad)
% Utility for computing circular distance between 2 sets of angles. This
% distance is bounded on [0,pi]. Optional argument 'rad' to specify whether
% the angles are in radians (true | default) or in degrees (false).
if nargin<3 || rad
    c = 2*pi;
else
    c = 360;
end
dist = min([mod(a1-a2,c),mod(a2-a1,c)],[],2);
