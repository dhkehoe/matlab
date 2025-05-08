function varargout = kde(d,varargin)
% I haven't had time to properly document this function yet. And it could
% use a little bit of refining (e.g., more kernels, better default
% bandwidths, etc.)
%
%   DHK - March 12, 2021

%% Set up
d = reshape( d(~(isnan(d)|isinf(d))) ,[],1); % Throw out trash data
p = inputParser;
addParameter(p,'bw',[],@(x)isnumeric(x)&&isscalar(x)); % Kernel bandwith
addParameter(p,'scale',[],@(x)isnumeric(x)&&isscalar(x)); % Spatial scale
addParameter(p,'npoints',101,@(x)isnumeric(x)&&isscalar(x)); % Spatial scale
addParameter(p,'xl',[],@(x)isnumeric(x)&&numel(x)==2&&issorted(x)); % Smoothing boundaries [lower,upper]
addParameter(p,'domain',[],@isnumeric); % user provides actual x domain
addParameter(p,'kernel','gauss',@ischar); % Kernel
addParameter(p,'norm','prob',@ischar); % Normalization type (probability or count)
addParameter(p,'dist','pdf',@ischar); % Distribution type (PDF or CDF)
addParameter(p,'bounds',[],@(x)isnumeric(x)&&numel(x)==2&&issorted(x)); % Domain bounds
parse(p,varargin{:});
p = p.Results;

%% Define/validate distribution type
dist = {'pdf','cdf'};
dist = find(strcmp(p.dist,dist));
if isempty(dist)
    error('Optional argument ''dist'' is invalid. It must be either ''pdf'' or ''cdf''.');
end

%% Define/validate normalization type
norm = {'prob','count'};
norm = find(strcmp(p.norm,norm));
if isempty(norm)
    error('Optional argument ''norm'' is invalid. It must be either ''prob'' or ''count''.');
end

%% Define/validate kernel type
kernel = {'gauss','rect','exp','tri','vonmises'}; % Accepted kernel choices
kernel = find(strcmp(p.kernel,kernel));
if isempty(kernel)
    error('Optional argument ''norm'' is invalid. Valid options are ''gauss'', ''rect'', ''exp'', ''tri'', or ''vonmises''.');
end
if ~isempty(p.bounds) && kernel~=1
    error(['Optional argument ''bounded'' provided. However, bounds are not supported for the ''',p.kernel,''' kernel. Either use a Gaussian kernel or do not impose bounds.']);
end

%% Define default bandwidths based on kernel selection
if isempty(p.bw)
    switch kernel
        case 1 % Gaussian kernel
            p.bw = .9*min([std(d) iqr(d)/1.34])*numel(d)^(-1/5);
        case 2 % Rectangular kernel
            p.bw = std(d);
        case 3 % Exponential decay kernel
            p.bw = std(d)/3;
        case 4 % triangle
            p.bw = std(d);
        case 5 % von mises (circular Gaussian)
            p.bw = .9*min([std(d) iqr(d)/1.34])*numel(d)^(-1/5);
    end
end

%% Define domain of x
if isempty(p.domain) % Domain was not provided
    if isempty(p.xl)
        p.xl = [min(d),max(d)]+[-1,1]*p.bw*2;
    end
    if ~isempty(p.scale)
        p.domain = p.xl(1) : p.scale : p.xl(2); % Define domain of x
    else
        p.domain = linspace(p.xl(1),p.xl(2),p.npoints);
    end
else % Domain was provided
    p.domain = p.domain(:);
    if ~isempty(p.scale)
        warning('Optional argument''domain'' was provided, so optional argument ''scale'' is being ignored.');
    end
    if ~isempty(p.xl)
         warning('Optional argument''domain'' was provided, so optional argument ''xl'' is being ignored.');
    end
    p.xl = rangei(p.domain(:));
end
x = p.domain;
x = reshape(x,1,numel(x));

%% Define kernels
switch kernel
    case 1 % Gaussian kernel
        if isempty(p.bounds)
            k = @(x,x0) normpdf(x,x0,p.bw);
        else
            k = @(x,x0) [... (data,domain)
                zeros( size(x,1), sum(x0(1,:)<p.bounds(1)) ),...
                normpdf( x(:,p.bounds(1)<=x0(1,:)&x0(1,:)<=p.bounds(2)), x0(:,p.bounds(1)<=x0(1,:)&x0(1,:)<=p.bounds(2)), p.bw),...
                zeros( size(x,1), sum(p.bounds(2)<x0(1,:)) )...
                ] ./ (normcdf(p.bounds(2),x0,p.bw)-normcdf(p.bounds(1),x0,p.bw));
        end
    case 2 % Rectangular kernel
        k = @(x,x0) (x0-p.bw/2<=x & x<=x0+p.bw/2)./p.bw;
    case 3 % Exponential decay kernel
        k = @(x,x0) exp(-abs(x-x0)/p.bw) .* (x-x0<=0) ./ (p.bw);
    case 4 % Triangle
        k = @(x,x0) (p.bw-abs(x-x0))./p.bw.^2 .* (abs(x-x0)<=p.bw);
    case 5 % von mises (circular Gaussian)
        k = @(x,x0) exp( p.bw*cos(x-x0) ) ./ (2*pi*besseli(0,p.bw));
end

%% Compute KDE
% Repeat data across kernels and take mean (mean gives pdf, while sum gives histogram)
[md,mx] = meshgrid(x,d);
y = sum(k(mx,md),1); % count
if norm == 1, y = y./numel(d); end % density

% If necessary, compute CDF
if dist == 2, y = cumsum(y); 
    y = y./max(y);
    if norm == 2, y = y.*numel(d);
    end
end

%% Set outputs
if nargout<=1
    % if single argument returned, return KDE; this assumes user has domain already
    varargout{1} = y;
end 
if 1<nargout
    % 2 or more arguments returned, return (x,y)
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = std(k(mx,md)); % compute error
end

function y = iqr(x)
y = diff(prctile(x, [25, 75]));