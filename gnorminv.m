function y = gnorminv(x,mu,sigma,beta)
% Inverse distribution (quantile) function of a generalized normal random variable.
y = mu + sign(x-.5) .* (sigma.^beta.*gaminv(2*abs(x-.5),1./beta)).^(1./beta);