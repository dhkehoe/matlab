function y = sknormpdf(x,mu,sigma,alpha)
y = 2/sigma .* normpdf((x-mu)./sigma) .* normcdf((x-mu)./sigma.*alpha);