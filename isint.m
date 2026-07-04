function b = isint(x,prec)
% Determine whether input is an integer, regardless of datatype.
if nargin<2 || isempty(prec)
    prec = eps;
end
b = mod(x,1) < prec;