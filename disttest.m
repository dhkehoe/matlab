function [p,h] = disttest(x,y,varargin)
% Computationally approximate the cutoffs of a joint probability density
% function P(x,y). Specifically, for two random variables x and y, compute
% the probability that 
%   p = P(X<Y+mu)
% and the null hypothesis that
%   h = p < alpha
%
%
%   DHK - July 10, 2024

%% Process input
if 1 < nargin
    if ischar(y)
        varargin = [y, varargin];
        clear y;
    elseif isnumeric(y)
        y = y(:);
        y(isnan(y)) = [];
    end
end

x = x(:);
x(isnan(x)) = [];

ip = inputParser;
addParameter(ip,'tail','both',@(x)any(strcmpi(x,{'both','left','right'}))); % tail
addParameter(ip,'null',     0,@(x)isscalar(x)&&isnumeric(x)); % null hypothesis
addParameter(ip,'alpha',  .05,@(x)isscalar(x)&&isnumeric(x)); % TypeI confidence level
parse(ip,varargin{:});
ip = ip.Results;

%% Compute test
if exist('y','var')
    y = y-ip.null;
    z = nan(numel(x),2);
    for i = 1:numel(x)
        z(i,1) = sum(x(i) > y);
        z(i,2) = sum(x(i) < y);
    end
    z = sum(z)/(numel(x)*numel(y));
else
    z = mean([ip.null<x x<ip.null]);
end
if strcmp(ip.tail,'both')
    p = min(z)*2;
else
    p = z(strcmpi(ip.tail,{'left','right'}));
end
if nargout==2
    h = p<ip.alpha;
end