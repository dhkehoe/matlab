function [b, eye] = blinks(x,varargin)
% Blink detection algorithm. Detects and analyzes all blinks in the sample
% of pupil area passed as 'x'. Returns a logical array specifying all
% elements of 'x' that are classified as blink events and an Nx1 struct
% array where the i_th structure contains assorted data on the i_th blink
% blink event. To customize the blink detection criteria, several optional
% arguments can be provided using the MATLAB name-pair convention.
%
%
% USAGE
%   [b,eye] = blinks(x);
%   [b,eye] = blinks(x,'OptionalArgName',OptionalArgVal, ... );
%
%
% INPUT
%   x - Numeric matrix any of any number of dimensions containing pupil
%       samples in units of pixels. Samples must be separated by 'sampRate'
%       seconds.
%
%
% OPTIONAL INPUT
%   sampRate - Scalar specifying the eye tracker sampling rate in units of
%              seconds.
%                   (default = .0005; i.e., 2 kHz)
%
%     minDur - Scalar specifying minimum duration for blinks in units of
%              seconds.
%                   (default = .1; i.e., 100 ms)
%
%       pool - Scalar specifying the maximum interval threshold between
%              disjoint blink events below which which they are pooled into
%              a single blink event. Specified in units ofseconds. E.g., if
%              blink A ends at time .2 and blink B starts at time .25, the
%              interval between blinks is .05. If this is less than or
%              equal to 'pool', then blinks A and B are pooled together.
%                   (default = .1; i.e., 100 ms)
%
%     xThres - Scalar specifying pupil area threshold below which samples 
%              are considered to be a blink.
%                   (default = 1 pixel)
%
%    dxThres - Scalar specifying the pupil area time derivative threshold
%              above which samples are considered to be a blink.
%                   (default = 1000 pixels/second)
%
%
% OUTPUT
%     b - Logical array with the same dimensions as 'x' specifying whether
%         each sample in 'x' has been classified as a blink (true) or not
%         classified as a blink (false).
%
%   eye - Nx1 struct array where the i_th element contains data on the i_th
%         detected blink. This data is split into the following fields:
%               .bins      - A vector of the indices of 'x' and 'y'
%                            containing the blink.
%               .duration  - A scalar indicating the duration of the blink
%                            in units of seconds.
%               .p         - A vector of the isolated pupil area samples
%                            during the blink.
%               .dp        - A vector of the isolated pupil area time
%                            derivative samples during the blink.
%
%
%   DHK - May 10, 2023

%% Manage input
p = inputParser;
addOptional(p,'sampRate',.0005,@(x)isnumeric(x)&&isscalar(x)); % 2 kHz sampling rate
addOptional(p,'minDur',.1,@(x)isnumeric(x)&&isscalar(x)); % ensure blinks are at least 100 ms in duration
addOptional(p,'pool',.1,@(x)isnumeric(x)&&isscalar(x)); % pool blinks separately by less than 100 ms
addOptional(p,'xThres',100,@(x)isnumeric(x)&&isscalar(x)); % threshold: 100 pixel pupil area
addOptional(p,'dxThres',1e3,@(x)isnumeric(x)&&isscalar(x)); % threshold: 1000 pixels/second pupil area change

parse(p,varargin{:});
p = p.Results;

x = x(:); % Ensure the dimensions are correct

%% Compute blinks
dx = abs([0;x(2:end)-x(1:end-1)]/p.sampRate); % Pupil area first derivative against time
b = x<p.xThres | dx>p.dxThres; % Blink samples = area < 1 pixel OR pupil change > 1000 pixels/second

blnks = sequence( b, 1, ceil(p.pool/p.sampRate) ); % Find contiguous sequences

% If no blinks, return
if isempty(blnks)
    eye = [];
    return;
end


%% Discard short blinks (<100 ms); ensure there are no gaps within a blink event
nSamps = ceil(p.minDur / p.sampRate); % Convert duration into number of samples
for i = 1:size(blnks,1)
    if blnks(i,3) < nSamps ||... % Subthreshold blink duration
            ~any( x( blnks(i,1):blnks(i,2) ) < p.xThres ) % Blink does not contain subthreshold pupil area values
        b( blnks(i,1):blnks(i,2) ) = false; % Reset these samples as not a blink event
        blnks(i,:) = nan; % Discard this blink event
    else % Valid blink event
        b( blnks(i,1):blnks(i,2) ) = true; % Remove any gaps in Boolean array
        blnks(i,3) = blnks(i,2)-blnks(i,1); % Recalculate duration
    end
end
blnks( all(isnan(blnks),2),: ) = []; % Trim erroneous blinks

%% Set the output structure

% Initalize output structure
eye = repmat(struct('bins',[],'duration',[],'p',[],'dp',[]),...
    size(blnks,1),1);

% Fill the output structure
for i = 1:size(blnks,1)
    eye(i).bins     = blnks(i,1):blnks(i,2);
    eye(i).duration = blnks(i,3) * p.sampRate;
    eye(i).p        =  x(eye(i).bins); % Pupil area
    eye(i).dp       = dx(eye(i).bins); % Pupil area first derivative against time
end