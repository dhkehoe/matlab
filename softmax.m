function y = softmax(x,lambda,dim)
if nargin<2 || isempty(lambda)
    lambda = 1;
end
if nargin<3 || isempty(dim)
    % Let MATLAB pick the default dimension
    y = exp(x) ./ sum(exp(x.*lambda));
else
    y = exp(x) ./ sum(exp(x.*lambda),dim);
end