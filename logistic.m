function y = logistic(x,lambda,x0,alpha,delta)
if nargin<5 || isempty(delta)
    delta = 0;
end
if nargin<4 || isempty(alpha)
    alpha = 1;
end
if nargin<3 || isempty(x0)
    x0 = 0;
end
if nargin<2 || isempty(lambda)
    lambda = 1;
end

y = (alpha-delta) ./ ( exp( -(x-x0).*lambda )+1 ) + delta;