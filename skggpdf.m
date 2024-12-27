function y = skggpdf(x,mu,sigma,beta,lambda)
if nargin<5 || isempty(lambda)
    lambda = 0;
end
if nargin<4 || isempty(beta)
    beta = 2;
end
if nargin<3 || isempty(sigma)
    sigma = 1;
end
if nargin<2 || isempty(mu)
    mu = 0;
end
%% Compute
% z = (x-mu)./sigma;
% y = 2./sigma .* gnormpdf( z,0,1,beta ) .* gnormcdf( lambda.*z,0,1,beta );

% Try the mu parameter
try
    z = (x-mu);
catch
    error('Parameter ''mu'' must be scalar or the same size as ''x''.');
end

% Try the sigma parameter
try
    z = z./sigma;
catch
    error('Parameter ''sigma'' must be scalar or the same size as ''x''.');
end

% Try the beta parameter
beta = abs(beta);
try
    y = 2./sigma .* gnormpdf( z,0,1,beta );
catch
    error('Parameter ''beta'' must be scalar or the same size as ''x''.');
end

% Try the lambda parameter
try
    y = y .* gnormcdf( lambda.*z,0,1,beta );
catch
    error('Parameter ''lambda'' must be scalar or the same size as ''x''.');
end