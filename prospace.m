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
if nargin<6 || isempty(d)
    d = .01;
end
if nargin<5 || isempty(sigma)
    sigma = 1;
end
if nargin<4 || isempty(mu)
    mu = (lb+ub)/2;
end
if nargin<3 || isempty(n)
    n = 100;
end
if ~all([isscalar(lb),isscalar(ub),isscalar(n),isscalar(mu),isscalar(sigma),isscalar(d)])
    error('Inputs must be scalars.');
end
if mod(n,1) || n<1
    error('Number of data points must be a positive integer.');
end
if d<=0 || 1<=d
    error('Argument ''d'' specifies the inner bounds of the probit-domain such that the domain is (d,1-d). ''d'' must therefore be within the interval (0,1).');
end

%% Compute the probit-spaced vector

x = norminv(linspace( normcdf(lb,mu,sigma), normcdf(ub,mu,sigma), n), mu,sigma);
x([1,end]) = [lb,ub]; % Avoid inf values in the tails