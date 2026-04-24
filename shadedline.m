function varargout = shadedline(x,y,e,varargin)

% Force these to row vectors
x = x(:)';
y = y(:)';

% Set hold behavior
ish = ishold;

% Be sure to wipe old plot if hold is off
if ~ish
    clf;
end

%% Retrieve optional arguments that cannot be passed to plot()
try
    % keyboard
    % Parse varargin for anything that won't be accepted by plot()
    [varargin,  fa ] = inputChecker(varargin,'FaceAlpha',         .1 );
    [varargin,  fc ] = inputChecker(varargin,'FaceColor',         [] );
    [varargin,  ea ] = inputChecker(varargin,'EdgeAlpha',         [] );
    [varargin,  ec ] = inputChecker(varargin,'EdgeColor',         [] );
    [varargin, els ] = inputChecker(varargin,'EdgeLineStyle',     [] );
    [varargin, elw ] = inputChecker(varargin,'EdgeLineWidth',     [] );
    [varargin,  em ] = inputChecker(varargin,'EdgeMarker',        [] );
    [varargin, ems ] = inputChecker(varargin,'EdgeMarkerSize',    [] );
    [varargin, emc ] = inputChecker(varargin,'EdgeMarkerColor',   [] );
    
    % Check that any additional arguments are valid when passed directly to
    % plot(); let plot() catch offenders
    plot(nan,nan,varargin{:});

    % Fill will annoyingly crash without this argument
    varargin0 = {'k'};  %,''Marker','none'};

    % Input the lengthly list of optionals manually...
    if ~isempty(fa)
        varargin0 = [varargin0, 'FaceAlpha', fa];
    end
    if ~isempty(fc)
        varargin0 = [varargin0, 'FaceColor', fc];
    end
    if ~isempty(ea)
        varargin0 = [varargin0, 'EdgeAlpha', ea];
    end
    if ~isempty(ec)
        varargin0 = [varargin0, 'EdgeColor', ec];
    end
    if ~isempty(els)
        varargin0 = [varargin0, 'LineStyle', els];
    end
    if ~isempty(elw)
        varargin0 = [varargin0, 'LineWidth', elw];
    end
    if ~isempty(em)
        varargin0 = [varargin0, 'Marker', em];
    end
    if ~isempty(ems)
        varargin0 = [varargin0, 'MarkerSize', ems];
    end
    if ~isempty(emc)
        varargin0 = [varargin0, 'MarkerFaceColor', emc, 'MarkerEdgeColor', emc];
    end

    % If EdgeColor and EdgeLineStyle aren't provided, default to no line,
    % overriding the default, which is a black line
    if isempty(ec) && isempty(els) && isempty(elw)
        varargin0 = [varargin0, 'LineStyle', 'none'];
    end

    % Check that the arguments specifically targeting fill() are valid
    % when passed; let fill() catch offenders
    fill(nan,nan,varargin0{:});    

catch err
    throwAsCaller(err);
end


%% Plot
try
    hold on;

    % Plot line
    h = plot(x,y,varargin{:});

    % If FaceColor isn't provided, default to whatever color is used for the
    % line
    if ~strcmpi('FaceColor',varargin0)
        varargin0 = [varargin0, 'FaceColor', h.Color];
    end

    % Plot shading
    if isvector(e)
        fill([x,fliplr(x)],[y-e(:)',fliplr(y+e(:)')],varargin0{:});
    else
        fill([x,fliplr(x)],[e(1,:),fliplr(e(2,:))],varargin0{:});
    end

catch err
    % Likely bad arguments for plot()
    throwAsCaller(err);
end

%% Wrap up

if nargout
    varargout{1} = h;
end

hold(ish);