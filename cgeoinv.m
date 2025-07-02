function y = cgeoinv(x,p)
% Inverse geometric cumulative distribution function that maps onto the
% range of the positive reals.
%
%   See documentation for geoinv()
y = log(1-x)./log(1-p);