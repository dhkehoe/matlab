function [p,tbl,stats] = friedman(x,reps,displayopt)
if numel(size(x))~=2, error('''x'' must be a 2D matrix where rows indicate subjects and columns indicate conditions'); end
[n,k] = size(x);
r = nan(size(x));
for i = 1:n
    r(i,:) = tiedrank(x(i,:));
end
stats.chi2 = (12*n)/(k*(k+1))*sum((mean(r)-((k+1)/2)).^2);
stats.df = k-1;
stats.p = 1-chi2cdf(stats.chi2,stats.df);

p = stats.p;