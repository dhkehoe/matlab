function y = gnormcdf(x,mu,sigma,beta)
if beta<0, error('''beta'' must be positive'); end
y = .5 + sign(x-mu)/2 .* gammainc( abs( (x-mu)./(sqrt(2)*abs(sigma)) ).^beta, 1/beta );