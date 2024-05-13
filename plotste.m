function h = plotste(x,y,varargin)
%
%
%
%

%% Manage input

% Check whether 'x' was omitted
xflag = false;
if nargin<2 
    % Only a single argument
    xflag = true;
elseif ischar(y)
    % If 'y' is a string, it's a property name belonging to varargin
    varargin = [y, varargin];
    xflag = true;
elseif numel(x) ~= size(y,2)
    % 'x' was provided, but the size is mismatched with matrix 'y'
    error('''x'' must contain as many elements as columns in ''y''.');
end

% Create 'x'
if xflag
    y = x;
    x = 1:size(y,2);
else % Ensure x is a row vector
    x = reshape(x,1,numel(x));
end

% Check for 'whiskerlength' optional arg, which cannot be passed to plot()
wl = 0;
for i = 1:numel(varargin)
    if i<numel(varargin) && ischar(varargin{i}) && strcmpi(varargin{i},'whiskerlength')
        wl = varargin{i+1};
        if ~( isnumeric(wl) && isscalar(wl) )
            error('Optional argument ''whiskerLength'' must be a numeric scalar.');
        end
        varargin(i:i+1) = [];
        break;
    end
end

% Check for 'line' optional arg, which cannot be passed to plot()
lin = 1;
for i = 1:numel(varargin)
    if i<numel(varargin) && ischar(varargin{i}) && strcmpi(varargin{i},'line')
        lin = varargin{i+1};
        if ~( isnumeric(wl) && isscalar(wl) )
            error('Optional argument ''line'' must be a numeric scalar.');
        end
        varargin(i:i+1) = [];
        break;
    end
end

% Save initial hold state, temporarily turn hold on
ish = ishold;
hold on;

%% Plot
m = nanmean(y);                                         %#ok
e = m + [-1;1] .* nanstd(y) ./ sqrt( sum(~isnan(y)) );  %#ok

% Compute whiskers
if wl
    w = x + [-1;1] .* wl/2;
end

% Draw means
if lin
    h = plot(x, m, varargin{:});
else
    h = [];
end

% Draw error bars
for i = 1:size(y,2)
    plot([0;0]+x(i), e(:,i), varargin{:}, 'Marker','none'); % Override the marker property
    if wl
        plot(w(:,i), [0;0]+e(1,i), varargin{:}, 'Marker','none');
        plot(w(:,i), [0;0]+e(2,i), varargin{:}, 'Marker','none');
    end
end

%% Restore initial hold state
if ~ish
    hold off;
end