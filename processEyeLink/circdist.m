function dist = circdist(a1,a2,rad)
% Utility for computing circular distance between 2 sets of angles. This
% distance is bounded on [0,pi]. Optional argument 'rad' to specify whether
% the angles are in radians (true | default) or in degrees (false).

% Default to radians
if nargin<3 || isempty(rad) || rad
    c = 2*pi;
else
    c = 360;
end

% Compute the circular distances
try
    dist = min(mod(a1-a2,c),mod(a2-a1,c));
catch err % Probably a size mismatch, catch and rethrow from here
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end