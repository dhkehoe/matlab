function sacs = microsaccades(x,y,varargin)
% Needs documenting... see 'saccades.m' for starters

%% Manage inputs
p = inputParser;
addOptional(p,'sampRate',.0005,@(x)isnumeric(x)&&isscalar(x)); % 2 kHz
addOptional(p,'minDur',.005,@(x)isnumeric(x)&&isscalar(x)); % 5 ms
addOptional(p,'lambda',6,@(x)isnumeric(x)&&isscalar(x)); % 6 SDs (noise threshold)
addOptional(p,'maxAmp',2,@(x)isnumeric(x)&&isscalar(x)); % 1 degree visual angle
addOptional(p,'maxTheta',pi/2,@(x)isnumeric(x)&&isscalar(x)); % 90 polar degrees
addOptional(p,'method','conf',@ischar);
parse(p,varargin{:});
p = p.Results;
if ~any(strcmp(p.method,{'conf','ek'}))
    error('unrecognized ''method'' argument')
end

nSamps = ceil(p.minDur / p.sampRate); % Convert duration into number of samples
x = x(:); % Ensure the dimensions are correct
y = y(:); % Ensure the dimensions are correct

%% Compute velocity space
 
% Compute signed velocities separately for the x and y components
vx = velocity(x, zeros(size(x)), p.sampRate) .* [0; reshape( sign(x(2:end)-x(1:end-1)) ,[],1)];
vy = velocity(y, zeros(size(y)), p.sampRate) .* [0; reshape( sign(y(2:end)-y(1:end-1)) ,[],1)];

% Estimate nu parameters
if strcmp(p.method,'ek') % Engbert & Kliegl (2003) method:
	nu = [sqrt(nanmedian([vx, vy].^2) - nanmedian([vx, vy]).^2) * p.lambda, 0]; %#ok
elseif strcmp(p.method,'conf')
    % This is very similar to the E&K method but doesn't use an arbitrary
    % number of standard deviations and has the added benefit of allowing
    % the ellipse to rotate in order to better fit the data.
    [~,~,nu(1),nu(2),nu(3)] = confEllipse(vx,vy);
%     nu = [width,height,rot];
end

% Check which points fall within the ellipse
ind = (cos(nu(3))*(vx-nanmean(vx))+sin(nu(3))*(vy-nanmean(vy))).^2 / nu(1)^2 +...
    (sin(nu(3))*(vx-nanmean(vx))-cos(nu(3))*(vy-nanmean(vy))).^2 / nu(2)^2 > 1; %#ok

% Compute velocity/acceleration
v = velocity(x, y, p.sampRate);
a = velocity(v, zeros(size(v)), p.sampRate);

% Compute instantaneous eye movement angles
t = [nan; mod( atan2( y(2:end)-y(1:end-1) , x(2:end)-x(1:end-1) ), 2*pi)];

% Get all candidate microsaccades
% Contiguous sequences of samples that are outside of the noise ellipse,
% are directionally consistent within the max theta tolerance 'maxTheta',
% and are at least of length 'nSamps'.
seqs = sequence(ind & circdistvector(t) <= p.maxTheta, nSamps);

% Preallocate data structure
sacs = repmat( struct('bins',[],'x',[],'y',[],'theta',[],...
    'duration',[],'amplitude',[],'avgVel',[],'peakVel',[],...
    'avgAcc',[],'peakAcc',[],'nu',[]),size(seqs,1),1);

%% Compute kinematic metrics for each potential microsaccade
for i = 1:numel(sacs)
    sacs(i).bins = seqs(i,1):seqs(i,2);
    sacs(i).x = x(sacs(i).bins);
    sacs(i).y = y(sacs(i).bins);
    sacs(i).theta = t( sacs(i).bins ); % instantaneous polar angle
    % Summary statistics:
    sacs(i).duration = seqs(i,3) * p.sampRate;
    sacs(i).amplitude = sqrt( (x(seqs(i,2))-x(seqs(i,1)))^2 + (y(seqs(i,2))-y(seqs(i,1)))^2 );
    sacs(i).avgVel = mean(v(seqs(i,1):seqs(i,2)));
    sacs(i).peakVel = max(v(seqs(i,1):seqs(i,2)));
    sacs(i).avgAcc = mean(a(seqs(i,1):seqs(i,2)));
    sacs(i).peakAcc = max(a(seqs(i,1):seqs(i,2)));
    sacs(i).nu = nu;
    if sacs(i).amplitude > p.maxAmp
    	seqs(i,:) = nan; % Brand this saccade a failure
    end
end
sacs(all(isnan(seqs),2)) = []; % Trim out rejected saccades before returning


%% Wrap circdist() function for contiguous comparisons
function d = circdistvector(t)
d = [nan; reshape( circdist(t(2:end),t(1:end-1)), [],1)];