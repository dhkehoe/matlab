function [p,h] = disttest(x,y,varargin)
if nargin > 1 && ischar(y), varargin = [y varargin]; clear y, 
elseif nargin > 1 && isnumeric(y), y = y(:);
end
ip = inputParser;
addParameter(ip,'tail','both',@(x)any(strcmp(x,{'both','left','right'}))); % tail
addParameter(ip,'null',0,@(x)numel(x)==1&&isnumeric(x)); % null hypothesis
addParameter(ip,'alpha',.05,@(x)numel(x)==1&&isnumeric(x)); % TypeI confidence level
parse(ip,varargin{:});
ip = ip.Results;

x = x(:);
x(isnan(x)) = [];
if exist('y','var')
    y = y(:);
    y(isnan(y)) = [];
    y = y-ip.null;
    z = nan(numel(x),2);
    for i = 1:numel(x)
        z(i,1) = sum(x(i) > y);
        z(i,2) = sum(x(i) < y);
    end
    z = sum(z)/(numel(x)*numel(y));
else
    z = mean([x>ip.null x<ip.null]);
end
if strcmp(ip.tail,'both')
    p = min(z)*2;
else
    p = z(strcmp(ip.tail,{'left','right'}));
end
if nargout==2, h = p<ip.alpha; end