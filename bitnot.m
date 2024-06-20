function y = bitnot(x,n)

% Assume 16 bits
if nargin<2
    n = 16;
end

% Check that 'n' is formatted correctly
if 1<numel(n) || n<1 || logical(mod(n,1))
    error('Argument ''n'' must be a positive scalar greater than zero.');
end

% Get the size of 'x' before linearizing
s = size(x);
x = x(:);
y = nan(size(x));

% Get 'x' greater than zero
i = 0<x(:);

% Assume 2's compliment for negative numbers and flip them
if any(~i)
    y(~i) = -(x(~i)+1);
end

% For positive numbers, flip all the bits
e = repmat( 2.^(0:n-1), sum(i), 1);
y(i) = sum( ~bitand( repmat(x(i),1,n),e) .* e, 2);

% Reshape output
y = reshape(y, s);