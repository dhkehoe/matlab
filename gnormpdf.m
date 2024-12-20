function y = gnormpdf(x,mu,sigma,beta)
% Probability density function of a generalized normal random variable.
y = beta./(2*sigma*gamma(1/beta)) .* exp( -(abs(x-mu)./sigma).^beta );