function cols = pickColors(n,varargin)
% Sample 'n' evenly spaced colors from the HSV color wheel.
%
% USAGE
%   cols = pickColors(n);
%   cols = pickColors(n,'OptionalArgName',optionalArgValue, ...);
%
%
%   DHK - Feb. 10, 2024

%% Manage inputs
if ~isscalar(n) || mod(n,1) || n<1
    error('Argument ''n'' specifies the number of colors and must be a positive integer.');
end

p = inputParser;
addParameter(p,'rot', .0,  @(x) isscalar(x) && 0<=x && x<=1); % Hue of color 1
addParameter(p,'sat', .75, @(x) isscalar(x) && 0<=x && x<=1); % Saturation
addParameter(p,'val', .8,  @(x) isscalar(x) && 0<=x && x<=1); % Value
addParameter(p,  'w', .95, @(x) isscalar(x) && 0<=x && x<=1); % Proportion decrease in value at CYM locations
parse(p,varargin{:});
p = p.Results;

%% Compute colors

% Compute 'n' maximally spaced HSV color thetas, rotated by 'rot'
t = mod(linspace(0,1-1/n,n)'+p.rot,1);

% Compute a circular weighting function that reduces the brightness at CYM
% locations, as they're inherently brighter than RGB locations
wval = ( cos(t*6*pi)/2+.5 ) * (p.val-p.val*p.w) + p.val*p.w;

% Select the colors
cols = hsv2rgb([t, repmat(p.sat,n,1), wval]);