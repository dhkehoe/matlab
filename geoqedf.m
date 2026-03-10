function [T,pvalue,Tcrit,theta_hat] = geoqedf(X,varargin)
% Performs quadratic empirical cumulative distribution inferential tests 
% (Anderson-Darling, Watson, or Cramér-von Mises) of whether the data in
% sample 'X' is drawn from a geometric distribution. The inferential alpha
% level and the theoretical theta parameter are adjustable.
%
% USAGE
% [T,pvalue,Tcrit,theta_hat] = geoqedf(X,'OptionalArgName',OptionalArgValue,...)
% 
%
% INPUT
%   X - A random sample of natural numbers.
%
%
% OPTIONAL INPUT
%   theta - The parameter of the theoretical geometric distribution with 
%           which to test the sample 'X' against. The default option is to
%           use the empirical theta computed from sample 'X': 1/mean(X+1).
%
%   alpha - The alpha level for the inferential test. (default = .05).
%
%    test - A character string specifying which QEDF test to run. The
%           options are
%               'anderson-darling' (default)
%               'watson'
%               'cramer-vonmises'
%
%           For details on these statistical tests, see
%               a) https://en.wikipedia.org/wiki/Anderson–Darling_test
%               b) https://en.wikipedia.org/wiki/Cramér–von_Mises_criterion
% 
%   print - Boolean specifying whether to print neatly formatted results to
%           the console.
%
% OUTPUT
%           T - The value of the test statistic.
%      pvalue - The cumulative probability of the test statistic.
%       Tcrit - The critical value of the test statistic given the alpha
%               level.
%   theta_hat - The empirical maximum likelihood value for the geometric
%               distribution parameter, as calculated from the sample 'X'.
%
%
% DEPENDENCIES
%   LPB4.m  - Available at https://users.ssc.wisc.edu/~behansen/progs/Qcdf.html
%             by the author Bruce E. Hansen
%
%
% REFERENCES
%
% This code is based on the theoretical work of
%   [1] H.F Coronel-Brizio, A.R. Hernández-Montoya, M.E. Rodríguez-Achach,
%       H. Tapia-McClung, J.E. Trinidad-Segovia. (2024). Anderson-Darling
%       and Watson tests for the geometric distribution with estimated
%       probability of success. PLoS One, 19(12), e0315855. 
%       doi: 10.1371/journal.pone.0315855
%
% With accompanying code snippets borrowed from
%       https://zenodo.org/records/10659806/Asymptotic.py
%
%
%   DHK - Feb 26, 2026

%% Data hygiene
X(isnan(X)|isinf(X)) = [];
if isempty(X)
    error('Insufficient valid data in ''x''.');
end
X = round(X(:)); % Force these to be integers

%% Parse optionals
arg = inputParser;
addParameter(arg,'theta',[],@(x)isnumeric(x)&&isscalar(x)); % Theta parameter for geometric distribution
addParameter(arg,'alpha',.05,@(x)isnumeric(x)&&isscalar(x)&&0<x&&x<1); % Alpha value for inferential test
addParameter(arg,'test','anderson-darling',@ischar); % {1: Anderson-Darling, 2: Watson, 3:Cramer-von Mises}
addParameter(arg,'print',true,@(x)islogical(logical(x))); % Print results? (Bool)
parse(arg,varargin{:});
arg = arg.Results;

%% Check for bad optionals
test = {'anderson-darling','watson','cramer-vonmises'};
test = find(strcmpi(arg.test,test));
if isempty(test)
    error(sprintf(['Optional argument ''test'' is invalid. It must be one of the following strings:',...
        '\n\t''anderson-darling''',...
        '\n\t''watson''',...
        '\n\t''cramer-vonmises''']));
end

%% Compute empirical distribution
N = numel(X);
x = min(X) : max(X); % Domain
p = sum( x<=X & X<x+1 ); % PDF (counts)
P = cumsum(p); % CDF
k = numel(x); % Number of discrete bins
theta_hat = 1/mean(X+1);

% Default theta parameter
if isempty(arg.theta)
    arg.theta = theta_hat;
end

%% Compute the test statistic
T = (P-geocdf(x,arg.theta)*N).^2 .* geopdf(x,arg.theta);

% Anderson-Darling weight function
if test==1
    T = T ./ ( geocdf(x,arg.theta).*(1-geocdf(x,arg.theta)) );
end

% Compute sum
T = sum(T) / N;

% Watson adjustment
if test==2
    T = T-mean(geocdf(X,arg.theta));
end

%% Compute the p-value and cutoff

% Compute V^hat matrix
p_hat = geopdf(x,arg.theta);
D_hat = diag(p_hat);
B_array = ((1-arg.theta).^x).*(1-arg.theta*x/(1-arg.theta));
V_hat = B_array * (D_hat \ B_array');
scalar = 1/V_hat;

% Calculate covariance matrix (Sigma_hat)
A = tril(ones(k));
sigma_d_hat = (D_hat - p_hat' * p_hat) - scalar * (B_array' * B_array);
sigma_u_hat = A * (sigma_d_hat * A');

% 3. Define M-hat matrix for the two statistics
E_hat = diag(p_hat);
% E_hat = eye(k);

% Obtain M matrices and eigenvalues for A2, W2, and U2
switch test
    case 1 % (A^2 - Anderson-Darling)

        % Matrix M for A2
        H_hat = cumsum(p_hat);
        K_hat = zeros(k);
        i = H_hat .* (1 - H_hat) > 0;
        K_hat(diag(i)) = 1 ./ (H_hat(i) .* (1 - H_hat(i)));
        M_A2 = E_hat * (K_hat * sigma_u_hat);

        [~,eigen_vals_A] = eig(M_A2);
        evals = eigen_vals_A(eigen_vals_A > 0);

    case 2 % (W^2 - Watson)      
        [~, eigen_vals_W] = eig(E_hat * sigma_u_hat);
        evals = eigen_vals_W(eigen_vals_W > 0);

    case 3 % (U^2 - Cramer-von Mises)

        %  M matrix
        I_minus_E11T = eye(k) - E_hat * ones(k);
        M_U2 = (I_minus_E11T * (E_hat * I_minus_E11T')) * sigma_u_hat;

        [~,eigen_vals_U]  = eig(M_U2);
        evals = eigen_vals_U(eigen_vals_U > 0);
end

%% Find critical values
pvalue = 1-LPB4(T,evals); % p-value for test-statistic
Tcrit = lsqnonlin(@(x) 1-arg.alpha-LPB4(x,evals), 0.1, .05, 4, optimoptions(@lsqnonlin,'Display','off'));

%% Print results
if arg.print
fprintf("N = %d, k = %d, theta_hat = %.3f;  T = %.3f, p %s;  critical T = %.3f (alpha = %.3f)\n",...
    N,k,theta_hat, T,pval(pvalue), Tcrit,arg.alpha);
end

% Much of this code was adopted from
%  https://zenodo.org/records/10659806/Asymptotics.py
%
%                           ORIGINAL REFERENCES
% 
% [1] M. Lesperance, W.J. Reed, M.A. Stephens, C. Tsao, B. Wilton. (2016).
%       Assessing Conformance with Benford’s Law: Goodness-Of-Fit Tests and Simultaneous Confidence Intervals. 
%       PLoS ONE 11(3), e0151235. https://doi.org/10.1371/journal.pone.0151235
% 
% [2] B. G. Lindsay, R. S. Pilla, and P. Basak. 
%       Moment-based approximations of distributions using mixtures: Theory and applications. 
%       Annals of the Institute of Statistical Mathematics, 52(2):215-230, 2000.
% 
% [3] J. P. Imhof. Computing the distribution of quadratic forms in normal variables. (1961).
%       Biometrika 48(3/4), 419-426.
% 
% [4] V. Choulakian, R.A. Lockhart, and M.A. Stephens. (1994).
%       Cram ́er-von Mises statistics for discrete distributions. 
%       Can. Jour. Statisti., 22, 125–137.
% 
% [5] R.A. Lockhart, J.J. Spinelli, and M.A. Stephens. (2007). 
%       Cram ́er-von Mises statistics for discrete distributions with unknown parameters. 
%       Can. Jour. Statisti., 35(1), 125–133.