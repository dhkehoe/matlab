function x = subsets(n)
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

x = bitand( repmat( (0:2^n-1)',1,n), repmat(2.^(n-1:-1:0),2^n,1) )&1;
