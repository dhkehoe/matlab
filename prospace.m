function x = prospace(lb,ub,n,mu,sigma)
% Probit-spaced values.
% 
% INPUT
%      lb - Lower bound of values.
%      ub - Upper bound of values.
% OPTIONAL INPUT
%       n - Number of values (scalar, positive integer).
%               Default = 100
%      mu - Center of probit-values (scalar).
%               Default = (lb+ub)/2
%   sigma - Standard deviation of probit-values (scalar).
%               Default = 1

%% Data hygiene
if nargin<5 || isempty(sigma)
    sigma = 1;
end
if nargin<4 || isempty(mu)
    mu = (lb+ub)/2;
end
if nargin<3 || isempty(n)
    n = 100;
end
if ~all([isscalar(lb),isscalar(ub),isscalar(n),isscalar(mu),isscalar(sigma)])
    error('Inputs must be scalars.');
end
if mod(n,1) || n<1
    error('Number of data points must be a positive integer.');
end

%% Compute the probit-spaced vector

x = norminv(linspace( normcdf(lb,mu,sigma), normcdf(ub,mu,sigma), n), mu,sigma);
x([1,end]) = [lb,ub]; % Avoid inf values in the tails