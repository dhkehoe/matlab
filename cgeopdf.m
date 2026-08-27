function y = cgeopdf(x,p)
% Geometric probability density function with support on the positive
% reals.
%
%   See documentation for geopdf()
y = p.*(1-p).^x;
y( x<0 | p<=0 | 1<p ) = nan;
