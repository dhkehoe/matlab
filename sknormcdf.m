function y = sknormcdf(x,mu,sigma,alpha)
% The skew normal cumulative distribution function.

% Make it behave like a skewed standard normal if only 2 arguments are
% given.
if nargin==2, alpha = mu; mu = 0; sigma = 1; end
y = normcdf((x-mu)./sigma) - 2*owens_t((x-mu)./sigma,alpha);