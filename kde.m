function [x,y,e] = kde(d,varargin)
% I haven't had time to properly document this function yet. And it could
% use a little bit of refining (e.g., more kernels, better default
% bandwidths, etc.)
%
%   DHK - March 12, 2021

%% Set up
d = reshape( d(~(isnan(d)|isinf(d))) ,[],1); % Throw out trash data
p = inputParser;
addOptional(p,'bw',[],@(x)isnumeric(x)&&isscalar(x)), % Kernel bandwith
addOptional(p,'scale',[],@(x)isnumeric(x)&&isscalar(x)), % Spatial scale
addOptional(p,'xl',[],@(x)isnumeric(x)&&numel(x)==2), % Smoothing x boundaries [lower,upper]
addOptional(p,'domain',[],@(x)isnumeric(x)&&numel(size(x))==2&&any(size(x)==1)); % user provides actual x domain
addOptional(p,'kernel','gauss',@ischar), % Kernel
addOptional(p,'norm','prob',@ischar), % Normalization type (probability or count)
addOptional(p,'dist','pdf',@ischar), % Distribution type (PDF or CDF)
addOptional(p,'bounded',[0,0],@(x)islogical(logical(x))&&numel(x)==2), % Kernel bandwith
parse(p,varargin{:});
p = p.Results;

%% Define/validate distribution type
dist = {'pdf','cdf'};
dist = find(strcmp(p.dist,dist));
if isempty(dist), error(['distribution type ''',p.dist,''' not recognized. check documentation']), end

%% Define/validate normalization type
norm = {'prob','count'};
norm = find(strcmp(p.norm,norm));
if isempty(norm), error(['normalization type ''',p.norm,''' not recognized. check documentation']), end

%% Define kernel and set default bandwidths
kernel = {'gauss','rect','exp','pgauss','tri','vonmises'}; % Accepted kernel choices
kernel = find(strcmp(p.kernel,kernel));
if isempty(kernel), error(['kernel ''',p.kernel,''' not recognized. check documentation']), end
if any(p.bounded)&&kernel~=1, error(['bounds are not supported for the ''',p.kernel,''' kernel. either use a Gaussian kernel or do not impose bounds']), end
switch kernel
    case 1 % Gaussian kernel
        if isempty(p.bw), p.bw = .9*min([std(d) iqr(d)/1.34])*numel(d)^(-1/5); end
        if all(p.bounded)
            k = @(x,x0) [zeros(1,sum(x<p.xl(1)))...
                normpdf(x(x>=p.xl(1)&x<=p.xl(2)),x0,p.bw)...
                zeros(1,sum(x>p.xl(2)))]./...
                (normcdf(p.xl(2),x0,p.bw)-normcdf(p.xl(1),x0,p.bw));
        elseif p.bounded(1)
            k = @(x,x0) [zeros(1,sum(x<p.xl(1))) normpdf(x(x>=p.xl(1)),x0,p.bw)]./...
                (1-normcdf(p.xl(1),x0,p.bw));            
        elseif p.bounded(2)
            k = @(x,x0) [normpdf(x(x<=p.xl(2)),x0,p.bw) zeros(1,sum(x>p.xl(2)))]./...
                normcdf(p.xl(2),x0,p.bw);
        else % unbounded
            k = @(x,x0) normpdf(x,x0,p.bw);
        end
    case 2 % Rectangular kernel
        if isempty(p.bw), p.bw = std(d); end
        k = @(x,x0) (x0-p.bw/2<=x & x<=x0+p.bw/2)./p.bw;
    case 3 % (Positive) exponential decay kernel
        if isempty(p.bw), p.bw = std(d)/3; end
        k = @(x,x0) exp(-abs(x-x0)/p.bw) .* (x-x0<=0) ./ (p.bw);
    case 4 % (Positive) half Gaussian kernel
        if isempty(p.bw), p.bw = (.9*min([std(d) iqr(d)/1.34])*numel(d)^(-1/5))/2; end
        k = @(x,x0) normpdf(x,x0,p.bw) .* (x-x0<=0) .* 2;
    case 5 % triangle
        if isempty(p.bw), p.bw = std(d); end
        k = @(x,x0) (p.bw-abs(x-x0))./p.bw.^2 .* (abs(x-x0)<=p.bw);
    case 6 % von mises (circular Gaussian)
        if isempty(p.bw), p.bw = .9*min([std(d) iqr(d)/1.34])*numel(d)^(-1/5); end
        k = @(x,x0) exp( p.bw*cos(x-x0) ) ./ (2*pi*besseli(0,p.bw));
end

%% Define domain of x
if isempty(p.domain) % domain not provided
    if isempty(p.xl), p.xl = [min(d),max(d)]+[-1,1]*p.bw*2; end
    if isempty(p.scale), p.scale = range(p.xl)/100; end
    p.domain = p.xl(1) : p.scale : p.xl(2); % Define domain of x
elseif ~isempty(p.scale) || ~isempty(p.xl) % domain provided -> ~isempty(p.x) == true
    warning(' ''domain'' was provided, so ''scale'' and ''xl'' are being ignored.');
end
x = p.domain;

%% Compute KDE
% Repeat data across kernels and take mean (mean gives pdf, while sum gives histogram)
[md,mx] = meshgrid(x,d);
y = sum(k(mx,md)); % count
if norm == 1, y = y./numel(d); end % density

% If necessary, compute CDF
if dist == 2, y = cumsum(y); 
    y = y./max(y);
    if norm == 2, y = y.*numel(d);
    end
end

%% Set outputs
if nargout==3, e = std(k(mx,md)); end % compute error
if nargout==1, x = y; end % if single argument returned, return KDE; this assumes user has domain already


function y = iqr(x)
y = diff(prctile(x, [25, 75]));