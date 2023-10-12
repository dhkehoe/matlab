function B = repmatr(A, M, varargin)
% Repeat matrix function (MATLAB: repmat) extended to real-valued number of
% repetitions.
% 
% For example, if input matrix A is size [2,4] and
%  A = [...
%       1, 2, 3, 4;...
%       5, 6, 7, 8;...
%  ]

% and
% 
% M = [2.5, 1], then matrix A is repeated 2 and a half times along the
% first dimension:
% repmatr(A,M) = [...
%       1, 2, 3, 4;...  % row 1 repetition 1
%       5, 6, 7, 8;...  % row 2 repetition 1
%       1, 2, 3, 4;...  % row 1 repetition 2
%       5, 6, 7, 8;...  % row 2 repetition 2
%       1, 2, 3, 4;...  % row 1 repetition 2.5
%  ]
%
% If size(A) .* M contains non-integers, these values are rounded and a
% warning is raised.
%
%
%   DHK - Oct. 10, 2023

% Ensure format
if all(cellfun(@isnumeric,varargin)) && isnumeric(M)

    % Build size vector
    M = [M, cell2mat(varargin)];

    % Trim trailing 1's
    i = 0;
    while i<numel(M)-2 && M(end-i)==1
        i=i+1;
    end
    M = M(1:end-i);

else
    error('Replication factors must be numeric.')
end

% Call repmat with (potentially) extra repeats
B = repmat(A,ceil(M));

% If all whole number repetitions, exit early
if ~any(mod(M,1)) 
    return
end

% Make sure the size vectors match in length
sizeA = size(A);
sizeA = [sizeA, ones(1,numel(M)-numel(sizeA))];

% Check the wholeness of the product of 
%   (1) the size of the replicated matrix 'A' and 
%   (2) the replication-size matrix 'M'
N = sizeA.*M;
if any(mod(N,1)) % Non-integers, give warning
    warning('Product of replication size matrix and size of input matrix produces non-integers.');
end

% Build subscript reference
S.type = '()';
S.subs = cell(size(N));
for i = 1:numel(N)
    S.subs{i} = 1:round(N(i));
end

% Get the correct range subscripts
B = subsref(B,S);