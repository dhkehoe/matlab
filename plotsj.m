function h = plotsj(x,y,varargin)
%   Doc
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

% Quick error check
if ~(isnumeric(y) && isnumeric(x))
    error('Non-numeric data is invalid for plotting.');
end

% Save initial hold state
ish = ishold;


try
    % Retrieve subject args
    [varargin, col ] = inputChecker(varargin,'color',           [], [], []);
    [varargin, la  ] = inputChecker(varargin,'alpha',           .3, [], []);
    [varargin, ec  ] = inputChecker(varargin,'markeredgecolor', [], [], []);
    [varargin, fc  ] = inputChecker(varargin,'markerfacecolor', [], [], []);
    [varargin, ea  ] = inputChecker(varargin,'markeredgealpha', [], [], []);
    [varargin, fa  ] = inputChecker(varargin,'markerfacealpha', [], [], []);
    [varargin, ms  ] = inputChecker(varargin,'markersize',      30, [], []);
    [varargin, lw  ] = inputChecker(varargin,'linewidth',        1, [], []);
    
    % Be sure to wipe old plot if hold is off
    if ~ish
        clf;
    end

    % Check that any additional arguments are valid when passed directly to
    % plot(); let plot() catch these
    h = plot(nan,nan,varargin{:});
    % Get a handle for replicating the plot format

    % Set some other critical defaults
    if isempty(col)
        col = h.Color;
    end
    if isempty(ec)
        ec = 'none';
    end
    if isempty(fc)
        fc = col;
    end
    if isempty(ea)
        ea = 0;
    end
    if isempty(fa)
        fa = la;
    end

catch err
    throwAsCaller(err);
end

h = gca;

%% Plot

% Temporarily turn hold on
hold on;

% Plot scatter
X = repmat(x(:)',size(y,1),1);
scatter(X(:),y(:),ms,'MarkerFaceColor',fc,'MarkerEdgeColor',ec,'MarkerFaceAlpha',fa,'MarkerEdgeAlpha',ea);
% Plot lines
for i = 1:size(y,1)
    plot(x,y(i,:),'LineStyle','-','Marker','none','Color',col,'LineAlpha',la,'LineWidth',lw);
end

%% Restore initial hold state
if ~ish
    hold off;
end