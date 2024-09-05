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
if isscalar(n) && ( n<1 || mod(n,1) )
    error('Scalar argument ''n'' specifies the number of colors and must be a positive integer.');
end

p = inputParser;
addParameter(p,'rot', .0,  @(x) isscalar(x) && 0<=x && x<=1); % Hue rotation of color 1
addParameter(p,'sat', .75, @(x) all( 0<=x & x<=1 )); % Saturation
addParameter(p,'val', .8,  @(x) all( 0<=x & x<=1 )); % Value
addParameter(p,  'w', .8, @(x) isscalar(x) && 0<=x && x<=1); % Proportion decrease in value at CYM locations
parse(p,varargin{:});
p = p.Results;

%% Compute colors

% Compute 'n' maximally spaced HSV color thetas, rotated by 'rot'
if 1<numel(n)
    t = mod(abs(n(:))+p.rot,1);
    n = numel(n);
else
    t = mod(linspace(0,1-1/n,n)'+p.rot,1);
end

% Ensure format of Saturation values
if isscalar(p.sat)
    p.sat = repmat(p.sat,n,1);
elseif numel(p.sat) ~= n
    error('Optional argument ''sat'' must contain as many elements as ''n'' when ''n'' is non-scalar.');
end

% Ensure format of Value values
if isscalar(p.val)
    p.val = repmat(p.val,n,1);
elseif numel(p.val) ~= n
    error('Optional argument ''val'' must contain as many elements as ''n'' when ''n'' is non-scalar.');
else
    p.val = p.val(:);
end

% Compute a circular weighting function that reduces the brightness at CYM
% locations, as they're inherently brighter than RGB locations
lb = p.val*p.w;
wval = rescale(triwave(t,1/3,1/4)) .* (p.val - lb) + lb;

% Select the colors
cols = hsv2rgb([t, p.sat(:), wval]);