function i = finddim(x,dim,varargin)
% Generalizes MATLAB's  find()  function such that it will return the true
% indices of 'x' as subscripts along the dimensions specified by 'dim'.
%
%
% EXAMPLE
%       x = rand(10,4,2);
%       i = finddim(x,[2,3]);
% 'i' is an N by M matrix, where N is the number of true elements in 'x'
% and M is 2. The first column specifies the dimension 2 subscripts of true
% elements of 'x', while the second column specifies the dimension 3
% subscripts of true elements of 'x'.
%
%
%   dhk - July 17, 2024
i = sortrows(ind2submat( size(x), find(x(:),varargin{:}) ));
i = i(:,dim);