function varargout = rot(x,y,theta,origin,deg)
% Rotate the data in 'x' and 'y' by 'theta' degrees about the 'origin'
% (default = [0,0]) in 2 dimensions. 'deg' specifies whether 'theta' is in
% units of degrees (deg == TRUE) or radians (deg==FALSE | default). 'x' and
% 'y' must have the same number of elements.
%
% When 2 arguments are returned, rotated 'x' and 'y' are returned as a
% separated list {'rx', 'ry'} with the same shape as 'x' and 'y' inputs.
%
% When 1 argument is returned, rotated 'x' and 'y' are returned as an 
% N by 2 matrx 'rxy',  where 'N' is the numel(x) AND numel(y).
%
%
%   DHK - October 24, 2023

%% Manage inputs
if numel(x) ~= numel(y)
    error('Dimension mismatch between inputs ''x'' and ''y''.');
end

if nargin<5
    deg = 1;
end

if nargin<4
    origin = [0;0];
else
    origin = origin(:);
end

if deg
    theta = theta/180*pi;
end

%% Compute

xy = [x(:),y(:)]' - origin;
rxy = [cos(theta), -sin(theta); sin(theta), cos(theta)] * xy + origin;

switch nargout
    case 1
        varargout{1} = rxy';
    case 2
        varargout{1} = reshape(rxy(1,:),size(x));
        varargout{2} = reshape(rxy(2,:),size(y));
end