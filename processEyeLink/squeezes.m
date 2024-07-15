function sqz = squeezes(x,varargin)
% Detect and analyze all BioPac dynometer squeezes in the sample of data
% passed as 'x'. Returns an Nx1 struct array where the i_th structure
% contains assorted data on the i_th squeeze event. To customize the
% detection criteria, several optional arguments can be provided using the
% MATLAB name-pair convention.
%
%
% USAGE
%   sqz = blinks(x);
%   sqz = blinks(x,'OptionalArgName',OptionalArgVal, ... );
%
%
% INPUT
%   x - Numeric matrix of any size containing continuous dynometer samples.
%       Units are assumed to be kgs.
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
%              derivative of dynometer data.
%                   (default = .02; i.e., 20 ms)
%
%     xThres - Scalar specifying dynometer force threshold below which 
%              samples are considered to be a squeeze. Units of kgs.
%                   (default = 0.25 kgs)
%
%    dxThres - Scalar specifying the dynometer force time derivative
%              threshold above which samples are considered to be a
%               squeeze. Units of kgs/s
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
addOptional(p,'sampRate', .0005, @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'minDur',   .3,    @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'bw',       .02,   @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'xthres',  0.25,   @(x)isnumeric(x)&&isscalar(x));
addOptional(p,'dxthres', 1.0,    @(x)isnumeric(x)&&isscalar(x));
parse(p, varargin{:});
p = p.Results;

p.bw     = p.bw     / p.sampRate; % Convert bandwidth from seconds into bins
p.minDur = p.minDur / p.sampRate; % Convert time threshold from seconds into bins

%% Find squeezes

% Get the force data and time bin series
x = x(:)-x(1); % Zero out force
t = 1:numel(x);

% Compute the time derivative
dx = reshape( krege(t, [0;diff(x)]/p.sampRate, t, p.bw), [],1);

% Find sequences where  (derivative > time_thres) OR (force > force_thres)
% ...AND the signal is above zero (weird edge case...)
% Pool if separated by half the time threshold
s = sequence( (p.dxthres < abs(dx) | p.xthres < x) & 0 < x,...
    p.minDur, round(p.minDur/2));

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
    sqz(i).peakVel   = max( sqz(i).vel );

    % Temporal metrics
    sqz(i).latency     = sqz(i).bins(1) * p.sampRate;
    sqz(i).duration    = s(i,3) * p.sampRate;

    if sqz(i).peakVel<0, keyboard; end
end