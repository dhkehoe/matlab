function varargout = violin(x,y,varargin)
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
    [varargin,  prec] = inputChecker(varargin,'precision',101, @(x)isnumeric(x)&&isscalar(x), 'Optional argument ''Precision'' must be a numeric scalar.');
    [varargin,  side] = inputChecker(varargin,'side','both', @(x)ischar(x)&&any(strcmpi(x,sideStr)), 'Optional argument ''Side'' must be one of the following strings: ''both'', ''right'', or ''left''.');
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
    error('Unsupported ''FaceColor'' specifier. Must be either an Nx3 RGB numeric matrix or a length N cell array of color values, where ''N'' is equal to the number of conditions.');
end
if numel(col) ~= ncon
    error('Insufficient number of ''FaceColor'' values for the number of conditions (number of conditions = %d)',ncon);
end


%% Fit the KDEs to the data
kdearg = {'npoints',prec};
if ~isempty(bw)
    kdearg = [kdearg, 'bw', bw];
end

fx = cell(ngrp,ncon);
fy = fx;
mmax = 0;
for i = 1:ngrp
    for j = 1:ncon
        [fx{i,j},fy{i,j}] = kde(y{i,j},kdearg{:});
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
                fill( [fy{i,j},-fliplr(fy{i,j})]/mmax*width+x(i),[fx{i,j},fliplr(fx{i,j})],'k','FaceColor',col{j},varargin{:});
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
end