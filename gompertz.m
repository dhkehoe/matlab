function y = gompertz(x,a,b,c)
%   exp( -exp(  x ) ) -> Z shape, positive skew
% 1-exp( -exp(  x ) ) -> S shape, positive skew
%   exp( -exp( -x ) ) -> S shape, negative skew
% 1-exp( -exp( -x ) ) -> Z shape, negative skew
y = a.*exp(-abs(b).*exp(-c.*x));