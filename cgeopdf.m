function y = cgeopdf(x,p)
% Geometric probability density function with support on the positive
% reals.
%
%   See documentation for geopdf()
y = p.*(1-p).^x;
