function y = rescaledim(x,dim,l,u)
% Rescale input matrix 'x' along the dimensions specified by 'dim', with
% a rescaled lowerbound 'l' and upperbound 'u'.
%
% INPUT
%     x - A matrix of any size.
%
% OPTIONAL INPUT
%   dim - The dimensions along which to apply the rescaling. (default = 1)
%     l - The lower bound of the rescaling. (default = 0)
%     u - The upper bound of the rescaling. (default = 1)
%
% OUTPUT
%     y - The rescaled 'x' matrix of same size.
%
% EXAMPLE
%   x = rescaledim( rand(10,3,2), 1); 
%       --> x(:,j,k) is rescaled for every (j,k)
%
%   x = rescaledim( rand(10,3,2), [2,3]); 
%       --> x(i,:,:) is rescaled for every (i)
%
%   
%
%   DHK - July 5, 2024

%% Manage input

% The default with most MATLAB functions
if nargin<2 || isempty(dim)
    dim = 1;
end

% Let MATLAB catch misspecified 'dim' argument errors
try
    m = min(x,[],dim);
catch err
    error(err.message);
end

% Set 'l' and 'u' defaults
if nargin<3 || isempty(l)
    l = 0;
end
if nargin<4 || isempty(u)
    u = 1;
end

% Data integrity checks
if ~( numel(l) == 1 || eqsize(l,x) )
    error('Optional argument ''l'' must be either scalar or have the same size as input ''x''.');
end
if ~( numel(u) == 1 || eqsize(u,x) )
    error('Optional argument ''u'' must be either scalar or have the same size as input ''x''.');
end

%% Compute

% Rescale
y = (x-m) ./ (max(x,[],dim)-m);
y = y .* (u-l) + l;