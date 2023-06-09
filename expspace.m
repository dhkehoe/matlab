function x = expspace(lb,ub,e,n)
if ~all([isscalar(lb),isscalar(ub),isscalar(e),isscalar(n)])
    error('Inputs must be scalars.');
end
x = linspace(lb^(1/e),ub^(1/e),n).^e;