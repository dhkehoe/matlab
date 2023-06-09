function y = repeat(mat,varargin)
% Repeat a matrix of any size across lower dimensions. If 'mat' is the
% input matrix and is of size S, and the replication dimensions are (N,M),
% then 'y' is of size [N,M,S] and 'mat' is replicated across all lower
% dimensions such that
%   squeeze(y(i,j,:)) == mat(:)
% for any (i,j).
%
% Replication dimensions can be passed individually or as a vector.
%
%
% USAGE:
%   y = repeat(x,N,M,...);
%   y = repeat(x,[N,M,...]);
%
% INPUT
%    mat - The matrix to be replicated across each lower dimension passed
%          the size argument.
% (size) - Size of the lower replication dimensions, passed as a separate
%          scalar arguments or collated into a vector.
%
% OUTPUT
%      y - The resultant matrix with 'mat' replicated across the first
%          dimensions specified by (size).
%
%
%   DHK - Nov.7, 2022

%% Check inputs
if isempty(mat), y = []; return; end

if isempty(varargin) % No size arguments provided
    error('Not enough input arguments.');
elseif all(cellfun(@isnumeric,varargin)) % Check size arguments
    if numel(varargin)>1 % Size input as separate arguments
        s = [varargin{:}];
    else % Size input as a vector
        s = varargin{1};
    end
else, error('Replication factors must be numeric.');
end

%% Process
m = size(mat); % Get the size of the replicated data
if isscalar(mat) % Adjust for scalars
    m = 1;
elseif isvector(mat) % and for vectors
    m = m(m>1);
end

y = nan([s,m]); % Initialize output structure
p = prod(s); % Compute step sizes
for i = 1:numel(mat) % For all replicated data
    j = p*(i-1)+1 : p*i; % Compute step sizes
    y(j) = mat(i);
end