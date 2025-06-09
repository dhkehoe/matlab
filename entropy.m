function H = entropy(p,b,dim)
% Compute the cross entropy of some array 'p', along the dimension 'dim',
% using the logarithm of base 'b'.

% Use the specified base
if nargin<2 || isempty(b)
    lp = log(p); % Default to natural log
else
    lp = logn(p,b);
end

% Recode -Inf as 0, which
%   (1) avoids needing to use nansum()
%   (2) ensures that if
%           all(isnan(p(i,:)))==1
%       then
%           isnan(H(i))==1
lp(isinf(lp)) = 0;

% Sum over appropriate dimension, allowing for n-dimensional arrays
if nargin<3 || isempty(dim)
    H = -sum(p.*lp); % Let MATLAB decide which dimension to use
else
    H = -sum(p.*lp,dim);
end

