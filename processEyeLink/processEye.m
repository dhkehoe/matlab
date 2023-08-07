function eye = processEye(file,varargin)
% Preprocess the EyeLink data within a NOISE lab data file. Specify
% optional arguments with MATLAB name-pair convention.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% USAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   eye = processEye('dataFileName');
%   eye = processEye('dataFileName','optionalArgName',optionalArgValue,...);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   file - A string specifying the filename of the NOISE lab data file.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OPTIONAL INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Screen parameters:
%   screenResolution - A 1x2 vector of screen [width,height] in pixels.
%                           default = [2560,1440]
%         screenSize - A 1x2 vector of screen [width,height] in centimeters.
%                           default = [60.8,34.3]
%     screenDistance - A scalar indicating the viewing distance between the
%                      the screen and observer in centimeters.
%                           default = 74
%
%       Smoothing options
%   temporalBW - A scalar indicating the smoothing bandwidth in the
%                temporal domain for the pupil and gaze location data.
%                Units are in seconds.
%                   default = .01 (10 milliseconds)
%    spatialBW - A scalar indicating the smoothing bandwidth in the spatial
%                domain for the gaze location data. Units are in degrees of
%                visual angle.
%                   default = .1
%
%       Saccade dectection options: (see 'saccades.m')
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   eye - 1xN array of structures containing data from N trials. The i_th
%         index contains data from the i_th trial.
%
%         Fields:
%           .t - Vector of time flags across eye samples. Sample 1
%                corresponds to "trialstart" and is time 0.
%           .p - Vector of pupil area samples.
%           .x - Vector of gaze x position samples.
%           .y - Vector of gaze y position samples.
%           .e - Vector of eye movement event code integers where
%                  -1 ... Blink
%                   0 ... Fixation
%                   1 ... Fixation drift
%                   2 ... Microsaccade
%                   3 ... Pursuit
%                   4 ... Saccade
%           .s - 1xM array of structures containing data from M detected
%                saccades on each trial. For details, see 'saccades.m'.
%           .i - Structure containing the indices of '.t', '.p', '.x', and
%                '.y' that correspond to various trial events:
%                Fields:
%                       .trialstart
%                       .trialstop
%                       .ITIstart
%                       .ITIend
%                       .fixOn
%                       .fixAcq
%                       .fixOff
%                       .targOn
%                       .targAcq
%                       .targOff
%                       .trialFeedback
%                       .totalFeedback
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXAMPLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   % Plot pupil area as a function of time after trial start for the i_th trial
%   plot( eye(i).t, eye(i).p )
%
%   % Get the time after trial start of the fixation onset for the i_th trial
%   fixon = eye(i).t( eye(i).i.fixOn );
%
%   % Realign temporal data to time after target fixation on the i_th trial
%   eye(i).t = eye(i).t - eye(i).t( eye(i).i.targAcq );
%
%   % Get average acceleration of the j_th saccade on the i_th trial
%   aa = eye(i).s(j).avgACC;
%
%   % Leave eye data unsmoothed (set 'temporalBW' optional argument to 0)
%   eye = processData('dataFileName','temporalBW',0);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (written)  Dec. 11, 2022: Created routine
%   (modified) May  10, 2023: Resolved microsaccade detection algorithm
%                             defects
%   (modified) May  10, 2023: Modified 'smooth' and 'kreg' dependencies for
%                             greatly improved memory allowance
%   (addendum) May  13, 2023: Incorporated blink detection subroutine with
%                             greatly improved detection performance
%   (replaced) Aug.  7, 2023: Replaced 'kreg' for 'krege' .mex function,
%                             which is much faster and requires a fraction
%                             of the memory
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   DHK - Dec. 11, 2022
%   devin.heinz.kehoe@umontreal.ca

%% Manage inputs
% Prioritize "~/processEyeLink/" folder on MATLAB path variable
d = which('processEye.m');
if ispc, str = '\'; else, str = '/'; end
addpath(d(1:max(strfind(d,str))));
clear d, clear str;

% Load data
if ischar(file)
    load(file); %#ok
    if exist('trial_data','var')
        trials = trial_data;
    end
    clear('file','payment','trial_data');
else
    trials = file;
    clear file;
end

% Trim error trials
trials = trials([trials(:).error]==0);

% Parse optional inputs
p = inputParser;

% Screen options
addOptional(p,'screenResolution',[2560,1440],@(x)isnumeric(x)&&numel(x)==2); % Screen [width,height] in pixels
addOptional(p,'screenSize',[60.9,34.3],@(x)isnumeric(x)&&numel(x)==2); % Screen [width,height] in cm
addOptional(p,'screenDistance',74,@(x)isnumeric(x)&&numel(x)==1); % Viewing distance (default = 57 cm)

% Smoothing options
addOptional(p,'temporalBW',.01,@(x)isnumeric(x)&&numel(x)==1); % Smoothing bandwidth in temporal domain
addOptional(p,'spatialBW',.1,@(x)isnumeric(x)&&numel(x)==1); % Smoothing bandwidth in spatial domain

% Saccade detection options
addOptional(p,'sampRate',.0005,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minVel',20,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minDur',.01,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minAmp',1,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minPeakVel',50,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'maxPeakVel',1500,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'minPeakAcc',6000,@(x)isnumeric(x)&&numel(x)==1);
addOptional(p,'maxTheta',pi/2,@(x)isnumeric(x)&&numel(x)==1);

% Parse
parse(p,varargin{:});
p = p.Results;

%% Initialize eye metrics data structure
eye = repmat(struct(...
    't',[],... % Time from trial start
    'p',[],... % Pupil data
    'x',[],... % x eye position
    'y',[],... % y eye position
    'e',[],... % ocular behavior event code
    's',saccades(nan,nan),... % Saccade info structure
    'i',struct(... Initialize data structure for timeflag indices
    'trialstart'   ,[],...
    'trialstop'    ,[],...
    'ITIstart'     ,[],...
    'ITIend'       ,[],...
    'fixOn'        ,[],...
    'fixAcq'       ,[],...
    'fixOff'       ,[],...
    'targOn'       ,[],...
    'targAcq'      ,[],...
    'targOff'      ,[],...
    'trialFeedback',[],...
    'totalFeedback',[]...
    )...
    ),1,numel(trials)); % Repeat for each trial

%% Preprocess time flags
% Define all flags
flags = {...
    'trialstart',...
    'trialstop',...
    'ITIstart',...
    'ITIend',...
    'fixOn',...
    'fixAcq',...
    'fixOff',...
    'targOn',...
    'targAcq',...
    'targOff',...
    'trialFeedbackT',...
    'totalFeedbackT'...
    };

% Ensure all relevant flags are included in 'trials'
for f = flags
    if ~any(contains(fields(trials),f{:}))
        trials = cell2struct([struct2cell(trials); num2cell(nan(1,numel(trials)))], [fieldnames(trials);f{:}]);
    end
end

% Set time flags relative to "pcTime"
flags = (...
    [...
    [trials(:).trialstart    ]; % 1
    [trials(:).trialstop     ]; % 2
    [trials(:).ITIstart      ]; % 3
    [trials(:).ITIend        ]; % 4
    [trials(:).fixOn         ]; % 5
    [trials(:).fixAcq        ]; % 6
    [trials(:).fixOff        ]; % 7
    [trials(:).targOn        ]; % 8
    [trials(:).targAcq       ]; % 9
    [trials(:).targOff       ]; % 10
    [trials(:).trialFeedbackT]; % 11
    [trials(:).totalFeedbackT]; % 12
    ] ....
    - [trials(:).pcTime]....
    )';

%% Define inline functions

% Clock alignment function to retrieve time flag indices
getTimeIndex = @(t,idx) find( min(abs(t-idx))==abs(t-idx) );

%% Specify column headers for data preprocessing
h.eye = [1,12,14,16]; % [timetag, eye_x, eye_y, pupil_diameter] columns in Eyelink('GetQueuedData')
h.t = 1; % timetag        (eyedata)
h.p = 2; % eye x position (eyedata)
h.x = 3; % eye y position (eyedata)
h.y = 4; % pupil diameter (eyedata)

h.trialstart    = 1;  % trial start       (flags)
h.trialstop     = 2;  % trial end         (flags)
h.ITIstart      = 3;  % ITI start         (flags)
h.ITIend        = 4;  % ITI end           (flags)
h.fixOn         = 5;  % fixation onset    (flags)
h.fixAcq        = 6;  % fixation acquired (flags)
h.fixOff        = 7;  % fixation offset   (flags)
h.targOn        = 8;  % target onset      (flags)
h.targAcq       = 9;  % target acquired   (flags)
h.targOff       = 10; % target offset     (flags)
h.trialFeedback = 11; % trial feedback    (flags)
h.totalFeedback = 12; % task feedback     (flags)

h.blink         = -1; % Oculomotor behavior code
h.fixation      =  0; % Oculomotor behavior code
h.fixationDrift =  1; % Oculomotor behavior code (NOT IMPLEMENTED)
h.microsaccade  =  2; % Oculomotor behavior code
h.pursuit       =  3; % Oculomotor behavior code (NOT IMPLEMENTED)
h.saccade       =  4; % Oculomotor behavior code

%% Process each trial
for i = 1:numel(trials)

    % Retrieve eye data from the i_th trial
    eyedata = trials(i).eyedata(h.eye,:)';

    % Align timetags to "trackerTime"; convert timetags from milliseconds to seconds
    eyedata(:,h.t) = (eyedata(:,h.t)-trials(i).trackerTime)/1000;

    % Get index of trial start
    eye(i).i.trialstart = getTimeIndex( eyedata(:,h.t), flags(i,h.trialstart) );

    % Trim away trials prior to "trialstart"
    eyedata = eyedata( eye(i).i.trialstart : end, :);

    % Collect all indices of "eyedata" that coincide with time flags
    eye(i).i.trialstart    = getTimeIndex( eyedata(:,h.t), flags(i,h.trialstart   ) );
    eye(i).i.trialstop     = getTimeIndex( eyedata(:,h.t), flags(i,h.trialstop    ) );
    eye(i).i.ITIstart      = getTimeIndex( eyedata(:,h.t), flags(i,h.ITIstart     ) );
    eye(i).i.ITIend        = getTimeIndex( eyedata(:,h.t), flags(i,h.ITIend       ) );
    eye(i).i.fixOn         = getTimeIndex( eyedata(:,h.t), flags(i,h.fixOn        ) );
    eye(i).i.fixAcq        = getTimeIndex( eyedata(:,h.t), flags(i,h.fixAcq       ) );
    eye(i).i.fixOff        = getTimeIndex( eyedata(:,h.t), flags(i,h.fixOff       ) );
    eye(i).i.targOn        = getTimeIndex( eyedata(:,h.t), flags(i,h.targOn       ) );
    eye(i).i.targAcq       = getTimeIndex( eyedata(:,h.t), flags(i,h.targAcq      ) );
    eye(i).i.targOff       = getTimeIndex( eyedata(:,h.t), flags(i,h.targOff      ) );
    eye(i).i.trialFeedback = getTimeIndex( eyedata(:,h.t), flags(i,h.trialFeedback) );
    eye(i).i.totalFeedback = getTimeIndex( eyedata(:,h.t), flags(i,h.totalFeedback) );

    % Realign the tracker time to time afer "trialstart"
    eyedata(:,h.t) = eyedata(:,h.t) - eyedata( eye(i).i.trialstart, h.t );

    % Collect eye metrics
    eye(i).t = eyedata(:,h.t); % Time tags
    eye(i).p = eyedata(:,h.p); % Pupil data
    [eye(i).x, eye(i).y] = pix2deg( eyedata(:,[h.x, h.y]) ); %  Cartesian eye position in degrees
    eye(i).e = zeros(size(eye(i).t)) + h.fixation; % Default oculomotor event code to fixation event

    % Smooth time series data
    if p.temporalBW

        % Smooth gaze position
        [eye(i).x, eye(i).y] = smooth( eye(i).x, eye(i).y, p.temporalBW/p.sampRate, p.spatialBW );

        % Smooth pupil size
        eye(i).p = krege( eye(i).t, eye(i).p, eye(i).t, p.temporalBW );
    end

    % Find true start/end of blinks
    [b, eye(i).b] = blinks(eye(i).p,'sampRate',p.sampRate);
    eye(i).e(b) = h.blink; % Set blinks

    % Update metrics to discard blink samples
    eye(i).p(b) = nan;
    eye(i).x(b) = nan;
    eye(i).y(b) = nan;
    clear b;

    % Get saccade info
    eye(i).s = saccades( eye(i).x, eye(i).y,...
        'sampRate',p.sampRate,...
        'minVel',p.minVel,...
        'minDur',p.minDur,...
        'minAmp',p.minAmp,...
        'minPeakVel',p.minPeakVel,...
        'maxPeakVel',p.maxPeakVel,...
        'minPeakAcc',p.minPeakAcc,...
        'maxTheta',p.maxTheta...
        );

    % Code saccade oculomotor events
    for j = 1:numel(eye(i).s)
        eye(i).e( eye(i).s(j).bins ) = h.saccade;
    end

    % Get microsaccades from 'fixation' activity
    mx = eye(i).x; % Make a copy of 'x'
    my = eye(i).y; % Make a copy of 'y'
    mx( eye(i).e ~= h.fixation ) = nan; % Only process fixation events
    my( eye(i).e ~= h.fixation ) = nan; % Only process fixation events
    eye(i).m = microsaccades( mx, my, 'method','ek');
    clear mx, clear my;

    % Code microsaccade bins
    for j = 1:numel(eye(i).m)
        eye(i).e( eye(i).m(j).bins ) = h.microsaccade;
    end

end