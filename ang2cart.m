function varargout = ang2cart(theta,r,deg)
% Largely copies pol2cart(), but adds certain flexibility. 'theta' is an
% array of angles, 'r' is an array of radii. 'theta' and 'r' can be of any
% number of dimensions, but the dimensions must match or one of them must
% be a scalar. 'r' is optional and will be defaulted to 1. 'deg' is a
% Boolean indicating whether 'theta' is in units of radians (false|default)
% or degrees (true).
% 
% This function returns the Cartesian xy coordinates of the polar . If a single value is returned from this function, the 
% coordinates theta and r. If a single value is returned, the xy values are
% linearized and returned as an N x 2 matrix. Otherwise, the arguments are
% returned separately.
% 
%
%   DHK - March 9, 2026

if nargin<2 || isempty(r)
    r = 1;
end
if ~( isscalar(theta) || isscalar(r) || eqsize(theta,r) )
    error('The dimensions of ''theta'' and ''r'' must either match or at least one must be a scalar.');
end

%%
if nargin<3 || isempty(deg)
    deg = 0;
end
if deg
    theta = theta/pi*180;
end

%%
if nargout == 1
    varargout = { [cos(theta(:)), sin(theta(:))] .* r(:) };
else
    varargout = { cos(theta).*r, sin(theta).*r };
end