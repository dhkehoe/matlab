function y = gnormpdf(x,mu,sigma,beta)
if beta<0, error('''beta'' must be positive'); end
y = beta./(2*sigma*gamma(1/beta)) .* exp( -(abs(x-mu)./sigma).^beta );