function dist = circdist(a1,a2,rad,dim)
% Utility for computing absolute circular distance between 2 sets of
% angles in 'a1' and 'a2'. 'a1' and 'a2' must match in size or at least one
% of them must be scalar. Circular distances are bounded on [0,pi].
% Optional argument 'rad' specifies whetherthe angles are in radians (true)
% or in degrees (false) (default = true). Optional argument 'dim' specifies
% the dimension of 'a1' and 'a2' along which to perform the computation.

% Default to no dimension argument
if nargin<4
    dim = [];
end
% Default to radians
if nargin<3 || isempty(rad) || rad
    c = 2*pi;
else
    c = 360;
end

% Compute the circular distances
try
    if isempty(dim)
        dist = min(mod(a1-a2,c),mod(a2-a1,c));
    else
        dist = min(mod(a1-a2,c),mod(a2-a1,c),dim);
    end
catch err % Probably a size mismatch, catch and rethrow from here
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end