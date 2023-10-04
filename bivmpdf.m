function y = bivmpdf(X1,X2,mu,kappa,lambda)
% Bivariate von Mises probability density function: circular distribution
% on the surface of a torus.
%
% INPUT
%      X1 - Matrix of any size containing major circular dimension data.
%      X2 - Matrix of any size containing minor circular dimension data.
%      mu - 1 by 2 vector of location parameters in the first and second
%           spatial dimensions.
%   kappa - 1 by 2 vector of dispersion parameters in the first and second
%           spatial dimensions.
%  lambda - Scalar parameter of the correlation between spatial dimensions.

if any(size(X1)~=size(X2))
    error('dimension mismatch between args ''X1'' and ''X2''');
end

i = 0:88;
y = exp(...
    kappa(1)*cos(X1-mu(1))+...
    kappa(2)*cos(X2-mu(2))+...
    lambda*sin(X1-mu(1)).*sin(X2-mu(2))...
    ) /... exp
    ( (4*pi^2) * sum(...
        binocoef(i*2,i) .*...
        (lambda^2 / (prod(kappa)*4) ).^i .*...
        besseli(i,kappa(1)).*besseli(i,kappa(2))...
        )... sum
    ); % /
