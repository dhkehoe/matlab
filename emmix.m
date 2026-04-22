function stats = emmix(x,n,dist,varargin)
% Expectation-maximization (EM) algorithm for fitting mixture-models to the
% data in 'x', with an arbitrary nuber of mixture components 'n', and where
% the PDF characterizing components is specified by 'dist'. This function 
% only supports mixtures of expoential family distributions that have
% closed-form solutions for maximum-likelihood parameters. Several
% algorithmic parameters can be optionally specifed with the MATLAB
% name-pair convention.
%
% USAGE
%   stats = emmix(x,n,dist);
%   stats = emmix(x,n,dist, 'OptionalArgName', OptionalArgValue, ...);
%
% INPUTS
%      x - A matrix of data that the mixture model is fit to. Can be any
%          number of dimensions.
%
%      n - The number of mixture components. Must be a positive scalar,
%          greater than 0.
%
%   dist - A string specifying the type of probability density function
%          that characterizes each mixture component. Supported options are
%               1) norm : normal PDF
%               2) geo  : geometric PMF
%
%
% OPTIONAL ARGUMENTS
%      seed - A scalar to seed the RNG for reproducibility. Many valid
%             formats exist (see rng.m). The default behavior is to
%             initialize the RNG with
%                   rng('shuffle');
%
%     nSeed - The number of randomized parameters guesses to iterate over 
%             with the EM algorithm. Multiple initial parameter guesses 
%             helps ensure that a true global maximum likelihood solution
%             is found and not a local maximum. Must be a numeric scalar
%             greater than 0.
%                   default = 10
%
%     nIter - The maximum number of iterations for each instance of the EM
%             algorithm. Must be a numeric scalar greater than 0.
%                   default = 1000
%
%   deltaLL - The minimum improvement in log-likelihood between iterations
%             required for the algorithm to proceed. Otherwise, the
%             algorithm terminates.
%                   default = 1e-6
%
%     print - A Boolean scalar indicating whether to print to console
%             the status of the algorithmic runtime (i.e., current seed
%             value, number of iterations, current global maximum
%             log-likelihood, seed-specific maximum log-likelihood).
%                   default = false
%
% OUTPUT
%   stats - A struct containing information about the algorithmic
%           exectution. The fields are:
%
%               params - The maximum likelihood set of parameters computed
%                        by the algorithm. They are arranged into an M by N
%                        matrix, where N is the number of components, and M
%                        is the number of parameters for each component.
%                        The Mth component is always the mixture weight.
%                        The remaining parameters are arranged in the order
%                        specified by the relevant PDF function in the
%                        Statistics and Machine Learning toolbox. For
%                        example, when fitting 'norm' mixtures, the 1 : M-1
%                        components are [mu; sigma], as specified by
%                        normpdf().
%
%               labels - A vector of class labels, with the same number of
%                        elements as input data 'x'. All labels are 
%                        integers in the interval (1,n), where 'n' is the 
%                        number of mixture components. The ith label
%                        indicates which mixture component has the highest
%                        likelihood for generating the datum x_i.
%
%                   LL - The global maximum log-likelihood for the
%                        parameters in 'params', given the data 'x'.
%
%                   ll - An 'nIter' by 'nSeeds' matrix that contains the
%                        log-likelihood at each iteration, for each seed.
%
%                 iter - A vector of length 'nSeeds' indicating the number
%                        of iterations prior to termination, for each seed.
%
%                seeds - An M by N by 'nSeeds' matrix containing the set of
%                        initial seed parameter values for each run of the
%                        EM algorithm.
%
%
%   DHK - April 21, 2026

%% Parse inputs
x = x(:);
x( isinf(x) | isnan(x) ) = [];

% Check validity of 'n'
if ~( isscalar(n) && isnumeric(n) && 0<n ) || mod(n,1)
    error('Argument ''n'' must be a positive integer.');
end

% Check validity of 'dist'
if ~( ischar(dist) || isstring(dist) ) 
    error('Argument ''dist'' must be a string.');
end
d = find(strcmpi(dist,{'norm','geo'}),1);
if isempty(d) 
    error(sprintf(['Unknown value for argument ''dist''. ',...
        'Argument ''dist'' must be one of the following strings:\n\t',...
        '''norm'', ''geo''.']));
end

% Get number of parameters
m = nargin(eval(['@',dist,'pdf'])); % Number of parameters

% Check for sufficient data
N = numel(x);
if N <= n*m
    error('Insufficient valid data for fitting');
end

%% Parse optional arguments
p = inputParser;
addParameter(p,'seed',[],@isscalar); % Seed value for rng() replicability
addParameter(p,'nseed',1e1,@(x)isnumeric(x)&&isscalar(x)&&0<x); % Number of seeds
addParameter(p,'niter',1e3,@(x)isnumeric(x)&&isscalar(x)&&0<x); % Number of iterations for each seed
addParameter(p,'deltaLL',1e-6,@(x)isnumeric(x)&&isscalar(x)); % Change in log-likelihood
addParameter(p,'print',false,@(x)islogical(logical(x))&&isscalar(x)); % Print iterations?
parse(p,varargin{:});
p = p.Results;

% Randomize seed?
origSeed = rng;
if isempty(p.seed)
    rng('shuffle');
else
    try
        rng(p.seed);
    catch 
        error('Optional argument ''seed'' is invalid as input for rng().');
    end
end

%% Define critical functions

% (1) Initial parameter generating function (pgen)
% (2) Parameter updating function (pdat)
switch d
    case 1 % normpdf()
        pgen = @(x,n) [rand(1,n)*range(x)+min(x); std(x)*max(.1,rand(1,n))];
        pdat = @normupdate;
    case 2 %  geopdf()
        pgen = @(x,n) rand(1,n);
        pdat = @(x,g) 1./(  sum( (x+1).*g ) ./ sum(g)  );
end

% Define conditional probability function
F = repmat('p(%d),',1,m-1); % Format parameter inputs
F = strrep(sprintf([dist,'pdf(x,',F(1:end-1),')*p(%d)\n'],1:m*n),newline,',');
F = eval(['@(x,p) [',F(1:end-1),'];']);

% Define log-likelihood function
llf = @(P) sum(log( sum(P,2) )); 

%% Fit

% Grand maximum log-likelihood, over all seeds/iterations
LL = -inf; 

% Initialize output structure
stats = struct(...
    'params',   [],...
    'labels',   [],...
    'LL',       [],...
    'll',       nan(p.niter,p.nseed),... log-likelihood at each iteration, for each seed
    'iter',     zeros(1,p.nseed),... number of iterations for each seed
    'seeds',    nan(m,n,p.nseed) ... each set of seed parameter values
    ); 

% Step through seeds
for i = 1:p.nseed
    
    % Iterative log-likelihood
    ll = [inf; nan(p.niter-1,1)];

    % Ensure we generate parameter guesses that don't sabotage this run by
    % pushing the log-likelihood to -Inf. This happens when
    %   P(Z_ij | x_i) = 0,  for all j, for some i 
    while isinf(ll(1))

        % Initial parameter guesses
        P = rand(1,n);
        P = [pgen(x,n); P/sum(P)];

        % Initialize
        ll(1) = llf(F(x,P));
    end

    % Record the (verified) seeded parameter values
    stats.seeds(:,:,i) = P;

    % Start EM algorithm for this seed
    for j = 2 : p.niter

        % Expectation-step
        g = F(x,P); % Joint probability: P(Z,X)
        g = g ./ sum(g,2); % Conditional probability: P(Z|X)
        [~,l] = max(g,[],2); % Labels

        % Maximization-step
        tP = [pdat(x,g); sum(g)./N]; % [theta; pi]

        % Update
        ll(j) = llf(F(x,tP));

        % If likelihood increased above threshold
        if p.deltaLL < diff(ll(j-1:j))
            % Update parameters
            P = tP;
        else % No change, saturated, break
            break;
        end
    end

    % Upon exiting iteration loop, check if this seed produced new global
    % maximum
    if LL<ll(j)
        % Update global maximum
        LL = ll(j);

        % Capture everything from this iteration, as it's the new winner
        stats.params = P;  % Parameters
        stats.label  = l;  % Labels
        stats.LL     = LL; % Log-likelihood
    end

    % Count iterations
    stats.iter(i) = j;
    % Get the log-likelihood across iterations
    stats.ll(:,i) = ll;

    % Status output
    if p.print
        fprintf('seed = %3d,  iter = %3d, global max LL = %.4f, iteration max LL = %.4f\n',i,j, LL,ll(j));
    end
end

%% Wrap up

% Reset seed value
rng(origSeed);


%% Utilities
function p = normupdate(x,g)
% Maximization step for normpdf mixture, which cannot be inlined
G = sum(g);
p = sum(x.*g) ./ G; % mu
p = [p; sqrt( sum( (x-p).^2 .* g ) ./ G )]; % [mu; sigma]