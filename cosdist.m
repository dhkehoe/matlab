function d = cosdist(x,y,dim)
% Cosine similarity between arrays 'x' and 'y' along the dimension 'dim'.
% 'x' and 'y' can be any number of dimensions.
%
% If 'y' is empty, then this function computes the cosine distance of 'x'
% along the dimension 'dim'.

if nargin<3 || isempty(dim)
    dim = 1;
end
if nargin<2 || isempty(y)
    d = squeeze( sum(x,dim) ./ sqrt(sum(x.^2,dim)) );
else
    d = squeeze( sum(x.*y,dim) ./ ( sqrt(sum(x.^2,dim)) .* sqrt(sum(y.^2,dim)) ));
end