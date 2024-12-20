function y = gnormcdf(x,mu,sigma,beta)
% Cumulative distribution function of a generalized normal random variable.
y = .5 + sign(x-mu)/2 .* gammainc( abs( (x-mu)./(sqrt(2)*abs(sigma)) ).^beta, 1/beta );