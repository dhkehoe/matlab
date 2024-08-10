function y = entropy(p,n)
if nargin<2
    n = [];
end

if isempty(n)
    lp = log(p);
else
    lp = logn(p,n);
end

lp(isinf(lp)) = 0;

y = -sum(p.*lp);