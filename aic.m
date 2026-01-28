function d = aic(ll,k,delta,n)
% Compute the Akaike information criterion across a set of log-likelihood
% values 'll' and number of model parameters 'k'. 'll' and 'k' must match
% in size or at least one must be scalar. When 'delta' is true, this
% function computes AIC delta, where each AIC value is relative to the
% minimum AIC in the set of values (default = true). When 'n' is non-zero,
% this function computes the second order AIC, where 'n' specifies the
% number of observations for each model fit (default = 0). For more
% details, see
%
%   https://en.wikipedia.org/wiki/Akaike_information_criterion
%
%
%   DHK - Jan. 28, 2025

if nargin<4 || isempty(n)
    n = 0;
end
if nargin<3 || isempty(delta)
    delta = true;
end

d = 2*(k-ll);

if n
    d = d + ( 2*(k.^2+k) ) ./ (n-k-1);
end

if delta
    d = d-min(d);
end