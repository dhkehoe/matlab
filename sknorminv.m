function f = sknorminv(p,mu,sigma,alpha)
% Computational approach to find quantile of skew normal. No closed-form
% solution exists, so it must be computationally derived. Here, I minimize
% the distance between the CDF and quantile input.
%
%   DHK - October 12, 2022

% Manage input
if any(p(:)<0) || any(p(:)>1)
    error('Quantile function input must be in the interval (0,1)');
end
% Make it behave like a skewed standard normal if only 2 arguments are
% given.
if nargin==2, alpha=mu;mu=0;sigma=1; end

s = size(p); % Return data with same shape

% For small problems, we can just use optimization for precise solutions
if numel(p) <= 1000
    f = nan(s);
    for i = 1:numel(f)
        f(i) = fminsearch(@(x0)abs(p(i)-sknormcdf(x0,mu,sigma,alpha)),...
            mu,optimset('display','off'));
    end
    f = reshape(f,s);
    return;
end

% Otherwise, we can approximate the CDF across the entire domain, and take
% a gross minimum for each quantile

% Compute computational precision. More than 5e4 elements in the data x CDF
% matrix seems to punish the CPU.
if numel(p) > 5e4
    warning('The input size of ''p'' may cause MATLAB to become sluggish and non-responsive.');
end

% First, find the computable min/max of the x domain, to avoid +/- Inf values
mm = [min(p(p>0)),max(p(p<1))];
x0(2) = fminsearch(@(x0)abs(mm(2)-sknormcdf(x0,mu,sigma,alpha)),...
    mu,optimset('display','off'));
x0(1) = fminsearch(@(x0)abs(mm(1)-sknormcdf(x0,mu,sigma,alpha)),...
    mu,optimset('display','off'));

% Compute CDF
prec = 1e4;
x = linspace(x0(1),x0(2),prec); % Compute x domain
y = sort(sknormcdf(x,mu,sigma,alpha)); % Compute CDF and ensure CDF accuracy

% Repeat CDF/x domain for each quantile in 'p'
y = repmat(y,numel(p),1);
x = repmat(x,numel(p),1);

% Exhaustively compare CDF to quantiles
f = abs(y-repmat(p(:),1,prec));

% Get the minimum differences between CDF and quantiles
f = f==repmat(min(f,[],2),1,prec);

% Break ties
for i = find(sum(f,2)>1)
    f(i, (1:prec)<find(f(i,:),1,'last') ) = 0;
end

% Return corresponding value on x-domain that minimizes difference
f = reshape(x(f),s); % Reshape to original size

% Adjust for edge cases
f(p==0) = -Inf;
f(p==1) =  Inf;