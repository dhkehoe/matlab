function dist = circdist(a1,a2,rad)
% Utility for computing circular distance between 2 sets of angles. This
% distance is bounded on [0,pi]. Optional argument 'rad' to specify whether
% the angles are in radians (true | default) or in degrees (false).

% Set units
if nargin<3 || rad
    c = 2*pi; % Default to radians
else
    c = 360;
end

% Get the shape of the matrix
s = size(a1);

% Vectorize
a1 = a1(:);
a2 = a2(:);

% Ensure equal number of elements
if numel(a1)~=numel(a2)
    error('Dimension mismatch between inputs ''a1'' and ''a2''.');
end

% Compute the circular distances
dist = reshape( min([mod(a1-a2,c),mod(a2-a1,c)],[],2), s);