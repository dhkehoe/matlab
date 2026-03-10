function y = bnormpdf(x,bounds,mu,sigma)
% Bounded normal probability density function.

if nargin < 4 || isempty(sigma)
    sigma = 1;
end
if nargin < 3 || isempty(mu)
    mu = 0;
end
if nargin < 2 || isempty(bounds)
    bounds = [-inf,inf];
else
    if numel(bounds)~=2 || diff(bounds)<0
        error('Optional argument ''bounds'' must contain 2 elements sorted in ascending order.');
    end
end

y = normpdf(x,mu,sigma) ./ (normcdf(bounds(2),mu,sigma)-normcdf(bounds(1),mu,sigma));
y( x<bounds(1) | bounds(2)<x ) = 0;
