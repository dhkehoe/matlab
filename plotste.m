function varargout = plotste(x,y,varargin)
% 
%
% USAGE
%   h = plotste(y);
%   h = plotste(x,y);
%   h = plotste(y, 'OptionalArgName',optionalArgValue, ...);
%   h = plotste(x,y, 'OptionalArgName',optionalArgValue, ...);
%
% INPUT
%   y - 
%
% OPTIONAL INPUT
%               x - 
%   whiskerlength - 
%            line - 
%            type - 
%         weights - 
%       ignoreinf - 
%           polar - 
%     openmarkers - 
%
% OUTPUT
%   h - 
%
%
%   DHK - June 12, 2024

% Wish list:
%   (1) 'lin' argument behavior for polar plot
%   (2) 'lin' argument behavior for polar plot

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

% Retrieve optional arguments that cannot be passed to plot()
try
    [varargin, wl  ] = inputChecker(varargin,'whiskerlength',0, @(x)isnumeric(x)&&isscalar(x),                         'Optional argument ''WhiskerLength'' must be a numeric scalar.');
    [varargin, lin ] = inputChecker(varargin,'line',        [], @(x)iscell(x),                                         'Optional argument ''Line'' must be a numeric scalar.');
    [varargin, type] = inputChecker(varargin,'type',    'cont', @(x)ischar(x)&&any(contains(lower(x),{'cont','prop'})),'Optional argument ''Type'' must be a string, with accepted values ''cont'' or ''prop''.');
    [varargin, n   ] = inputChecker(varargin,'weights',     [], @(x)isnumeric(x)&&all(size(x)==size(y)),               'Optional argument ''Weights'' must be a matrix with the same shape as ''y''.');
    [varargin, ign ] = inputChecker(varargin,'ignoreinf',    0, @(x)isnumeric(x)&&isscalar(x),                         'Optional argument ''IgnoreInf'' must be a logical scalar.');
    [varargin, pol ] = inputChecker(varargin,'polar',        0, @(x)isnumeric(x)&&isscalar(x),                         'Optional argument ''Polar'' must be a logical scalar.');
    [varargin, plab] = inputChecker(varargin,'polarlabels', [], @(x)isnumeric(x)&&isscalar(x),                         'Optional argument ''PolarLabels'' must be a numeric scalar.');
    [varargin, opmk] = inputChecker(varargin,'openmarkers', [], @(x)isvector(x)&&numel(x)==size(y,2),                   'Optional argument ''OpenMarkers'' must contain the same number of elements as there are columns in ''y''.');
catch err
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end

% Convert 'type' to an integer
type = find(strcmpi(type,{'cont','prop'})); 

% Set additional error checking + default behavior
if type==2 && isempty(n) % Must provide 'n' if data is proportional
    error('When optional argument ''Type'' is ''prop'', optional argument ''Weights'' must be provided.');
end
if ~isempty(n) % If 'weights' arg is provided, 'type' is set to proportional data
    type = 2;
end

%% Compute plotting variables

% Save initial hold state
ish = ishold;

% Be sure to wipe old plot if hold is off
if ~ish
    clf;
end

% Temporarily turn hold on
hold on;

% Compute means and standard errors
switch type
    case 1 % Continuous data type
        if ign
            i = ~(isinf(y)|isnan(y));
            m = nan(1,size(y,2));
            e = m;
            for j = 1:numel(m)
                m(j) = mean(y(i(:,j),j));
                e(j) = sqrt(  sum( (y(i(:,j),j)-m(j)).^2 ) ./ (sum(i(:,j))-1) ./sum(i(:,j))  );
            end
        else
            m = nanmean(y); %#ok
            e = nanste(y);
        end
    case 2 % Proportion data type
        if ign
            i = ~(isinf(y)|isnan(y));
            s = sum(i);
            m = nan(1,size(y,2));
            for j = 1:numel(m)
                m(j) = sum(y(i(:,j),j)) ./ s(j);
            end
        else
            s = nansum(n); %#ok
            m = nansum( y.* n ) ./ s; %#ok            
        end
        e = sqrt( m.*(1-m) ./ s );
end

% Convert standard error to ( M +/- SE )
e = m + [-1;1] .* e;

% Compute whiskers
if wl
    w = x + [-1;1] .* wl/2;
end

%% Plot

if pol  % Polar plot

    % Compute the y-scaling
    [zl, tix, lab] = axlim(rangei(e,[],'all'));
    % units = tix(2)-tix(1);

    % Draw the scaling circles
    ntix = numel(tix);
    t = 0:.01:2.01*pi;
    for i = 1:ntix
        plot(cos(t)*i/ntix,sin(t)*i/ntix,'k--');
    end

    % Set scale
    xyl = [-1,1];
    xlim(xyl);
    ylim(xyl);   

    % Draw the quadrants
    plot(xyl,[0,0],'k--');
    plot([0,0],xyl,'k--');

    % Draw the means (line?)
    if xflag
        x = x./numel(x)*2*pi;
    end
    m = (m-zl(1))/range(zl);
    h = plot(cos(x).*m, sin(x).*m, varargin{:}, 'LineStyle', 'none');

    % Draw the error bars
    e = (e-zl(1))/range(zl);
    for i = 1:size(y,2)
        plot(cos(x(i)).*e(:,i), sin(x(i)).*e(:,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color); % Override the marker property, ensure color matches
        if wl
            plot(cos(x(i)+pi/2)*wl*[-1,1]+cos(x(i))*e(1,i), sin(x(i)+pi/2)*wl*[-1,1]+sin(x(i))*e(1,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color);
            plot(cos(x(i)+pi/2)*wl*[-1,1]+cos(x(i))*e(2,i), sin(x(i)+pi/2)*wl*[-1,1]+sin(x(i))*e(2,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color);
        end
    end

    % Set scale labels
    if isempty(plab)
        x = sort(abs(mod(x,pi*2)));
        ad = abs(diff(x(:)));
        i = find(ad==max(ad));
        if isscalar(i)
            plab = atan2(mean(sin(x(i+[0,1]))),mean(cos(x(i+[0,1]))));
        else
            plab = pi/4;
        end       
    end
    for i = 1:ntix
        text(cos(plab)*i/ntix,sin(plab)*i/ntix,lab{i},...
            'HorizontalAlignment','center','VerticalAlignment','middle');
    end
    axis off;
    
else % Linear plot   

    % Get a handle for replicating the plot format
    h = plot(x, nan(size(x)), varargin{:});

    % Draw error bars
    for i = 1:size(y,2)
        plot([0;0]+x(i), e(:,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color); % Override the marker property, ensure color matches
        if wl
            plot(w(:,i), [0;0]+e(1,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color);
            plot(w(:,i), [0;0]+e(2,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color);
        end
    end

    % Draw means
    if isempty(opmk)
        plot(x, m, varargin{:});
    else
        % Override the 'MarkerFaceColor' argument, if provided
        i = find(strcmpi(varargin,'markerfacecolor'));
        if isempty(i)
            i = numel(varargin)+1;
            varargin{i} = 'markerfacecolor';
        end
        varargin{i+1} = 'w';

        % Draw the open-faced markers (draw them all so that they're
        % all connected with a line)
        plot(x, m, varargin{:},'Color',h.Color);

        % Draw the closed-faced markers
        varargin{i+1} = h.Color;
        plot(x(~opmk), m(~opmk), varargin{:},'Color',h.Color);
    end

end

%% Restore initial hold state
if ~ish
    hold off;
end

%% Set return args
if nargout
    varargout{1} = h;
end