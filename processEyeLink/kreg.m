function [yfit,xfit,efit] = kreg(x,y,varargin)
% Fit a kernel regression function of y ~ x. Can use a fixed bandwidth or
% k-nearest neighbors. Can choose between several kernels. Can specify the
% limits, scale, and precision of the x-domain or can simply give the exact
% x-domain itself. Optional arugments specified using the MATLAB name-pair
% convention. Optional output arguments are returned such that one return
% argument gives the fitted function, while two return arguments are the
% [fitted function, x-domain]. The former is ideal for nesting this
% function with plot().
%
% USAGE
%   yfit = kreg(x,y);
%   [yfit, xfit] = kreg(x,y);
%   [yfit, xfit, efit] = kreg(x,y);
%   yfit = kreg(x,y,'OptionalArgName1',OptionalArgValue1,...);
%
% EXAMPLES
%   Fully specified x-domain:
%       xfit = linspace(min(x),max(x),100);
%       plot(xfit,kreg(x,y,'domain',xfit));
%
%   Using shading to indicate fit error:
%       [yfit,xfit,efit] = kreg(x,y);
%       fill([xfit,fliplr(xfit)],[yfit-efit,fliplr(yfit+efit)],'k');
%       plot(xfit,yfit,'k'); 
%
%
% INPUT
%   x - Matrix of any number of dimensions specifying location of data on
%       the abcissa. NaN and Inf values will be ignored.
%   y - Matrix of any number of dimensions specifying location of data on
%       the ordinate. Each element in 'y' must be matched with
%       corresponding value in 'x'. NaN and Inf values will be ignored.
%
% OPTIONAL INPUT
%        bw - The fixed kernel bandwidth. Is superceded by 'knn'. If
%             neither 'bw' or 'knn' are provided, a default fixed kernel
%             bandwidth is used. The default is kernel specific:
%                   KERNEL   |   DEFAULT BW
%                  Gaussian  | Silverman's Rule of Thumb  
%                  Rectangle |  2*IQR*n^1/3 
%
%       knn - k-nearest neighbors. If all the k nearest neighbors to a 
%             particular datum have a distance of 0, then the distance to
%             the first non-zero neighbor is used.
%    domain - The exact x domain to use for random variable X. Supercedes
%             'scale', 'npoints', and 'xl'.
%     scale - The equal distance between points on an unspecified domain.
%             Mutually exclusive with 'npoints'.
%   npoints - The number of points on the unspecified domain. Mutually
%             exclusive with 'scale'.
%        xl - The [min,max] values of the unspecified domain. Default value
%             is the [min,max] of the random variable X.
%    kernel - A string specifying the type of kernel. Valid options are
%              STRING   |   FULL NAME  |   FORM
%               'gauss' |  Gaussian    |    exp( -x^2 / (2*bw^2) )   default
%               'rect'  | Rectangle    |    bw/2 <= x & x <= bw/2
%
%
% OUTPUT
%   yfit - The fitted regression function.
%   xfit - The domain of the random variable X.
%   efit - The standard deviation of the regression function as a function
%          of x. Use this to shade the standard error.
%
%   
%   DHK - Jan. 22, 2022

%% Manage input
x = x(:); y = y(:);
if numel(x)~=numel(y), error('dimension mismatch in inputs ''x'' and ''y''');
end
n = numel(x);
if n<=1, error('insufficient valid data'); end

p = inputParser;
validateArg = @(arg)all(isnumeric(arg))&&numel(arg)==1;
addOptional(p,'bw',[],validateArg), % Kernel bandwidth
addOptional(p,'knn',[],validateArg), % Weight data by kernel generated pdf? (true/false)
addOptional(p,'domain',[],@(arg)all(isnumeric(arg))), % Exact x domain
addOptional(p,'scale',[],validateArg), % Distance between points on x domain
addOptional(p,'npoints',[],validateArg), % # of points on x domain
addOptional(p,'xl',[min(x) max(x)],@(arg)all(isnumeric(arg))&&numel(arg)==2), % x domain boundaries [lower,upper]
addOptional(p,'kernel','gauss',@(arg)all(ischar(arg))), % Kernel choice
addOptional(p,'overlap',5,validateArg), % Overlapped smoothing interval in units of kernel bandwidth
parse(p,varargin{:});
p = p.Results;

%% Define kernels and bandwidths
if p.knn > n, error('''knn'' cannot exceed the number of data'); end
if ~isempty(p.knn) && ~isempty(p.bw)
    warning('setting ''knn'' supercedes values set to ''bw''');
end
k = find(strcmp(p.kernel,{'gauss','rect'}));
if isempty(k), error('unsupported ''kernel'' argument. options are {''gauss'', ''rect''}'); end
% Define kernel functions
switch k
    case 1
        if isempty(p.bw) && isempty(p.knn), p.bw = .9*min([std(x) iqr(x)/1.34])*n^(-1/5); end
        k = @(x,bw) exp(-x.^2./(2.*bw.^2));
    case 2
        if isempty(p.bw) && isempty(p.knn), p.bw = 2*iqr(x)*n^(-1/3); end
        k = @(x,bw) -bw/2 <= x & x <= bw/2;
end

%% Define x domain
if ~isempty(p.domain) % Exact x domain provided by user
    if ~isempty(p.scale) || ~isempty(p.npoints)
        warning('setting ''domain'' supercedes values set to ''scale'' or ''npoints'''); 
    end
    xfit = p.domain;
elseif isempty(p.scale) && isempty(p.npoints) % Nothing specified
    xfit = linspace(p.xl(1),p.xl(2),100); % Default to 100 point linear domain between xlits of x    
elseif isempty(p.scale) && ~isempty(p.npoints) % 'npoint's given
    xfit = linspace(p.xl(1),p.xl(2),p.npoints); % Linear domain between limits of x with n = 'npoints' points
elseif ~isempty(p.scale) && isempty(p.npoints) % Domain scaling factor given
    xfit = p.xl(1) : p.scale : p.xl(2);
else % ~isempty(p.scale) && ~isempty(p.npoints)
    error('not possible to set both ''scale'' and ''npoints''');
end

%% Invoke recursive subroutines
[yfit,efit] = kreg_(x, y, xfit, k, p);

%% Reshape output
if numel(x)==numel(xfit)
    s = size(xfit);
    yfit = reshape(yfit, s);
    xfit = reshape(xfit, s);
    efit = reshape(efit, s);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recursive caller
function [yfit,efit] = kreg_(x, y, xfit, k, p)
% Recursively split the data until there is enough memory to perform the 
% kernel regression

try
    % Try fitting to the entire data set
    [yfit,efit] = kreg__(x, y, xfit, k, p);
    
catch
    try
    % Out of memory... split the data and recursively step back in
    n = numel(x);
    m = numel(xfit);

    v = floor(n/2); % Recursive pivot point
    u = floor(m/2);

    yfit = nan(m,1);
    efit = nan(m,1);

    % Fit lower half of data
    i = x<=x(v)+p.bw*p.overlap;
    j = 1:u;
    [fy,fe] = kreg_( x(i), y(i), xfit(j), k, p );

    % Fill lower half of data
    yfit(j) = fy;
    efit(j) = fe;
    clear fy, clear fe;

    % Fit upper half of data
    i = x>x(v)-p.bw*p.overlap;
    j = u+1:n;
    [fy,fe] = kreg_( x(i), y(i), xfit(j), k, p);

    % Fill upper half of data
    yfit(j) = fy;
    efit(j) = fe;
    catch err
        keyboard; rethrow(err);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recursive callee
% Here is the actual kernel regression routine
function [yfit,efit] = kreg__(x,y,xfit,k,p)

% Compute kernel regression
[d,f] = meshgrid(xfit,x);
f = abs(f-d); % Generate distance of predictor from kernels
clear d;
if ~isempty(p.knn)
    fs = sort(f);
    p.bw = fs(p.knn,:); % The knn_th row
    p.bw(p.bw==0) = min(fs(fs>0)); % If that row contains zero, the minimum non-zero distance
    p.bw = repmat( p.bw*2, size(f,1),1);
end
f = k(f,p.bw); % Generate kernels
y = repmat(y,1,numel(xfit)); % Repeat y across domain
yfit = nansum( y .* f ); %#ok; Weight the data with kernels
f = nansum(f); %#ok; Sum kernels
yfit = yfit ./ f; % Fit regression

% Set nans in output
nanIdx = isnan(x) | isinf(x) | isnan(y) | isinf(y);
yfit(nanIdx) = nan;

% Compute error
% efit = nansum( (y-repmat(yfit,size(y,1),1)).^2 ); 
efit = sqrt(nansum( (y-repmat(yfit,size(y,1),1)).^2 )) ./ f; %#ok
efit(nanIdx) = nan;

%% Interquartile range
function y = iqr(x)
y = diff(prctile(x, [25, 75]));