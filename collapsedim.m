function y = collapsedim(x,dim,fun)
% Compute function 'fun' along the 'dim' dimension of input array 'x',
% while simply ignoring any NaN values in 'x'. 'x' can be any number of
% dimensions.

if dim<0 || dim>numel(size(x)), error('invalid dimension'), end
    
x = shiftdim(x,dim-1);
s = size(x);
x = x(:);

if isvector(s) && nargin<2 % this is typical matlab behavior
    y = fun( x(~isnan(x)) );
    return
end

y = nan([s(2:end),1]); % the trailing 1 protects against vectors
for i = 1:numel(y)
    x_i = x( (s(1)*(i-1)+1):s(1)*i );
    y(i) = fun( x_i(~isnan(x_i)) );    
end
y = shiftdim(y,numel(s)-dim);