function [y,x1,x2] = kde2(d,varargin)
% Fit a 2-dimensional KDE. The KDE bandwidth and domain can be flexibly and
% full-specified by the user using optional arguments. Optional arguments
% are passed using the MATLAB name-pair convention.
%
% USAGE
%   y = kde2(d);
%   [y,x1,x2] = kde2(d);
%   [y,x1,x2] = kde2(d,'OptionalArgName',OptionalArgValue,...);
%
% INPUT
%   d - An Nx2 matrix, of any number of rows. Columns specify the
%       dimensions of the data. Observations are distributed across the
%       rows.
% 
% OPTIONAL INPUT
%  kernel - A string specifying the smoothing kernel. Available options are
%           1) 'gauss'    - Gaussian function
%           2) 'rect'     - A rectangular box function (histogram)
%           3) 'vonmises' - Gaussian function with support on the circular
%                           domain [0,2*pi]
%
%      bw - A scalar or 1x2 vector specifying the kernel bandwidths in the
%           first and second dimensions of the data. Scalars are
%           repeated for both dimensions. Default value is Silverman's
%           rule-of-thumb bandwidths.
%
%  domain - A matrix or cell array with 2 elements. If a matrix, this
%           specifies the literal values for both dimenions of the KDE
%           domain. If a cell array, each element specifies the literal
%           values of the first and second dimensions of the KDE domain.
%           Values passed to domain will supercede any values passed to
%           'xl', 'npoints', or 'scale'. If not provided, the exact domain
%           is computed from the values of 'xl' and either 'npoints' or
%           'scale'.
%
%      xl - A 1x2 or 2x2 matrix specifying the [lower,upper] boundaries of
%           the KDE domain. Domain dimensions are specified by row. Upper/
%           lower boundaries are specified by column and must be in
%           columnwise ascending order. 1x2 vectors repeat the boundaries
%           across both KDE domain dimensions. Default is the boundaries of
%           the data +/- 2 * bandwidths.
%
% npoints - Scalar or 1x2 vector specifying the number of evenly spaced
%           points to use between the boundaries of the first and second
%           dimensions of the KDE domain. Scalars are repeated along both
%           dimensions. 'npoints' supercedes values passed to 'scale'.
%           Default is 100 points along each dimension.
%
%   scale - Scalar or 1x2 vector specifying the spatial scale (distance
%           between evenly spaced points) along the first and second
%           dimensions of the KDE domain. Scalars are repeated along both
%           dimensions. Default is the 1% of the range of the domain.
%
%    norm - Scalar specifying the normalization factor. This is the value
%           the KDE integrates to across the 2D domain. A value of 1 is
%           therefore a bivariate proability density function. Default is 1
%
%
% OUTPUT
%  y - The height of the fitted KDE across the 2D domain.
% x1 - The 2D values of the first data dimension.
% x2 - The 2D values of the second data dimension.
%   
% EXAMPLE 1:
%   d = randn(1000,2).*[40,30]+[100,150];
%   [y,x1,x2] = kde2(d);
%   surf(x1,x2,y);
%
% EXAMPLE 2:
%   x = 0:200;
%   y = 0:250; 
%   [x2,y2] = meshgrid(x,y);
%   surf( x2, y2, kde2(d,'domain',{x,y}) );
%
%
%   DHK - Nov. 20, 2022

%% Data hygiene
if numel(size(d)) ~=2 || size(d,2) ~= 2
    error('Input ''d'' must be an N x 2 matrix');
end

% Throw out non-numeric data
d(any(isnan(d)|isinf(d),2),:) = [];
n = size(d);

% Check we still have data left
if isempty(d)
    error('Input ''d'' is empty after removing non-numeric data');
end

%% Parse optionals
p = inputParser;
addOptional(p,'bw',[]),      % Kernel bandwith
addOptional(p,'domain',[]);  % User provides full domains
addOptional(p,'xl',[]),      % Smoothing boundaries [lower,upper]
addOptional(p,'npoints',[]), % Number of evenly spaced points along domain
addOptional(p,'scale',[]),   % Spatial scale
addOptional(p,'norm',[]),    % Normalization factor
addOptional(p,'kernel',[]),  % Smoothing kernel
parse(p,varargin{:});
p = p.Results;
% Now set any defaults and check the integrity of values that have been
% passed:

%% Set default kernel
if isempty(p.kernel)
    p.kernel = 1; % Default to Gaussian kernel
elseif ~ischar(p.kernel) % Incorrect format
    error('Optional argument ''kernel'' must be a string.');
else % Convert to integer/throw an error if not an accepted string.
    p.kernel = find(strcmp(p.kernel,{'gauss','rect','vonmises'}));
    if isempty(p.kernel)
        error(['Optional argument ''kernel'' must be one of the following strings',...
            'indicating the smoothing kernel:',...
            '\n\t''gauss'' (Gaussian function)',...
            '\n\t''rect'' (Rectangular box function)',...
            '\n\t''vonmises'' (Circular Von Mises function)']);
    end
end

% Define the kernels
switch p.kernel
    case 1
        k = @(x1,x2,bw) mean(exp( -x1.^2/(2*bw(1)^2) -x2.^2/(2*bw(2)^2) ),3) / prod([2,pi,bw]);
    case 2
        k = @(x1,x2,bw) mean(-bw(1)/2 <= x1 & x1 <= bw(1)/2 & -bw(2)/2 <= x2 & x2 <= bw(2)/2,3) / prod(bw);
    case 3
        k = @(x1,x2,bw) mean(exp( bw(1)*cos(x1)+bw(2)*cos(x2) ),3) * prod( bw./(4*pi*sinh(bw)) );
end

%% Set default bandwidths
if isempty(p.bw) 
    switch p.kernel
        case 1 % (Gaussian) Default to Silverman's rule-of-thumb
            % https://en.wikipedia.org/wiki/Multivariate_kernel_density_estimation
            p.bw = (4/(n(2)+2))^(1/(n(2)+4)) .* n(1)^(-1/(n(2)+4)) .* std(d);
        case 2 % (Rectangular) Default to Freedman-Diaconis rule-of-thumb
            % https://en.wikipedia.org/wiki/Freedman-Diaconis_rule
            p.bw = 2*iqr(d)*n(2)^(-1/3);
        case 3 % (Von Mises) Reciprocal of Silverman's rule-of-thumb
            p.bw = 1./((4/(n(2)+2))^(1/(n(2)+4)) .* n(1)^(-1/(n(2)+4)) .* std(d));
    end
elseif numel(p.bw)==1 % Use same bandwidth in both dimensions
    p.bw = [p.bw,p.bw];
elseif numel(p.bw)>2 % Wrong number of bandwidths provided
    error('Optional argument ''bw'' must contain either 1 or 2 elements');
end

%% Set default normalization
if isempty(p.norm)
    p.norm = 1;
elseif numel(p.norm)~=1
    error('Optional argument ''norm'' must be scalar.'),
end

%% Set default domain
if isempty(p.domain)
    % If a full domain isn't provided, defaults must be computed using 'xl'
    % and either 'npoints' or 'scale'.

    p.domain = cell(1,2); % Initialize domain

    % Set default domain limits
    if isempty(p.xl)
        p.xl = [min(d);max(d)]' + [-1,1].*p.bw(:)*2; % Default to edge of data +/- 2 SDs
    elseif numel(p.xl)==2 % Repeat xlims across both domains
        p.xl = [p.xl(:)',p.xl(:)']; % Repeat; ensure format
    elseif numel(size(p.xlim))>2 || numel(p.xl)>4  % Wrong number of xlims provided
        error('Optional argument ''xl'' must contain either a 1x2 vector or 2x2 matrix.');
    end

    % Now check that 'xl' is sorted
    for i = 1:2
        if ~issorted(p.xl(i,:))
            error('Optional argument ''xl'' must be columnwise sorted in ascending order.');
        end
    end

    % 'npoints' supercedes 'scale'
    if ~isempty(p.scale) || ~isempty(p.npoints)
        warning('Optional argument ''npoints'' was provided, so optional argument ''scale'' is ignored.');
    end

    % 'scale' is provided but not 'npoints', so use 'scale'
    if isempty(p.npoints) && ~isempty(p.scale)

        % Ensure integrity
        if numel(p.scale)==1 % Repeat scale
            p.scale = [p.scale,p.scale];
        elseif numel(p.scale)>2 % Wrong number of scale factors provided
            error('Optional argument ''scale'' must contain either 1 or 2 elements');
        end

        % Compute domain from scale
        for i = 1:2
            p.domain{i} = p.xl(i,1) : p.scale(i) : p.xl(i,2);
        end
        
    else % Otherwise, default to 'npoints'

        % Ensure npoints
        if isempty(p.npoints)
            p.npoints = [100,100];
        elseif numel(p.npoints)==1 % Repeat npoints
            p.npoints = [p.npoints,p.npoints];
        elseif numel(p.npoints)>2 % Wrong number of 'npoints' provided
            error('Optional argument ''npoints'' must contain either 1 or 2 elements');
        end

        % Compute domain from npoints
        for i = 1:2
            p.domain{i} = linspace( p.xl(i,1), p.xl(i,2), p.npoints(i));
        end
    end

else % Domain has been provided

    % Domain supercedes 'xl', 'scale', and 'npoints'
    if ~isempty(p.xl) || ~isempty(p.scale) || ~isempty(p.npoints)
        warning('Optional argument ''domain'' was provided, so any optional arguments ''xl'', ''scale'', and ''xl'' will be ignored.');
    end

    % Ensure domain integrity
    if isnumeric(p.domain) % Numeric data repeated for each domain
        p.domain = {p.domain(:),p.domain(:)};
    elseif ~(iscell(p.domain) && numel(p.domain)==2) % Incorrect format
        error('Optional argument ''domain'' must either be numeric or a 2 element cell array');
    else % Ensure integrity of domain contents
        for i = 1:2
            if ~isnumeric(p.domain{i}) || any(isnan(p.domain{i})) || any(isinf(p.domain{i}))
                error('Optional argument ''domain'' must contain non-nan and non-inf numeric values');
            end
        end
    end
end 
%%%%%%%%%%%%%%%%%%%%%%%%%% End of 'domain' defaults %%%%%%%%%%%%%%%%%%%%%%%

%% Compute KDE

% Compute full 2D domain
[x1,x2] = meshgrid(p.domain{1}, p.domain{2});

% Compute deviations of data along both dimensions
d1 = repmat(x1,1,1,n(1)) - shiftdim(repmat(d(:,1),1,size(x1,1),size(x1,2)),1) ;
d2 = repmat(x2,1,1,n(1)) - shiftdim(repmat(d(:,2),1,size(x2,1),size(x2,2)),1) ;

% Compute KDE
y = k(d1,d2,p.bw)*p.norm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UTILITIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = iqr(x)
y = diff(prctile(x, [25, 75]));