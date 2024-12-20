function y = skggpdf(x,mu,sigma,beta,lambda)
if nargin<5
    lambda = 0;
end
if nargin<4
    beta = 2;
end
if nargin<3
    sigma = 1;
end
if nargin<2
    mu = 0;
end
z = (x-mu)./sigma;
beta = abs(beta);
y = 2./sigma .* gnormpdf( z,0,1,beta ) .* gnormcdf( lambda.*z,0,1,beta );