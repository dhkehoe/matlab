function y = sknormdev(x,mu,sigma,alpha)

% Standardize x
x = (x-mu)./sigma;

% Compute x^2
x2 = x.^2;

% Compute -x^2/2
sx = -x2/2;

% Compute function
y = (...
    ( alpha .* exp(sx.*alpha.^2+sx)  ) / pi ...
    - ( x .* exp(sx) .* (erf(alpha.*x/sqrt(2))+1) ) / sqrt(2*pi)...
    ) ./ sigma;



%% LaTeX expression:
% \frac{ a\mathrm{e}^{-\frac{a^{2} z^{2}}{2} - \frac{z^{2}}{2}}}{\sigma\pi} - \frac { z\mathrm{e}^{-\frac{z^{2}}{2}} \left(\operatorname{erf}\left(\frac{az}{\sqrt{2}}\right) + 1\right) } {\sigma \sqrt{2\pi}}
