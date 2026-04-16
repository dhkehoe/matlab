function y = equal(x,dim,tol)
% Check whether all elements in 'x' are equal along the dimension specified
% by 'dim'. Consistent with MATLAB default behavior, the default dimension
% for matrices is 1, and the non-zero sized dimension for vectors.

if nargin<3
    tol = [];
end
if nargin<2
    dim = [];
end
try
    if isempty(tol)
        y = logical(collapsedim(x,@iseq,dim));
    else
        y = logical(collapsedim(x,@(x)iseqtol(x,tol),dim));
    end
catch err
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end

%%
function b = iseq(x)
b = true;
for i = 2:numel(x)
    b = b && x(i) == x(i-1);
end

function b = iseqtol(x,tol)
b = true;
for i = 2:numel(x)
    b = b && abs(x(i) - x(i-1)) <= tol;
end