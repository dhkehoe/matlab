function mat = ind2submat(sz,ind)
% Convert linear indices to matrix subscripts, but returned as a matrix,
% therefore not requiring an arbitrary number of output arguments. See
% MATLAB function ind2sub() for more info.
%
% EXAMPLE
%   [S1,...,Sn] = ind2sub(sz,ind);
% is replaced by
%   s = ind2sub(sz,ind);
% where 's' is a M x N matrix such that each column corresponds to a
% dimension of 'sz' and each row corresponds to an index in 'ind'. That is,
%   numel(ind) == M  and
%   numel(sz)  == N
%
% The exact dimensions of 'sz' and 'ind' are arbitrary.
%
%
%   DHK - Mar. 26, 2024

% Cell array to catch all the outputs from ind2sub()
c = cell(numel(sz),1);

% Call ind2sub(), ensuring 'ind' is a row vector
[c{:}] = ind2sub(sz,reshape(ind,1,numel(ind)));

% Convert to a matrix
mat = cell2mat(c)';