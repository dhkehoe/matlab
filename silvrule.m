function h = silvrule(x)
% Silverman's rule-of-thumb for optimal (Gaussian) bandwidth selection for
% KDE.
h = 9*min([std(x), iqr(x)/1.34])*numel(x)^(-1/5);