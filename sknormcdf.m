function y = sknormcdf(x,mu,sigma,alpha)
% The skew normal cumulative distribution function.

% Make it behave like a skewed standard normal if only 2 arguments are
% given.
if nargin==2, alpha = mu; mu = 0; sigma = 1; end

% Standardize x
x = (x-mu)./sigma;

% Compute function
y = normcdf(x) - 2*owens_t(x,alpha);

% Protect from lack of precision
y(y<1e-15) = 0;