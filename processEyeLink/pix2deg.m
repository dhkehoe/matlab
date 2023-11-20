function varargout = pix2deg(xy,varargin)
%
%
% OPTIONAL INPUT
%   screenResolution - A 1x2 vector of screen [width,height] in pixels.
%                           default = [2560,1440]
%         screenSize - A 1x2 vector of screen [width,height] in centimeters.
%                           default = [60.8,34.3]
%     screenDistance - A scalar indicating the viewing distance between the
%                      the screen and observer in centimeters.
%                           default = 74
%          rect2cart - A scalar logical indicating whether to convert from
%                      PsychToolBox 'rect' coordinates to Cartesian, where
%                      'rect' has the top-left pixel as [0,0] and the
%                      bottom-right pixel as [screenResolution].
%
%
%   DHK - May 8, 2023

% Check format
if numel(size(xy)) ~= 2 || size(xy,2) ~= 2
    error('Incorrect format for gaze position data. ''xy'' must be an Nx2 matrix with columns corresponding to [x,y] positions.')
end

%% Manage inputs
p = inputParser;
addOptional(p,'screenResolution',[2560,1440],@(x)isnumeric(x)&&numel(x)==2); % Screen [width,height] in pixels
addOptional(p,'screenSize',[60.9,34.3],@(x)isnumeric(x)&&numel(x)==2); % Screen [width,height] in cm
addOptional(p,'screenDistance',74,@(x)isnumeric(x)&&numel(x)==1); % Viewing distance (default = 74 cm)
addOptional(p,'rect2cart',1,@(x)numel(x)==1&&islogical(logical(x))); % Convert from PTB 'rect' into Cartesian?
parse(p,varargin{:});
p = p.Results;

% Check whether to adjust for rect coordinates
if p.rect2cart
    xy = (xy-p.screenResolution/2) .* [1,-1];
end

%% Convert pixels-to-degrees
x = atan2d(xy(:,1)*p.screenSize(1)/p.screenResolution(1),p.screenDistance);
y = atan2d(xy(:,2)*p.screenSize(2)/p.screenResolution(2),p.screenDistance);

%% Return {x,y} or [x,y] ?
switch nargout
    case 1
        varargout{1} = [x(:),y(:)];
    case 2
        varargout{1} = x;
        varargout{2} = y;
end