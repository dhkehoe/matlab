function varargout = uplot(x,y,varargin)
% Create a unity plot, over groups, with many customizable options specifed
% using the MATLAB name-pair convention.
%
% USAGE
%   h = uplot(x,y);
%   uplot(x);
%   uplot(x,y, 'OptionalArgName',optionalArgValue, ... );
%
% INPUT
%   x - The 'x' axis values in the unity plot. An N by M matrix, where N is
%       the number of observations and M is the number of groups.
%       Alternatively, if 'y' is empty, 'x' is an N by 2 by M matrix, with
%       'x' and 'y' values stacked along the second dimension.
%   y - The 'y' axis values in the unity plot. An N by M matrix, where N is
%       the number of observations and M is the number of groups.
%       Alternatively, 'y' may be empty (see previous).
%
%
% OPTIONAL INPUT
%
%   FIGURE PROPERTIES
%               Handle - Handle to an Axes object with which to draw.
%                               (default = gca)
%
%            EqualAxes - Boolean indicating whether to automatically
%                        rescale the axes to have an aspect ratio of 1.
%                               (default = true)
%
%                Ratio - A scalar proportion indicating how much of the
%                        width/height of the plot is dedicated to the
%                        scatterplot, where 1-ratio is dedicated to the
%                        histogram.
%                               (default = .5)
%
%             FontSize - Scalar indicating the font size of all labels.
%
%   HISTOGRAM PROPERTIES
%                 Bins - A sorted vector specifying the bin edges for
%                        histogramming.
%                               (default = linspace(min(d),max(d),sqrt(numel(d))) ),
%                                   for d = x-y      
%
%        Normalization - A string indicating whether the histogram units
%                       are 'freq', 'prob', 'pdf'; i.e., frequencies,
%                       probabilities, or probability densities.
%                               (default = 'freq')
%
%         AxisLocation - A string indicating whether the histogram y-axis
%                        is 'left', 'right', or 'center' aligned. Note that
%                        the axis label is ignored when
%                        AxisLocation = 'center'.
%                               (default = 'left')
%
%         BarLineStyle - Set the 'LineStyle' property of the fill() object
%                        used to draw each histogram bar.
%                               (default = '-')
%
%         BarLineColor - Set the 'EdgeColor' property of the fill() object
%                        used to draw each histogram bar.
%                               (default = [1,1,1]
%
%         BarLineWidth - Set the 'LineWidth' property of the fill() object
%                        used to draw each histogram bar.
%                               (default = .5)
%
%         BarFaceColor - Set the 'FaceColor' property of the fill() object
%                        used to draw each histogram bar. Optionally, this
%                        can be an M by 3 matrix, where M is the number of
%                        groups and each row specifies the RGB values for
%                        each group.
%                               (default = 'MarkerFaceColor', see below)
%
%         BarFaceAlpha - Set the 'FaceAlpha' property of the fill() object
%                        used to draw each histogram bar.
%                               (default = .5)
%
%            BarYLabel - A string label for the y-axis of the histogram. Is
%                        ignored when AxisLocation = 'center'.
%                               (default = 'count' | Normalization = 'freq')
%                               (default = 'probability' | Normalization = 'prob')
%                               (default = 'density' | Normalization = 'pdf')
%
%             BarXTick - A sorted vector of tick marks along the x-axis of
%                        the histogram.
%                                see axlim.m  for default behavior
%
%             BarYTick - A sorted vector of tick marks along the x-axis of
%                        the histogram.
%                                see axlim.m  for default behavior
%
%   SCATTER PLOT PROPERTIES
%               Marker - Set the 'Marker' property of the scatter() object
%                        used to draw each scatterplot. Can be an M-element
%                        cell array where M is the number of groups and
%                        each element specifies a marker style for a group.
%                               (default = 'o')
%
%           MarkerSize - Set the 'SizeData' property of the scatter()
%                        object used to draw each scatterplot. Can be an
%                        M-element vector where M is the number of groups
%                        and each element specifies a marker size for a
%                        group.
%                               (default = 36)
%
%      MarkerLineWidth - Set the 'LineWidth' property of the scatter()
%                        object used to draw each scatterplot.  
%                               (default = .5)
%
%      MarkerFaceColor - Set the 'MarkerFaceColor' property of the
%                        scatter() object used to draw each scatterplot.
%                        Optionally, this can be an M by 3 matrix, where M
%                        is the number of groups and each row specifies the
%                        RGB values for a group.
%                               (default = MATLAB default colors)
%
%      MarkerFaceAlpha - Set the 'MarkerFaceAlpha' property of the
%                        scatter() object used to draw each scatterplot.
%                               (default = .5)
%
%      MarkerEdgeColor - Set the 'MarkerEdgeColor' property of the
%                        scatter() object used to draw each scatterplot.
%                        Optionally, this can be an M by 3 matrix, where M
%                        is the number of groups and each row specifies the
%                        RGB values for a group.
%                               (default = MarkerFaceAlpha)
%
%      MarkerEdgeAlpha - Set the 'MarkerEdgeAlpha' property of the
%                        scatter() object used to draw each scatterplot.
%                               (default = .5)
%
%                XTick - A sorted vector of tick marks along the x-axis of
%                        the histogram.
%                                see axlim.m  for default behavior
%
%                YTick - A sorted vector of tick marks along the y-axis of
%                        the histogram.
%                                see axlim.m  for default behavior
%
%               XLabel - A string label for the x-axis of the scatterplot.
%                                   (default = '')
%
%               YLabel - A string label for the y-axis of the scatterplot.
%                                   (default = '')
%
%           AxisLimits - A 2-element vector specifying the lower/upper
%                        bounds of the scatter plot for both axes.
%                                   (default = range over [xlim;ylim])
%
% OUTPUT
%   h - A handle to the axes object on which the unity-plot is drawn.
%
%
%
%   DHK - March 15, 2026

%% Manage input

% Check whether 'y' was omitted
yflag = false;
if nargin<2
    % Only a single argument
    yflag = true;
elseif ischar(y)
    % If 'y' is a string, it's a property name belonging to varargin
    varargin = [y, varargin];
    yflag = true;
elseif ~eqsize(x,y)
    % 'y' was provided, but the size is mismatched with matrix 'x'
    error('''x'' must be the same size as ''y'' along all dimensions.');
end

% Disaggregate x into x and y
if yflag
    y = squeeze(x(:,2,:));
    x = squeeze(x(:,1,:)); 
end

% Compute the difference, check the size
d = x-y;
if 2<ndim(d)
    error(sprintf(['Misformatted data. Acceptable formats are\n',...
        '\t(1) ''x'' is an (N by 2 by M) matrix and ''y'' is empty\n',...
        '\t(2) ''x'' and ''y'' are both (N by M) matrices\n',...
        'where ''N'' is the number of observations and ''M'' is the number of groups.']));
end
ngrp = size(d,2);

%% Parse optional arguments

% Save initial hold state
ish = ishold;

try
    % Figure
    [varargin,     h] = inputChecker(varargin,'Handle',          gca, @isaxes, 'Optional argument ''Handle'' must be a scalar handle to a valid axis object.');
    [varargin, p.eax] = inputChecker(varargin,'EqualAxes',      true, @(x)isnumeric(x)&&isscalar(x)&&islogical(logical(x)), 'Optional argument ''EqualAxes'' must be a scalar castable to logical type.');
    [varargin, p.rto] = inputChecker(varargin,'Ratio',            .5, @(x)isnumeric(x)&&isscalar(x)&&0<x&&x<1, 'Optional argument ''Ratio'' must be a numeric scalar, greater than 0 and less than 1, specifying the size of the scatter plot relative to the histogram.');
    [varargin, p.axl] = inputChecker(varargin,'AxisLocation', 'left', @ischar, 'Optional argument ''AxisLocation'' must be a string.');
    [varargin, p.fsz] = inputChecker(varargin,'FontSize',         12, @(x)isnumeric(x)&&isscalar(x),  'Optional argument ''FontSize'' must be a numeric scalar.');    
    [varargin, p.xlb] = inputChecker(varargin,'XLabel',           '', @ischar, 'Optional argument ''XLabel'' must be a string.');
    [varargin, p.ylb] = inputChecker(varargin,'YLabel',           '', @ischar, 'Optional argument ''YLabel'' must be a string.');
    [varargin, p.xtx] = inputChecker(varargin,'XTick',            [], @(x)isnumeric(x)&&issorted(x), 'Optional argument ''XTick'' must be a sorted vector.');
    [varargin, p.ytx] = inputChecker(varargin,'YTick',            [], @(x)isnumeric(x)&&issorted(x), 'Optional argument ''YTick'' must be a sorted vector.');
    [varargin, p.alm] = inputChecker(varargin,'AxisLimits',       [], @(x)isnumeric(x)&&issorted(x)&&numel(x)==2, 'Optional argument ''AxisLimits'' must be a sorted vector with 2 elements.');
    [varargin, p.org] = inputChecker(varargin,'Origin',           [], @(x)isnumeric(x)&&numel(x)<=2, 'Optional argument ''Origin'' must be a numeric scalar, specifying the size of the histogram origin offset (upward/rightward shift) in data units. It can either by scalar or an (x,y) pair.');
    % Scatter plot
    [varargin, p.mkr] = inputChecker(varargin,'Marker',        {'o'});
    [varargin, p.msz] = inputChecker(varargin,'MarkerSize',       36);
    [varargin, p.mlw] = inputChecker(varargin,'MarkerLineWidth',  .5); 
    [varargin, p.mfc] = inputChecker(varargin,'MarkerFaceColor'); % Will default these manually
    [varargin, p.mec] = inputChecker(varargin,'MarkerEdgeColor');
    [varargin, p.mfa] = inputChecker(varargin,'MarkerFaceAlpha', .5);
    [varargin, p.mea] = inputChecker(varargin,'MarkerEdgeAlpha',  1);
    % Histogram
    [varargin, p.bin] = inputChecker(varargin,'Bins',             [], @(x)isnumeric(x)&&issorted(x), 'Optional argument ''Bins'' must be a sorted vector or scalar integer.');
    [varargin, p.bnz] = inputChecker(varargin,'Normalization','freq', @ischar, 'Optional argument ''Normalization'' must be a string.');
    [varargin, p.bls] = inputChecker(varargin,'BarLineStyle',    '-');
    [varargin, p.blc] = inputChecker(varargin,'BarLineColor',[1,1,1]);
    [varargin, p.blw] = inputChecker(varargin,'BarLineWidth',     .5);
    [varargin, p.bfc] = inputChecker(varargin,'BarFaceColor');
    [varargin, p.bfa] = inputChecker(varargin,'BarFaceAlpha',     .5);
    [varargin, p.blb] = inputChecker(varargin,'BarYLabel',        [], @ischar,'Optional argument ''BarLabel'' must be a string.');
    [varargin, p.bxt] = inputChecker(varargin,'BarXTick',         [], @(x)isnumeric(x)&&issorted(x), 'Optional argument ''BarXTick'' must be a sorted vector.');
    [varargin, p.byt] = inputChecker(varargin,'BarYTick',         [], @(x)isnumeric(x)&&issorted(x), 'Optional argument ''BarYTick'' must be a sorted vector.');
    % Undocumented
    [varargin, p.tan] = inputChecker(varargin,'TangentLine',   false, @(x)isscalar(x)&&islogical(logical(x)), 'Optional argument ''TangentLine'' must be a scalar castable to logical type.'); %#ok
    
    % Flag unknown properties
    i = find(cellfun(@ischar,varargin),1);
    if i
        error('Unknown property ''%s''.',varargin{i});
    end

    % % Be sure to wipe old plot if hold is off
    if ~ish
        hold off;
    end

    %%%%%%%%%%%%%
    % Resolve arguments that can be repeated across groups
    if ~iscell(p.mkr)
        p.mkr = {p.mkr};
    end
    if isscalar(p.mkr)
        p.mkr = repmat(p.mkr,1,ngrp);
    end
    if isscalar(p.msz)
        p.msz = repmat(p.msz,1,ngrp);
    end

    % Plot the scatter
    sh = scatter(x,y,'MarkerFaceAlpha',p.mfa,'MarkerEdgeAlpha',p.mea,'LineWidth',p.mlw);
    hold on;

    % Override the awful default color-behavior of scatter() MarkerFaceColor
    if isempty(p.mfc)
        p.mfc = cat(1,sh.CData); % Use MATLAB default colors
    elseif size(p.mfc,1)==1
        p.mfc = repmat(p.mfc,ngrp,1);
    end
    if isempty(p.mec)
        p.mec = p.mfc; % Make edges match faces
    elseif size(p.mec,1)==1
        p.mec = repmat(p.mec,ngrp,1);
    end
    for i = 1:ngrp
        set(sh(i),'MarkerFaceColor',p.mfc(i,:),'MarkerEdgeColor',p.mec(i,:),'Marker',p.mkr{i},'SizeData',p.msz(i));
    end

    % Default the bar color to match the scatter plot
    if isempty(p.bfc)
        p.bfc = p.mfc;
    elseif size(p.bfc,1)==1
        p.bfc = repmat(p.bfc,ngrp,1);    
    end

    % Bogus call to fill() to catch any errors
    for i = 1:ngrp
        t = fill(nan,nan,'k','FaceColor',p.bfc(i,:),'FaceAlpha',p.bfa,'LineWidth',p.blw,'EdgeColor',p.blc,'LineStyle',p.bls);
        delete(t);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Resolve argument 'bins'
    if isempty(p.bin)
        p.bin = ceil(sqrt(size(d,1)));
    end
    if isscalar(p.bin)
        if mod(p.bin,1)
            error('Optional argument argument ''Bins'' must be an integer, when scalar.');
        end
        p.bin = linspace(min(d(:)),max(d(:)),p.bin+1);
    end
    if min(d(:))<p.bin(1) || p.bin(end)<max(d(:))
        warning('Data falls outside the range specified in ''Bins''.');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Resolve argument 'axislocation'
    p.axl = find(contains({'left','right','center'},p.axl));
    if isempty(p.axl)
        error('Optional argument ''AxisLocation'' must be one of the following strings ''left'', ''right'', or ''center''.');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Resolve argument 'norm'
    if strcmpi(p.bnz,'freq')
        ylab = 'count';
    elseif strcmpi(p.bnz,'prob')
        ylab = 'probability';
    elseif strcmpi(p.bnz,'pdf')
        ylab = 'density';
    else
        error(sprintf('Optional argument ''Normalization'' must be one of the following strings:\n\t''freq'', ''prob'', or ''pdf''.'));
    end
    if ~isempty(p.blb)
        ylab = p.blb;
    end

catch err
    throwAsCaller(err);
end

%% Resolve formatting info

% Get the position of this axis
units = get(h,'Units');
set(h,'Units','normalized');
pos = get(h,'Position');

% Get the limits
if isempty(p.alm)
    xline = rangei([xlim,ylim]);
    yline = xline;
else
    xline = p.alm;
    yline = p.alm;    
end

% Resolve 'origin' argument
if isempty(p.org)
    p.org = [range(xline),range(yline)] * .05;
elseif isscalar(p.org)
    p.org = [p.org,p.org];
end

% Get ticks
xlim(xline);
ylim(yline);
set(h,'Position',pos .* [1,1, 1-p.rto, 1-p.rto]); % Reduced size
if isempty(p.xtx)
    p.xtx = get(h,'XTick'); % Get ticks
end
if isempty(p.ytx)
    p.ytx = get(h,'YTick');
end
set(h,'Position',pos); % Jump back to original size

% Compute the expanded limits
xl = [xline(1), xline(2)+range(xline)/p.rto-range(xline)];
yl = [yline(1), yline(2)+range(yline)/p.rto-range(xline)];

% Set axes
setAxes(h,...
    'XLim',xl,'XAxisLine',xline,'XTick',p.xtx,'XLabel',p.xlb,...
    'YLim',yl,'YAxisLine',yline,'YTick',p.ytx,'YLabel',p.ylb,...
    'FontSize',p.fsz); drawnow;

%% Compute histogram(s)

px = cell(1,ngrp);
py = px;
mm = [inf, -inf];
for i = 1:ngrp
    [px{i},py{i}] = edf(d(:,i),p.bin,p.bnz);

    % Get the range of the x-axis
    if min(px{i})<mm(1)
        mm(1) = min(px{i})-diff(px{i}(1:2))/2;
    end
    if mm(2)<max(px{i})
        mm(2) = max(px{i})+diff(px{i}(1:2))/2;
    end
end

% Compute histogram x-axis ticks and limits
if isempty(p.bxt)
    [~,Xtix] = axlim(rangei(p.bin),[],0);
    while Xtix(1)<mm(1)
        Xtix(1) = [];
    end
    while mm(2)<Xtix(end)
        Xtix(end) = [];
    end
else
    Xtix = p.bxt;
end

% Compute histogram y-axis ticks and limits
[Ylim,Ytix] = axlim([0,max([py{:}])],[],0);
if Ytix(end)<Ylim(end)
    Ytix = [Ytix,Ytix(end)+diff(Ytix(1:2))];
end

% Compute the histogram x-axis line (data units)
Xaxlin = rot(mm,[0,0],-pi/4) / sqrt(2) + [xline(2),yline(2)] + p.org;

% Ensure 'origin' argument doesn't go out of bounds
while any( [xl(2),yl(2)]<Xaxlin, 'all')
    xl(2) = xl(2)+range(xl)*.05;
    yl(2) = yl(2)+range(yl)*.05;
    Xaxlin = rot(mm,[0,0],-pi/4) / sqrt(2) + [xline(2),yline(2)] + p.org;
end
xlim(xl);
ylim(yl);

% Find the height of the histogram for scaling
ori = [xline(2),yline(2)] + p.org;
hgt = sqrt(sum((ori-[xl(2),yl(2)]).^2));

% Ensure histogram y-axis fits inside the figure object
if p.axl==2
    xL = [xl(1), fminsearch(@(hgt)abs(sum(pos([1,3]))-ax2fig(hgt-ori(1)+Xaxlin(2,1),'X')),hgt)];
    yL = [xl(1), xL(2)];
else
    yL = [yl(1), fminsearch(@(hgt)abs(sum(pos([2,4]))-ax2fig(hgt-ori(2)+Xaxlin(1,2),'Y')),hgt)];
    xL = [xl(1), yL(2)];
end
hgt = sqrt(sum((ori-[xL(2),yL(2)]).^2)); % Update

% Compute the histogram y-axis line (normalized figure units)
if p.axl<3
    Yaxlin = [0,xL(2)-ori(1); 0, yL(2)-ori(2)]+Xaxlin(p.axl,:)'; % y axis scale
    xtixpos = [0,hgt/20];
    if p.axl==2
        xtixpos = -xtixpos;
    end
else
    Yaxlin = [ori(1),xL(2); ori(2),yL(2)]; % y axis scale
    xtixpos = hgt/40*[-1,1];
    if ~Ytix(1)
        Ytix = Ytix(2:end);
    end
end
if p.axl==2
    ylabpos = 'left';
else
    ylabpos = 'right';
end

%% Plot histogram (in units, plotting to axis object)

% Plot the unity line
t = plot(xL,yL,'k');
uistack(t, 'bottom');

% Plot the histogram x-axis 
t = plot(Xaxlin(:,1),Xaxlin(:,2),'k');
uistack(t, 'bottom');

% Plot histogram bars
for i = 1:ngrp
    dx = diff(px{i}(1:2))/2;
    for j = 1:numel(px{i})
        rxy = rot( (px{i}(j)+[-dx,dx,dx,-dx])/sqrt(2), [0,0,py{i}([j,j])/Ytix(end)*hgt], -pi/4)+ori;
        t = fill(rxy(:,1),rxy(:,2),'k','FaceColor',p.bfc(i,:),'FaceAlpha',p.bfa,'LineWidth',p.blw,'EdgeColor',p.blc,'LineStyle',p.bls);
        uistack(t, 'bottom');
    end
end

%% Plot histogram (normalized, plotting to figure object)

% Plot histogram y-axis line
plot(Yaxlin(1,:),Yaxlin(2,:),'k-','LineWidth',.001); % axis scale line

% Plot rotated y-axis ticks+labels
buf = zeros(3,1); % Determine the offset for the axis label
for i = 1:numel(Ytix)
    rxy = rot(xtixpos,Ytix([i,i])/Ytix(end)*hgt,-pi/4)+Yaxlin(:,1)';
    plot(rxy(:,1),rxy(:,2),'k-','LineWidth',.01);
    t = text(...
        rxy(1,1)-range(Xaxlin(:,1))*.01*sign(xtixpos(2)),...
        rxy(1,2)+range(Xaxlin(:,2))*.01*sign(xtixpos(2)),...
        num2str(Ytix(i)),'Rotation',315,'Color','k','FontSize',p.fsz,...
        'HorizontalAlignment',ylabpos,'VerticalAlignment','middle','Margin',1);
    % Compute the bounding box
    ex = [... 
        t.Extent(1)+[0,           0, t.Extent(3), t.Extent(3)];...
        t.Extent(2)+[0, t.Extent(4), t.Extent(4),           0];...
        ];
    % 3/4 the maximum distance from axis-line
    [W,w] = max(sum(abs(ex-rxy(1,:)')));
    if buf(3)<W
        buf = [ (ex(:,w)-rxy(1,:)')*.75; W];
    end
end

% Plot rotated y-axis label
switch p.axl
    case 1
        % I really need to include these in the resize function...
        text(mean(Yaxlin(1,:))+buf(1),mean(Yaxlin(2,:))+buf(2),...
            ylab,'Rotation',45,'Color','k','LineStyle','none','FontSize',p.fsz,...
            'HorizontalAlignment','center','VerticalAlignment','bottom'); % rotated axis label
    case 2
        text(mean(Yaxlin(1,:))+buf(1),mean(Yaxlin(2,:))+buf(2),...
            ylab,'Rotation',45,'Color','k','LineStyle','none','FontSize',p.fsz,...
            'HorizontalAlignment','center','VerticalAlignment','top'); % rotated axis label
end

% Plot rotated x-axis ticks+label
for i = 1:numel(Xtix) 
    rxy = rot(Xtix([i,i])/sqrt(2),[0,hgt/20],-pi/4)+ori(1);
    plot(rxy(:,1),rxy(:,2),'k-','LineWidth',.001);
    text(rxy(1,1),rxy(1,2),num2str(Xtix(i)),'LineStyle','none','Rotation',315,'Color','k',...
        'FontSize',p.fsz,'HorizontalAlignment','center','VerticalAlignment','top');
end

% Draw tangent lines for each data point
if p.tan
    for i = 1:size(d,2)
        for j = 1:size(d,1)
            plot( [x(j,i),xl(2)], [y(j,i),xl(2)+(y(j,i)-x(j,i))],'Color',p.mfc(i,:),'LineAlpha',.1);
        end
    end
end

% Dynamically adjust the aspect ratio to square-up the panel?
if p.eax
    adjAR(h,pos);
    set(gcf,'SizeChangedFcn',@(~,~)adjAR(h,pos));
end

%% Restore initial states
if ~ish
    hold off;
end
set(h,'Units',units);

%% Set return args
if nargout
    varargout{1} = h;
end


%% Utilities
function ar = computeAR(pos)
ar = get(gcf,'Position').*pos;
ar = ar(3)/ar(4);

function x = adjAR(h,POS)
% Ensure that units are set to normalized
set(h,'Units','normalized');
pos = get(h,'Position'); % Current size

% Make sure the size doesn't constantly decrease
if all(pos(3:4)<POS(3:4))
    pos(3:4) = POS(3:4);
end

% Which dimension to reduce?
ar = computeAR(pos);
if 1<ar
    p = fminsearch(@(p)abs(computeAR([pos(1:2),p,pos(4)])-1),pos(3));
    x = [pos(1:2),p,pos(4)];
else
    p = fminsearch(@(p)abs(computeAR([pos(1:3),p])-1),pos(4));
    x = [pos(1:3),p];
end
set(h,'Position',x);



