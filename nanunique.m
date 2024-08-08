function y = nanunique(x)
% MATLAB's unique() function, but ignoring NaN values.
y = unique(x(~isnan(x)));