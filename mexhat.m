function y = mexhat(x,mu,sigma,alpha,delta)
if nargin<5 || isempty(delta)
    delta = 0;
end
if nargin<4 || isempty(alpha)
    alpha = 1;
end
if nargin<3 || isempty(sigma)
    sigma = 1;
end
if nargin<2 || isempty(mu)
    mu = 0;
end

dx = -(x-mu).^2;
ss = sigma.^2;

y = exp( dx./(2*ss) ) .* ( dx./ss.^2 + 1./ss ) .* ss * (alpha-delta) + delta;