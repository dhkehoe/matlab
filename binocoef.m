function x = binocoef(n,k)
% Get binomial coefficients for n choose k. 
%   'n' is scalar:
%       (1) If 'k' is provided, returns just the binomial coefficient for n
%           choose k. Can return coefficients for multiple values of k.
%       (2) If 'k' is omitted, returns all binomial coefficients for n 
%           choose k = 0 : n.
%
%   'n' is a matrix:
%       (1) 'k' must either be scalar or match in size to 'n'. Returns all
%           binomial coefficients for paired values of (n1,k1), (n2,k2),...
%
%   DHK - August 9, 2023

%% Manage input
if any(mod(n,1) | n < 0)
    error('Parameter ''n'' must be positive integers.');
end
if nargin<2
    k = 1:n+1; % Return all value of k; increment as it is used to index list of k = 0 : n
else
    if any(mod(k,1) | k < 0 | n < k)
        error('Parameter ''k'' must be integers bounded on the interval [0,n].');
    end
    k=k+1; % Increment as it is used to index list of k = 0 : n
end

%% Define behavior of function
if numel(n)>1
    x = nan(size(n));
    if numel(k) == numel(n) % Paired (n,k) values
        for i = 1:numel(x)
            x(i) = binocoef_(n(i),k(i));
        end
    elseif numel(k) == 1 % Multiple 'n' values on scalar 'k'
        for i = 1:numel(x)
            x(i) = binocoef_(n(i),k);
        end
    else % 'k' must either be scalar or match in size with 'n' if numel(n) > 1
        error('Number of elements in parameters ''n'' and ''k'' must match if numel(n)>1.');
    end
else % Specified values of k or (2) all values of k if isempty(k)
    x = binocoef_(n,k);
end

%% Compute coefficients
function x = binocoef_(n,k)

i = 1:n;
x = [1,cumprod( (n-i+1)./i )];

if nargin==2
    x = x(k);
end