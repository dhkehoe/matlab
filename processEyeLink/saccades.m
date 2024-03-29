function sacs = saccades(x,y,varargin)
% Saccade detection algorithm. Detects and analyzes all saccades in the
% sample of eye positions split into 'x' and 'y' components. Returns an
% N x 1 structure array where the i_th structure contains assorted data on
% the i_th saccade. To customize the saccade criteria, several optional
% arguments can be provided using the MATLAB name-pair convention.
%
% USAGE
%   sacs = saccades(x,y);
%   sacs = saccades(x,y,'OptionalArgName',OptionalArgValue,...);
%
% INPUT
%   x - The x components in the sample of eye positions.
%   y - The y components in the sample of eye positions.
%   
%   NOTE: 'x' and 'y' can have any number of dimensions but must have an 
%         equal number of elements.
%
% OPTIONAL INPUT
%   sampRate   - A scalar specifying the sampling rate in seconds.
%                	default = 2 kHz (.0005 seconds)
%   minVel     - A scalar specifying the minimum velocity for all eye
%                position samples in the saccade. Units are deg / second.
%                	default = 20 deg / second
%   minDur     - A scalar specifying the minimum duration of a saccade in
%                seconds.
%                   default = .01 seconds (i.e., 10 milliseconds)
%   minAmp     - A scalar specifying the minimum amplitude of a saccade in
%                degrees of visual angle.
%                	default = 1 degree of visual angle
%   minPeakVel - A scalar specifying the minimum peak velocity for a
%                saccade in units of deg / second.
%                   default = 50 deg / second
%   maxPeakVel - A scalar specifying the maximum peak velocity for a
%                saccade in units of deg / second.
%                   default = 2500 deg / second
%   minPeakAcc - A scalar specifying the minimum peak acceleration for a
%                saccade in units of deg / second^2.
%                   default = 6000 deg / second^2
%   maxTheta   - A scalar specifying the maximum instantaneous saccade
%                angle difference between any two continguous saccade
%                samples in units of radians.
%                   default = pi/2 (90 degrees)
%
% OUTPUT
%   sacs - an N x 1 structure array where the i_th element contains data on 
%          the i_th saccade. This data is split into the following fields:
%               .bins      - A vector of the indices of 'x' and 'y'
%                            containing the saccade.
%               .x         - A vector of the isolated x component of the
%                            saccade.
%               .y         - A vector of the isolated y component of the
%                            saccade.
%               .theta     - A vector of the instantaneous saccade angles.
%               .direction - A scalar indicating the overall saccade
%                            direction.
%               .duration  - A scalar indicating the duration of the
%                            saccade.
%               .amplitude - A scalar indicating the amplitude of the
%                            saccade.
%               .avg_vel   - A scalar indicating the average velocity of
%                            the saccade.
%               .peak_vel  - A scalar indicating the maximum velocity of
%                            the saccade.
%               .avg_acc   - A scalar indicating the average acceleration
%                            of the saccade.
%               .peak_acc  - A scalar indicating the maximum acceleration
%                            of the saccade.
%
%
%   DHK - May 5, 2022

%% Manage inputs
p = inputParser;
addOptional(p,'sampRate',.0005,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minVel',20,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minDur',.01,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minAmp',1,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minPeakVel',50,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'maxPeakVel',1500,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minPeakAcc',6000,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'maxTheta',pi/2,@(x)isnumeric(x)&&numel(x)==1);
parse(p,varargin{:});
p = p.Results;

nSamps = ceil(p.minDur / p.sampRate); % Convert duration into number of samples
x = x(:); % Ensure the dimensions are correct
y = y(:); % Ensure the dimensions are correct

%% Compute some initial metrics, get candidate saccades, preallocate data structure

% Compute velocity/acceleration
v = velocity(x, y, p.sampRate);
a = velocity(v, zeros(size(v)), p.sampRate);

% Compute instantaneous eye movement angles
t = [nan; mod( atan2( y(2:end)-y(1:end-1) , x(2:end)-x(1:end-1) ), 2*pi)];

% Get all candidate saccades
% Contiguous sequences of samples that are at least the minimum velocity
% 'minVel' and are directionally consistent within the max theta tolerance
% 'maxTheta', and are at least of length 'nSamps'.
seqs = sequence(v >= p.minVel & circdistvector(t) <= p.maxTheta, nSamps);

% Preallocate data structure
sacs = repmat( struct('bins',[],'x',[],'y',[],'theta',[],'deviation',[],...
    'duration',[],'amplitude',[],'avgVel',[],'peakVel',[],...
    'avgAcc',[],'peakAcc',[],'curve',[]),size(seqs,1),1);

%% Compute kinematic metrics for each potential saccade
for i = 1:numel(sacs)

    % Continuous metrics
    sacs(i).bins = seqs(i,1):seqs(i,2); % Time bins (indices)
    sacs(i).x = x(sacs(i).bins); % x position (degrees)
    sacs(i).y = y(sacs(i).bins); % y position (degrees)
    sacs(i).theta = t( sacs(i).bins ); % Instantaneous polar angle
    sacs(i).deviation = deviation(sacs(i).x,sacs(i).y);

    % Summary statistics:
    sacs(i).direction = mod(atan2( sacs(i).y(end)-sacs(i).y(1) , sacs(i).x(end)-sacs(i).x(1) ),2*pi);
    sacs(i).duration = seqs(i,3) * p.sampRate;
    sacs(i).amplitude = sqrt( (x(seqs(i,2))-x(seqs(i,1)))^2 + (y(seqs(i,2))-y(seqs(i,1)))^2 );
    sacs(i).avgVel = mean(v(seqs(i,1):seqs(i,2)));
    sacs(i).peakVel = max(v(seqs(i,1):seqs(i,2)));
    sacs(i).avgAcc = mean(a(seqs(i,1):seqs(i,2)));
    sacs(i).peakAcc = max(a(seqs(i,1):seqs(i,2)));
    sacs(i).curve = trapz(sacs(i).deviation);

    % Here we can check additional kinematic conditions to reject saccades:
    if sacs(i).amplitude < p.minAmp ||... (1) Minimum amplitude
            sacs(i).peakVel < p.minPeakVel ||... (2) Minimum peak velocity
            sacs(i).peakVel > p.maxPeakVel ||... (3) Maximum peak velocity
            sacs(i).peakAcc < p.minPeakAcc     % (4) Minimum peak acceleration
        seqs(i,:) = nan; % Brand this saccade a failure
    end
end
sacs(all(isnan(seqs),2)) = []; % Trim out rejected saccades before returning


%% Wrap circdist() function for contiguous comparisons
function d = circdistvector(t)
d = [nan; reshape( circdist(t(2:end),t(1:end-1)), [],1)];

%% Compute saccade deviations about a straight line between start- and endpoint
function d = deviation(x,y)

% Translate to origin
x = x-x(1);
y = y-y(1);

% Rotate, such that endpoint falls on x axis
t = atan2(y,x);
t = t-t(end);

% Compute y-deviations (deviations about a straight line connecting the
% start- and endpoint of the saccade). I've flipped the sign so that
% clockwise deviations are positive and counter-clockwise deviations are
% negative
d = -sin(t) .* sqrt(x.^2+y.^2);