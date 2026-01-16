function y = vmpdf(x,mu,kappa)
% Univariate von Mises probability density function: circular distribution
% on the surface of a circle.
%
% INPUT
%       x - Matrix of any size containing data.
%      mu - Scalar location parameter.
%   kappa - Scalar dispersion parameter.

if nargin<2 || isempty(kappa)
    kappa = 1;
end
if nargin<2 || isempty(mu)
    mu = 0;
end

y = exp( kappa.*cos(x-mu) ) ./ ( 2*pi * besseli(0,kappa) );