function varargout = gabor(varargin)
% Create a grayscale type uint8 Gabor filter image. Allows for very
% flexibly setting the Gabor parameters between various required and 
% some optional arguments with (mostly) reasonable default values.
%
% USAGE -------------------------------------------------------------------
%   The first 4 arguments are required and must be in the correct order:
%       gabor(width,height,freq,sigma);
%
%   Optional arguments must be given using the MATLAB name-value convention
%   and follow after the required arguments:
%       gabor(width,height,freq,sigma,'OptionalArgName',OptionalArgValue, ...);
%
%   Output is also optional. Return the image data:
%       im = gabor(width,height,freq,sigma);
%
%   Or, with no return value, simply display the image (internally, this
%   uses imshow() and creates a new figure object):
%       gabor(width,height,freq,sigma);
%   
%
%
% INPUT -------------------------------------------------------------------
%        width - The width of the image in pixels. Must be a single
%                positive integer.
%
%       height - The height of the image in pixels. Must be a single
%                positive integer.
%
%         freq - The frequency of the 2D sinusoid. This is in units of
%                pixels unless 'conversion' is provided, in which case it
%                is in units of 'conversion'. 'freq' is thus the number of
%                oscillations per unit of 'conversion'.
%
%        sigma - The spatial decay rate of the first and second axes of the
%                Gabor. The first axis is perpendicular to the angle
%                specified by 'ori' (see below). The second axis is
%                parallel to the angle specified by 'ori'. Must be either a
%                1x2 numeric vector [1st_axis,2nd_axis] or a scalar, which
%                specifies that the Gabor is circular. These value(s) are
%                in units of pixels unless 'conversion' is provided, in
%                which case it is in units of 'conversion'.
%                NOTE: If a specific aspect ratio is desired, this will
%                need to be computed by the user (i.e., there is no gamma
%                parameter as is convention in image processing).
%
%
% OPTIONAL INPUT ----------------------------------------------------------
%
%       center - The (x,y) placement of the Gabor center with respect to
%                the image. Must be 1x2 numeric vector. These values are
%                specified in Cartesian coordinates, such that (0,0) is the
%                center of the image. These are in units of pixels unless
%                'conversion' is provided, in which case they are in units
%                of 'conversion'.
%                   default = [0,0]
%
%          ori - The orientation of the Gabor in units of radians. This
%                must be a scalar.
%                   default = pi/2 (vertical)
%
%        phase - The phase of the Gabor in units of radians. This must be a
%                scalar.
%                   default = 0 (in phase)
%
%     contrast - The contrast of the Gabor. This must be a scalar in the
%                interval (0,1). This specifies the range between the
%                highest and lowest pixel intensity in the image. This is
%                therefore limited by the background pixel intensity (see
%                below).
%                   default = .5 (half intensity)
%
%      backgrd - The background pixel intensity. This must be a scalar in
%                the interval (0,1). This specifies the background
%                luminance that the Gabor fades into. NOTE: the Gabor
%                oscillates about this value by +/- contrast/2. This
%                value therefore suffers the constraint that 
%                   backgrd + contrast/2 cannot exceed 1
%                and
%                   backgrd - contrast/2 cannot be less than 0.
%                As such, this function performs a data integrity check 
%                that throws an error if
%                contrast/2 > min([backgrd 1-backgrd]).
%                   default = .5 (half contrast)
%
%   conversion - Specifies the pixel to <arbitrary unit> conversion. Must
%                be a scalar. If, for example, there are 30 pixels per
%                degree of visual angle with your display at the respective
%                viewing distance, and you'd like to conveniently define
%                Gabors using degrees, you can specify 'conversion' as 30
%                indicating that there are 30 pixels per degree. As such,
%                arguments 'center', 'freq', and 'sigma' must be all be
%                given in degrees.
%                   default = 1 (pixels)
%
%       format - Specifies the color encoding format of the Gabor. Accepted
%                values are either 'double' (0-1) or 'uint8' (0-255).
%                   default = 'double'
%
% OUTPUT ------------------------------------------------------------------
%
%   gb - An image (size 'width' x 'height') of a Gabor patch with
%        parameters as specified (see INPUT above).
%
%
%   DHK - Nov. 11, 2021

%% Manage input
p = inputParser;
addRequired(p,'width',@(x)numel(x)==1&&isnumeric(x)&&round(x)==x); % image width (pixels)
addRequired(p,'height',@(x)numel(x)==1&&isnumeric(x)&&round(x)==x); % image height (pixels)
addRequired(p,'freq',@(x)numel(x)==1&&isnumeric(x)); % lambda (*pixels)
addRequired(p,'sigma',@(x)(numel(x)==1||numel(x)==2)&&all(isnumeric(x))); % sigma (*pixels)
addParameter(p,'center',[0 0],@(x)numel(x)==2&&all(isnumeric(x))); % mu (*pixels)
addParameter(p,'ori',pi/2,@(x)numel(x)==1&&isnumeric(x)); % theta (radians)
addParameter(p,'phase',0,@(x)numel(x)==1&&isnumeric(x)); % psi (radians)
addParameter(p,'contrast',.5,@(x)numel(x)==1&&isnumeric(x)&&0<=x&&x<=1); % contrast (normalized 0-1)
addParameter(p,'backgrd',.5,@(x)numel(x)==1&&isnumeric(x)&&0<=x&&x<=1); % luminance (normalized 0-1)
addParameter(p,'conversion',1,@(x)numel(x)==1&&isnumeric(x)&&0<=x); % specify pixels per some arbitrary unit (e.g., pixels/degree)
addParameter(p,'format','double',@ischar); % specify the color encoding format double (0-1) or uint8 (0-255)
% *pixels indicates that pixels is the default. If a 'conversion' factor is
% given, then these args need to be in those units. E.g., if 'conversion'
% is pixels per degree, these units need to all be given in degrees.
parse(p,varargin{:});
p = p.Results;

if p.contrast/2>min([p.backgrd 1-p.backgrd])
    error('contrast/2 must be <= MIN{backgrd, 1-backgrd}')
end
if ~any(strcmp(p.format,{'double','uint8'}))
    error('format must be a string specifying the color encoding format: double (0-1) or uint8 (0-255)')
end

if numel(p.sigma)==1
    sigma = repmat(p.sigma,1,2);
else
    sigma = p.sigma;
end

%% Compute Gabor
% Create domain
[x,y] = meshgrid(...
    (1:p.width) -ceil(p.width /2)-p.center(1).*p.conversion,...
    (1:p.height)-ceil(p.height/2)+p.center(2).*p.conversion...
    );

% Rotate domain
theta_x = x*cos(p.ori)-y*sin(p.ori);
theta_y = x*sin(p.ori)+y*cos(p.ori);
x = theta_x./p.conversion;
y = theta_y./p.conversion;

% Create Gaussian mask
mask = exp( -x.^2/sigma(2)^2 -y.^2/sigma(1)^2 );

% Create gabor
gb = cos(y*p.freq*2*pi+p.phase) .* mask * p.contrast/2 + p.backgrd;
if strcmp(p.format,'uint8')
    gb = uint8(round(gb*255));
end

% Return
if nargout
    varargout{1} = gb;
else
    figure, imshow(gb),
end