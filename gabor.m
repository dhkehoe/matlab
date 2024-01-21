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
%
%     contrast - The contrast/color of the Gabor. The dimensions of
%                'contrast' indicate the mode:
%
%                (1) grayscale mode: 'contrast' is a scalar indicating 
%                grayscale contrast of the Gabor. This specifies the range
%                between the highest and lowest pixel intensity in the
%                image. This is therefore limited by the background pixel
%                intensity (see below).
%
%                (2) 'color mode': 'contrast' is a vector of length 3,
%                indicating the intensity contrast across all color
%                channels similar to the 'grayscale mode'. This gives
%                perfect control over the contrast of each color channel,
%                but means that the Gabor oscilates between the color
%                specified by 'contrast' and the RGB anti-color of
%                'contrast'. For example, if 'contrast' = [1,0,1], then the
%                Gabor oscilates between this magenta hue and its
%                anti-color, green: [0,1,0].
%               
%                (3) 'arbitrary mode': 'contrast' is a 2 by 3 matrix
%                specifying the exact colors that the Gabor oscilates
%                between. In this mode, 'contrast' does not specify
%                contrast levels at all, but gives full customization of
%                the oscilatory colors. Each row in the matrix contains one
%                of two colors. The columns correspond to the [R,G,B] color
%                values that define each color.
%
%                Regardless of the mode, 'contrast' must be bound on the
%                interval (0,1) when passed as a double. If passed as an
%                uint8, it must be bound on the interval (0,255).
%                   default = double(.5) (half intensity)
%
%
%      backgrd - The background pixel intensity. This can be either a
%                scalar or an RGB vector of length 3. These values specify
%                the background (grayscale) luminance or color that the
%                Gabor fades into. NOTE: the Gabor oscillates about this
%                value by +/- contrast/2. This value therefore suffers the
%                constraint that
%                   backgrd + contrast/2
%                cannot exceed 1 and
%                   backgrd - contrast/2
%                cannot be less than 0. As such, this function performs a
%                data integrity check  that throws an error if
%                   contrast/2 > min([backgrd 1-backgrd]).
%                These luminance/color values must be bound the interval
%                (0,1) when passed as a double. If passed as an uint8, they
%                must be bound on the interval (0,255).
%                   default = .5 (double)
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
% HISTORY
%   (written)  Nov. 11, 2021: Created routine
%   (modified) Jan. 10, 2024: Added new color Gabors
%
%
%   DHK - Nov. 11, 2021

%% Manage input
p = inputParser;
addRequired(p,'width', @(x)isscalar(x)&&isnumeric(x)&&~mod(x,1)); % image width (pixels)
addRequired(p,'height',@(x)isscalar(x)&&isnumeric(x)&&~mod(x,1)); % image height (pixels)
addRequired(p,'freq',  @(x)isscalar(x)&&isnumeric(x)); % lambda (*pixels)
addRequired(p,'sigma', @(x)(numel(x)==1||numel(x)==2)&&all(isnumeric(x))); % sigma (*pixels)
addParameter(p,'center',[0 0],@(x)numel(x)==2&&all(isnumeric(x))); % mu (*pixels)
addParameter(p,'ori',pi/2,@(x)isscalar(x)&&isnumeric(x)); % theta (radians)
addParameter(p,'phase',0, @(x)isscalar(x)&&isnumeric(x)); % psi (radians)
addParameter(p,'contrast',.5,@(x)(numel(x)==1||numel(x)==3||size(x,1)==2&&size(x,2)==3)&&isnumeric(x)&&all(0<=x(:))&&((isa(x,'double')&&all(x(:)<=1))||(isa(x,'uint8')&&all(x(:)<=1)))); % contrast (normalized 0-1)
addParameter(p,'backgrd',.5,@(x)(numel(x)==1||numel(x)==3)&&isnumeric(x)&&all(0<=x&x<=1)); % luminance (normalized 0-1)
addParameter(p,'conversion',1,@(x)isscalar(x)&&isnumeric(x)&&0<=x); % specify pixels per some arbitrary unit (e.g., pixels/degree)
addParameter(p,'format','double',@ischar); % specify the color encoding format double (0-1) or uint8 (0-255)
% *pixels indicates that pixels is the default. If a 'conversion' factor is
% given, then these args need to be in those units. E.g., if 'conversion'
% is pixels per degree, these units need to all be given in degrees.
parse(p,varargin{:});
p = p.Results;

% Convert between data types if necessary
if isa(p.contrast,'uint8')
    p.contrast = double(p.contrast)/255;
end
if isa(p.backgrd,'uint8')
    p.backgrd = double(p.backgrd)/255;
end

% Determine the color type of the Gabor
arbcolor = size(p.contrast,1)==2 && size(p.contrast,2)==3;
color = ~arbcolor && (numel(p.contrast)==3 || numel(p.backgrd)==3);
% else (grayscale)

% Check contrast levels are supported by background intensity
if ~arbcolor

    % Ensure these are vectorized
    p.contrast = p.contrast(:)';
    p.backgrd = p.backgrd(:)';

    if any( round(p.contrast/2,10) > round(min([p.backgrd; 1-p.backgrd]),10) )
        error('contrast/2 must be <= MIN{backgrd, 1-backgrd}')
    end
end

% Ensure a correct format was specified
if ~any(strcmp(p.format,{'double','uint8'}))
    error('format must be a string specifying the color encoding format: double (0-1) or uint8 (0-255)')
end

% Repeat sigma if needed
if numel(p.sigma)==1
    p.sigma = repmat(p.sigma,1,2);
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
mask = exp( -x.^2/p.sigma(2)^2 -y.^2/p.sigma(1)^2 );

% Create gabor
if arbcolor % Using 2 arbitrary alternating colors
    gb = cos(y*p.freq*2*pi+p.phase);

    gb = (  (gb /2 + .5).*shiftdim(p.contrast(1,:),-1) + (-gb /2 + .5).*shiftdim(p.contrast(2,:),-1)  ) .* mask +...
        (1-mask) .* shiftdim(p.backgrd,-1);

    gb = rescale( gb, max([min(gb(:)),0]), min([max(gb(:)),1]) );
    
elseif color % Using contrast specified across all color channels
    gb = repmat(cos(y*p.freq*2*pi+p.phase) .* mask,1,1,3) .* shiftdim(p.contrast/2,-1) + shiftdim(p.backgrd,-1);

else % Using grayscale
    gb = cos(y*p.freq*2*pi+p.phase) .* mask * p.contrast/2 + p.backgrd;
end

% Adjust color format
if strcmp(p.format,'uint8')
    gb = uint8(round(gb*255));
end

% Return
if nargout
    varargout{1} = gb;
else
    figure, imshow(gb),
end