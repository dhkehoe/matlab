function y = skggpdf(x,p)
y = 2./p(2) .* gennpdf( (x-p(1))/p(2),0,1,p(3) ) .* genncdf( p(4).* (x-p(1))/p(2),0,1,p(3) );