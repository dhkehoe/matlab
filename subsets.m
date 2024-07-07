function x = subsets(n,k)
% Compute all subsets of a set with length 'n' returned as 'x'. Rows of 'x'
% are subsets. Columns of 'x' are elements in the original set. Cells of
% 'x' are logical, specifying whether the set element in the _j_th column
% is selected in the _i_th subset.
%
%   USAGE:
%       x = subsets(n)
%
%   INPUT:
%       n - Scalar natural number.
%
%   OPTIONAL INPUT:
%       k - Vector of numbers specifying whether to return subsets with a 
%           specific number of elements. For example, if (k==2), then 'x'
%           will only contain subsets with 2 items. 'k' must be in the
%           range   0 <= k <= n . If 'k' is empty, all subsets are
%           returned.
%               (default = [])
%
%   OUTPUT:
%       x - N^2 x N logical matrix.
%
%   EXAMPLE:
%       s = 'abc';
%       p = experm(numel(s));
%       ss = cell(1,size(p,1));
%       for i = 1:numel(ss)
%           ss{i} = s(p(i,:));
%       end
%       %% ss = { '', 'a', 'b', 'ab', 'c', 'ac', 'bc', 'abc' } 
%
%
%   DHK - Dec. 11, 2021

% Compute all subsets
x = bitand( repmat( (0:2^n-1)',1,n), repmat(2.^(n-1:-1:0),2^n,1) )&1;

% If pecific sized subsets are not required, return
if nargin<2 || isempty(k)
    return;
end

% Get the subsets of required size
k = unique(k(:));
if any(k<0 | n<k)
    error('All elements of optional argument ''k'' must be in the range 0<=k<=n .');
end
x = x(any( repmat(sum(x,2),1,numel(k)) == k', 2),:);