function varargout = rot(x,y,theta,varargin)
% Rotate the data in 'x' and 'y' by 'theta' degrees. Rotation is about the
% point (x,y) specified by 'center' (default = [0,0]). Rotated 'x' and 'y'
% are translated to 'origin' (default = [0,0]). 'degree' specifies whether
% 'theta' is in units of degrees (true) or radians (false | default). 'x' 
% and 'y' must have the same number of elements.
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
    error('Number of elements must match between inputs ''x'' and ''y''.');
end
if ~isscalar(theta) && numel(theta) ~= numel(y)
    error('Argument ''theta'' must be scalar or contain the same number of elements as arguments ''x'' and ''y''.');
end

p = inputParser;
addOptional(p,'center',[0;0],@(x)isnumeric(x)&&numel(x)==2), % Rotational center
addOptional(p,'origin',[0;0],@(x)isnumeric(x)&&numel(x)==2), % Origin of rotated coordinates
addOptional(p,'degree',    0,@(x)isnumeric(x)&&isscalar(x)), % Is degrees (true)? Otherwise, radians
parse(p,varargin{:});
p = p.Results;

p.center = p.center(:);
p.origin = p.origin(:);

if p.degree
    theta = theta/180*pi;
end

%% Compute
xy = [x(:),y(:)]' - p.center;
if isscalar(theta)
    rxy = (...
        [cos(theta), -sin(theta); sin(theta), cos(theta)] * xy + p.origin...
        )';
else
    rxy = nan(numel(x),2);
    for i = 1:size(xy,2)
        rxy(i,:) = [cos(theta(i)), -sin(theta(i)); sin(theta(i)), cos(theta(i))] *...
            xy(:,i) + p.origin;
    end
end


%%
if nargout == 2
    varargout{1} = reshape(rxy(:,1),size(x));
    varargout{2} = reshape(rxy(:,2),size(y));
else
    varargout{1} = rxy;
end