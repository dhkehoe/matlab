function varargout = violin(x,y,varargin)
% Construct a plot with 1 or more violin densities. Optional arguments
% specified with MATLAB name-pair convention. All arguments accepted by
% fill() can be passed to define drawing behavior and apply equally to all 
% violines, except 'FaceColor', which is modified to accept multiple values
% (see Optional Arguments below). All arguments accepted by kde() can be
% passed to define density smoothing behavior and apply equally to all
% violins.
% 
%
% USAGE
%   violin(y);
%   violin(x,y);
%   violin(x,y, 'OptionalArgName',OptionalArgValue, ... );
%   [h, fx, fy] = violin(x,y 'OptionalArgName',OptionalArgValue, ... );
%
%
% INPUTS
%   x - The 'x' location(s) to center each violin. There must be one
%       element of 'x' for each collection of 'y' values. If omitted, 
%           x = 1:N
%       where 'N' is the number of violins.
%
%   y - The collection of values that are density smoothed and presented as
%       violins. There are 2 accepted formats:
%           (1) An K by N by M numeric array, where K is the number of data
%               points within each violin, N is the number of positions 
%               along the 'x' axis to draw violins, and M is the number of
%               conditions at each 'x' axis postion.
%           (2) An N by M cell array, with the same definitions of N and M
%               as above, but allowing for a jagged-array of any number of
%               data points to be smoothed within each cell.
%           
%
% OPTIONAL INPUTS
%   facecolor - Specifies the FaceColor of each violin. There must be one
%               'FaceColor' for each condition (M, see above). That is,
%               'FaceColor' can be either an M by 3 numeric vector of RGB
%               color values or a length M cell array of characters
%               accepted by plot(), e.g., 'k' in plot(x,y,'k'). If M==1,
%               then the 'FaceColor' value will be applied to all violins
%               equally.
%                   (default = pickColors(M) )
%
%       width - Scalar specifying the total width of each violin plot.
%                   (default = .8)
%
%   bandwidth - Scalar specifying the smoothing bandwidth passed to kde().
%                   (default = [])
%
%   precision - Scalar specifying the number of smoothing points passed to
%               kde(). 
%                   (default = [])
%
%      domain - A matrix of values specifying the exact smoothing domain
%               passed to kde().
%                   (default = [])
%
%        side - A string specifying whether to draw the violin plot on
%               the 'left', 'right', or 'both' sides about the 'x' point(s).
%                   (default = 'both')
%
%      bounds - A 2-element, sorted vector indicating the interval outside
%               of which the data is truncated. Same units as the data.
%                   (default = [-inf, inf])
%      cutoff - A 2-element, sorted vector bounded on the interval (0,1)
%               indicating the inner proportion of the data to include.
%               E.g., [.025,.975] indicates to utilize the inner 95% of the
%               data.
%                   (default = [0, 1])
%
% OUTPUTS
%    h - A handle to the current plot.
%   fx - An N x M cell array, where N is the number of locations along the
%        'x' axis that contain a violin and M is the number of conditions
%        at each 'x' location. Within each cell is the set of x-coordinate
%        values used to draw the i_th, j_th violin.
%   fy - An N x M cell array, where N is the number of locations along the
%        'x' axis that contain a violin and M is the number of conditions
%        at each 'x' location. Within each cell is the set of y-coordinate
%        values used to draw the i_th, j_th violin.
%
%   
%
%   DHK - Sept 5, 2024

%% Data integrity checks

% 'y' wasn't actually passed, but some name-pair optionals were
if exist('y','var') && ischar(y)
    varargin = [y,varargin];
    clear y;
end

% 'y' does not exist, so it was passed as 'x'
if ~exist('y','var')
    y = x;
    clear x;
end

% 'y' was passed as numeric
if isnumeric(y)
    [~,ngrp,ncon] = size(y);
    Y = cell(ngrp,ncon);
    for i = 1:ngrp
        for j = 1:ncon
            Y{i,j} = y(:,i,j);
        end
    end
    y = Y; clear Y;

elseif iscell(y) % 'y' was passed as cell type
    [ngrp,ncon] = size(y);

else % no other formats allowed
        error('Unsupported format for ''y''. Must be either an NxGxC numeric matrix or a GxC cell array of color values, where ''G'' is the number of groups and ''C'' is the number of conditions.');
end

% 'x' does not exist, default it to 1:n
if ~exist('x','var')
    x = 1:ngrp;
elseif numel(x) ~= ngrp % 'x' was passed, but contains the wrong number of elements
    error('Insufficient number of ''x'' values for the number of groups (number of groups = %d)',ngrp);
end

% Optional name-pair arguments that cannot be passed to fill()
sideStr = {'both','right','left'};
try
    [varargin, width] = inputChecker(varargin,'width',.8, @(x)isnumeric(x)&&isscalar(x), 'Optional argument ''Width'' must be a numeric scalar.');
    [varargin,    bw] = inputChecker(varargin,'bandwidth',[], @(x)isnumeric(x)&&isscalar(x), 'Optional argument ''Bandwidth'' must be a numeric scalar.');
    [varargin,  prec] = inputChecker(varargin,'precision',[], @(x)isnumeric(x)&&isscalar(x), 'Optional argument ''Precision'' must be a numeric scalar.');
    [varargin,  side] = inputChecker(varargin,'side','both', @(x)ischar(x)&&any(strcmpi(x,sideStr)), 'Optional argument ''Side'' must be one of the following strings: ''both'', ''right'', or ''left''.');
    [varargin,bounds] = inputChecker(varargin,'bounds',[], @(x)isnumeric(x)&&numel(x)==2&&issorted(x), 'Optional argument ''Bounds'' must be a sorted, 2-element vector.');
    [varargin,domain] = inputChecker(varargin,'domain',[], @isnumeric, 'Optional argument ''Domain'' must be numeric.');
    [varargin,cutoff] = inputChecker(varargin,'cutoff',[0,1], @(x)isnumeric(x)&&numel(x)==2&&issorted(x)&&all(0<=x&x<=1), 'Optional argument ''Cutoff'' must be a sorted, 2-element vector of values within the interval (0,1).');
catch err
    % Trim inputChecker from the call stack in the error report
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end
side = find(strcmpi(sideStr,side));

% Adjust the colors according to the number of conditions
[varargin, col] = inputChecker(varargin,'facecolor',[],@(x)true,'');
if isempty(col)
    col = pickColors(ncon);
end
if isnumeric(col)
    C = cell(size(col,1),1);
    for i = 1:numel(C)
        C{i} = col(i,:);
    end
    col = C; clear C;
elseif ischar(col)
    col = {col};
elseif ~iscell(col)
    error('Unsupported ''FaceColor'' specifier. Must be either an Mx3 RGB numeric matrix or a length M cell array of color values, where ''M'' is equal to the number of conditions.');
end
if isscalar(col)
    col = repmat(col,ncon,1);
end
if numel(col) ~= ncon
    error('Insufficient number of ''FaceColor'' values for the number of conditions (number of conditions = %d)',ncon);
end


%% Fit the KDEs to the data
kdearg = {};
if ~isempty(bw)
    kdearg = [kdearg, 'bw', bw];
end
if ~isempty(prec)
    kdearg = [kdearg, 'npoints', prec];
end
if ~isempty(bounds)
    kdearg = [kdearg, 'bounds',bounds,'xl',bounds];
end
if ~isempty(domain)
    kdearg = [kdearg, 'domain',domain];
end

fx = cell(ngrp,ncon);
fy = fx;
mmax = 0;
for i = 1:ngrp
    for j = 1:ncon
        % Isolate the central portion of the data
        Y = sort(y{i,j});
        N = numel(Y);
        B = round(N*cutoff);
        B = [max(B(1),1), min(B(2),N)]; 

        [fx{i,j},fy{i,j}] = kde( Y( B(1):B(2) ), kdearg{:});
        fx{i,j} = [fx{i,j}(1), fx{i,j}, fx{i,j}(end)];
        fy{i,j} = [         0, fy{i,j},            0];
        t = max(fy{i,j});
        if mmax < t
            mmax = t;
        end
    end
end

%% Draw the violin plots

% Adjust width so that it's meaningful with densities that are drawn symmetrically
width = width/2;

% Set the correct holding behavior
ish = ~ishold;
if ish
    clf;
end
hold on;

% Draw
for i = 1:ngrp
    for j = 1:ncon
        switch side
            case 1 % both
                fx{i,j} = [ fx{i,j},  fliplr(fx{i,j}) ];
                fy{i,j} = [ fy{i,j}, -fliplr(fy{i,j}) ] / mmax*width + x(i);
                fill(fy{i,j},fx{i,j},'k','FaceColor',col{j},varargin{:});
            case 2 % right
                fill( [fy{i,j},fy{i,j}(1)]/mmax*width+x(i),[fx{i,j},fx{i,j}(1)],'k','FaceColor',col{j},varargin{:});
            case 3 % left
                fill(-[fy{i,j},fy{i,j}(1)]/mmax*width+x(i),[fx{i,j},fx{i,j}(1)],'k','FaceColor',col{j},varargin{:});
        end
    end
end

% Restore the hold state
if ish
    hold off;
end

%% Return handle if necessary
if nargout
    varargout{1} = gca;
    varargout{2} = fx;
    varargout{3} = fy;
end