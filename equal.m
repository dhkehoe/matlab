function y = equal(x,dim)
% Check whether all elements in 'x' are equal along the dimension specified
% by 'dim'. Consistent with MATLAB default behavior, the default dimension
% for matrices is 1, and the non-zero sized dimension for vectors.

if nargin<2
    dim = [];
end
try
    y = collapsedim(x,@iseq,dim);
catch err
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end

%%
function b = iseq(x)
b = true;
for i = 2:numel(x)
    b = b && x(i) == x(i-1);
end