function y = collapsedim(x,fun,dim,nanflag)
% Compute function 'fun' along the 'dim' dimension of input array 'x',
% while simply ignoring any NaN values in 'x' when 'nanflag' is true. 'x'
% can be any number of dimensions.
%
% Consistent with MATLAB default behavior: default 'dim' is 1, for matrices
% and the non-zero sized dimension for vectors.
%
% Default 'nanflag' is false.

%% Check that we received a function handle
if ~isa(fun,'function_handle')
    error('Function argument ''fun'' must be a function handle.');
end

%% Check that the dimension argument is valid
s = size(x);
if nargin<3 || isempty(dim)
    if isvector(x)
        dim = find(s~=1);
    else
        dim = 1;
    end
end
if ~( isnumeric(dim) && isscalar(dim) ) || mod(dim,1)
    error('Dimension argument ''dim'' must be a scalar integer.');
end
if dim<0 || numel(s)<dim
    error('Dimension argument (dim = %d) is invalid for input with %d dimensions.',dim,numel(s));
end

%% Check that the nanflag argument is valid
if nargin<4  || isempty(nanflag)
    nanflag = false;
end
try
    nanflag = logical(nanflag);
    if ~isscalar(nanflag), error('a'); end
catch
    error('Argument ''nanflag'' must be a scalar that is castable to logical type.');
end
if nanflag
    filter = @rmnan;
else
    filter = @(x)x;
end


%% Compute function

% Shortcut for vectors computed along non-zero dimension
if isvector(x) && s(dim)~=1
    y = fun(filter(x));
    return
end

% Else
x = shiftdim(x,dim-1);
s = size(x);
x = x(:);

y = nan([s(2:end),1]); % The trailing 1 protects against vectors

for i = 1:numel(y)
    x_i = x( (s(1)*(i-1)+1):s(1)*i );
    y(i) = fun(filter(x_i));    
end
y = shiftdim(y,numel(s)-dim);