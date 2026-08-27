function y = cgeocdf(x,p)
% Geometric cumulative distribution function with support on the positive
% reals.
%
%   See documentation for geocdf()
y = 1-(1-p).^(x+1);
y( x<0 | p<=0 | 1<p ) = nan;