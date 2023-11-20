function y = repeat(x,varargin)
% Repeat a matrix of any size across any new or existing dimensions. This
% extends the MATLAB function 'repmat' to lower dimensions. For example,
% given the following usage
%   y = repeat(x,N,M);
% where 'x' is the input matrix of size S, and the replication dimensions
% are [N, M], then the output matrix 'y' is of size [N,M,S] such that 'x'
% is replicated across all lower dimensions. That is, y(i,j,:) is equal to
% 'x' for any (i,j). More specifically:
%   all( reshape( y(i,j,:) ,[],1) == x(:) )
% is true for any (i,j).
%
% The input matrix 'x' is always repeated along the last requested
% dimension in the replication list. As such, this function can exactly
% replicate the functionality of 'repmat' by requesting repetition sizes of
% 1 across all filled dimensions of input matrix 'x'. For example, assume
% input matrix 'x' has size S = [A,B]. Then the following usage
%   y = repeat(x,1,1,N);
% produces output matrix 'y' with size of [A,B,N] and is equvalent to
%   y = repmat(x,1,1,N);
%
% Replication dimensions can be passed individually or as a vector.
%
%
% USAGE:
%   y = repeat(x,N,M,...);
%   y = repeat(x,[N,M,...]);
%
% INPUT
%      x - The matrix to be replicated across each lower dimension passed
%          the size argument.
% (size) - Size of the lower replication dimensions, passed as separate
%          scalar arguments or collated into a vector.
%
% OUTPUT
%      y - The resultant matrix with 'x' replicated across the first
%          dimensions specified by (size).
%
%
%   DHK - Nov.7, 2022

%% Check inputs
try
    repmat([],varargin{:}); % Exactly replicate input argument errors thrown by repmat()
    if numel(varargin)>1 % Size input as separate arguments
            s = [varargin{:}];
    else % Size input as a vector
        s = varargin{1};
    end
catch err
    throw(err);
end

%% Process
if isempty(x), y = []; return; end % Edge case

m = size(x); % Get the size of the replicated data
if isvector(x) % Adjust for vectors to avoid y having shape [s,1,numel(m)]
    m = numel(x);
end

y = nan([s,m]); % Initialize output structure
p = prod(s); % Compute step sizes
for i = 1:numel(x) % For all replicated data
    j = p*(i-1)+1 : p*i; % Compute step sizes
    y(j) = x(i);
end