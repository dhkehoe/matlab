function sqz = squeezes(x,varargin)
% Detect and analyze all BioPac dynamometer squeezes in the sample of data
% passed as 'x'. Returns an Nx1 struct array where the i_th structure
% contains assorted data on the i_th squeeze event. To customize the
% detection criteria, several optional arguments can be provided using the
% MATLAB name-pair convention.
%
%
% USAGE
%   sqz = squeezes(x);
%   sqz = squeezes(x,'OptionalArgName',OptionalArgVal, ... );
%
%
% INPUT
%   x - Numeric matrix of any size containing continuous dynamometer
%       samples. Units are assumed to be kgs.
%
%
% OPTIONAL INPUT
%   sampRate - Scalar specifying the sampling rate in units of seconds.
%                   (default = .0005; i.e., 2 kHz)
%
%     minDur - Scalar specifying minimum duration for squeezes in units of
%              seconds.
%                   (default = .1; i.e., 300 ms)
%
%         bw - Scalar specifying the smoothing bandwidth for the time
%              derivative of dynamometer data.
%                   (default = .02; i.e., 20 ms)
%
%     xThres - Scalar specifying dynamometer force threshold above which 
%              samples are considered to be a squeeze. Units of kgs. When
%              empty, will dynamically compute the threshold as 25% of the
%              range of the data in 'x'.
%                   (default = [])
%
%    dxThres - Scalar specifying the dynamometer force time derivative
%              threshold above which samples are considered to be a
%              squeeze. Units of kgs/s.
%                   (default = 1.0 kgs/second)
%
%
% OUTPUT
%   sqz - Nx1 struct array where the i_th element contains data on the i_th
%         detected squeeze. This data is split into the following fields:
%               .bins      - A vector of the indices of 'x' containing the
%                            squeeze.
%               .force     - A vector of the isolated force samples
%                            during the squeeze.
%               .peakForce - A scalar indicating the maximum force during
%                            the squeeze.
%               .vel       - A vector of the isolated force time derivative
%                            samples during the squeeze.
%               .peakVel   - A scalar indicating the maximum velocity
%                            during the squeeze.
%               .latency   - A scalar indicating the latency between the 
%                            squeeze and the first 'x' sample in units of
%                            seconds.
%               .duration  - A scalar indicating the duration of the
%                            squeeze in units of seconds.
%
%
%   DHK - June 21, 2024

%% Manage input
if isempty(x)
    sqz = [];
    return;
end

p = inputParser;
addOptional(p,'sampRate',      .0005, @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'minDur',        .10,   @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'bw',            .02,   @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'xthres',         [],   @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'dxthres',      1.00,   @(x)isnumeric(x)&&isscalar(x));
parse(p, varargin{:});
p = p.Results;

p.bw     = p.bw     / p.sampRate; % Convert bandwidth from seconds into bins
p.minDur = p.minDur / p.sampRate; % Convert time threshold from seconds into bins

%% Find squeezes

% Compute time bins
t = 1:numel(x);

% Compute the time derivative
dx = reshape( kregt(t, [0;diff(x)]/p.sampRate, p.bw), [],1);

% Zero out force
%   Ensure that we consider reasonable samples as idle, baseline force
x = x(:) - median(x(abs(dx) < 1e-3)); % Get the baseline force level

% Dynamically set force thresholds?
%   ...empirically, this gives much better results than using constants
if isempty(p.xthres)
    b = median(x(abs(dx) < 1e-3)); % Update baseline force level
    p.xthres = (max(x)-b)/4 + b; %  25% above baseline 
end

% Find sequences where  (derivative > dx_thres) OR (force > force_thres),
%   and pool if separated by <100 ms
%   NOTE: I use OR here because the derivative has a root around the time
%   of peak force (i.e., the transition between increasing force to
%   decreasing force, squeezing then releasing).
s = sequence( p.dxthres < abs(dx) | p.xthres < x, p.minDur, round(.1/p.sampRate));

% Number of squeezes
n = size(s,1);

% Exit early and return null if there's no squeezes detected
if ~n
    sqz = [];
    return;
end

%% Fill output struct
sqz = repmat(struct(...
    'bins',     [],...
    'force',    [],...
    'peakForce',[],...
    'vel',      [],...
    'peakVel',  [],...
    'latency',  [],...
    'duration', []...
    ),n,1);

% Step through squeezes
for i = 1:n

    % Bins
    sqz(i).bins      = s(i,1) : s(i,2);
    
    % Force metrics
    sqz(i).force     = x( sqz(i).bins ); 
    sqz(i).peakForce = max( sqz(i).force );

    % Velocity metrics
    sqz(i).vel       = dx( sqz(i).bins );
    sqz(i).peakVel   = max( sqz(i).vel ); % max() ensures we consider only the rising edge (consider squeezing, ignore releasing)

    % Temporal metrics
    sqz(i).latency     = sqz(i).bins(1) * p.sampRate;
    sqz(i).duration    = s(i,3) * p.sampRate;

end