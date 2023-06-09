function setAxes(varargin)
%% manage input
p = inputParser;
% Axes object properties
addOptional(p,'handle',gca,@(x)all(ishandle(x)));
addOptional(p,'color',[0,0,0],@(x)all(isnumeric(x))&&numel(x)==3);
addOptional(p,'fontsize',12,@(x)isscalar(x)&&isnumeric(x));
addOptional(p,'format',[],@ischar); % not implemented
addOptional(p,'linewidth',1e-6,@(x)isscalar(x)&&isnumeric(x));
addOptional(p,'ticklength',.01,@(x)isscalar(x)&&isnumeric(x));
addOptional(p,'interpreter',[],@ischar);
% X axis properties
addOptional(p,'xaxisline',[],@(x)all(isnumeric(x))&&numel(x)==2&&x(1)<=x(2));
addOptional(p,'xaxislocation','bottom',@(x)any(strcmp(x,{'bottom','top','origin'})));
addOptional(p,'xlabel',[],@ischar);
addOptional(p,'xlim',[],@(x) all(isnumeric(x))&&numel(x)==2&&x(1)<=x(2));
addOptional(p,'xticklabel',[],@(x)iscell(x)||isempty(x));
addOptional(p,'xtick',[],@(x)all(isnumeric(x))&&issorted(x));
addOptional(p,'xinterpreter','tex',@ischar);
% Y axis properties
addOptional(p,'yaxisline',[],@(x)all(isnumeric(x))&&numel(x)==2&&x(1)<=x(2));
addOptional(p,'yaxislocation','left',@(x)any(strcmp(x,{'left','right','origin'})));
addOptional(p,'ylabel',[],@ischar);
addOptional(p,'ylim',[],@(x) all(isnumeric(x))&&numel(x)==2&&x(1)<=x(2));
addOptional(p,'yticklabel',[],@(x)iscell(x)||isempty(x));
addOptional(p,'ytick',[],@(x)all(isnumeric(x))&&issorted(x));
addOptional(p,'yinterpreter','tex',@ischar);

parse(p,varargin{:}); 
d = p.UsingDefaults;
p = p.Results;

%% Set defaults
% Ticks
if any(strcmp(d,'xtick')) % Using the default (not the same as user passing an empty set)
    p.xtick = get(gca,'XTick'); % piggy-back off of MATLAB here
%     if ~isempty(p.xaxisline), p.xtick = p.xtick( p.xaxisline(1) <= p.xtick & p.xtick <= p.xaxisline(2) ); end
end
if any(strcmp(d,'ytick')) % Using the default (not the same as user passing an empty set)
    p.ytick = get(gca,'YTick');
%     if ~isempty(p.yaxisline), p.ytick = p.ytick( p.yaxisline(1) <= p.ytick & p.ytick <= p.yaxisline(2) ); end
end

% Tick labels
if any(strcmp(d,'xticklabel')) % Using the default (not the same as user passing an empty set)
    p.xticklabel = cellstr(num2str(p.xtick(:))); % use tick values as tick labels
    p.xticklabel = cellfun(@(t)strrep(t,' ',''),p.xticklabel,'UniformOutput',false); % trim white space out of labels
end
if any(strcmp(d,'yticklabel'))
    p.yticklabel = cellstr(num2str(p.ytick(:)));
    p.yticklabel = cellfun(@(t)strrep(t,' ',''),p.yticklabel,'UniformOutput',false);
end
% add these features
% p.xticklabel = cellfun(@(t)strrep(t,'0.','.'),p.xticklabel,'UniformOutput',false);
% p.yticklabel = cellfun(@(t)strrep(t,'0.','.'),p.yticklabel,'UniformOutput',false);

% Axis limits
if isempty(p.xlim), p.xlim = get(p.handle,'XLim'); end
if isempty(p.ylim), p.ylim = get(p.handle,'YLim'); end

% Interpreter
if ~isempty(p.interpreter), p.xinterpreter = p.interpreter; p.yinterpreter = p.interpreter; end

% format
% if 1/10^3 < p.lim(1) || p.lim(2) > 10^3
%     p.format = '%e';
% else, p.format = '%d';
% end    

%% Compute import info for drawing

% Get figure dimensions
units = get(gcf,'Units');
set(gcf,'Units','Normalized'); % Convert to inches
rect = get(gcf,'OuterPosition');
set(gcf,'Units',units);

% Get screen size in pixels
set(0,'Units','Pixels'); % Set root object to pixel units
ss = get(0,'ScreenSize'); % Get screen size

% Size of X axis line
if isempty(p.xtick)
    xAxisLine = p.xlim;
    if strcmp(p.yaxislocation,'left')
        yPos = p.xlim(1);
    elseif strcmp(p.yaxislocation,'right')
        yPos = p.xlim(2);
    elseif strcmp(p.yaxislocation,'origin')
        yPos = 0;
    end
elseif numel(p.xtick) == 1
    if strcmp(p.yaxislocation,'left')
        yPos = p.xtick; 
        xAxisLine = [p.xtick p.xlim(2)];
    elseif strcmp(p.yaxislocation,'right')
        yPos = p.xtick; 
        xAxisLine = [p.xlim(1) p.xtick ];
    elseif strcmp(p.yaxislocation,'origin')
        xAxisLine = [min([0,p.xtick]) max([0,p.xtick])];
    end
else
    xAxisLine = [min(p.xtick) max(p.xtick)];
    if strcmp(p.yaxislocation,'left')
        yPos = p.xlim(1);%xAxisLine(1);
    elseif strcmp(p.yaxislocation,'right')
        yPos = p.xlim(2);%xAxisLine(end);
    elseif strcmp(p.yaxislocation,'origin')
        yPos = 0;
    end
end

% Size of Y axis line
if isempty(p.ytick)
    yAxisLine = p.ylim;
    if strcmp(p.xaxislocation,'bottom')
        xPos = p.ylim(1);
    elseif strcmp(p.xaxislocation,'top')
        xPos = p.ylim(2);
    elseif strcmp(p.xaxislocation,'origin')
        xPos = 0;
    end
elseif numel(p.ytick) == 1
    if strcmp(p.xaxislocation,'bottom')
        xPos = p.ytick; 
        yAxisLine = [p.ytick p.ylim(2)];
    elseif strcmp(p.xaxislocation,'top')
        xPos = p.ytick; 
        yAxisLine = [p.ylim(1) p.ytick ];
    elseif strcmp(p.xaxislocation,'origin')
        yAxisLine = [min([0,p.ytick]) max([0,p.ytick])];
    end
else
    yAxisLine = [min(p.ytick) max(p.ytick)];
    if strcmp(p.xaxislocation,'bottom')
        xPos = p.ylim(1);%yAxisLine(1);
    elseif strcmp(p.xaxislocation,'top')
        xPos = p.ylim(2);%yAxisLine(end);
    elseif strcmp(p.xaxislocation,'origin')
        xPos = 0;
    end
end

% Override axis lines
if ~isempty(p.xaxisline), xAxisLine = p.xaxisline; end
if ~isempty(p.yaxisline), yAxisLine = p.yaxisline; end
    
% Axes object position
units = get(p.handle,'units');
set(p.handle,'units','normalized');
axpos = get(p.handle,'Position');

% Ensure ticks are the same length on screen for both axes
xtickLength = p.ticklength*(  range(xAxisLine)/range(p.xlim))*axpos(3)*rect(3)*ss(3); %   Total pixels of y ticks
xtickLength =  xtickLength/( (range(yAxisLine)/range(p.ylim))*axpos(4)*rect(4)*ss(4) ); % Total pixels of x ticks 
xtickLength = xtickLength * range(yAxisLine);

%% Turn off existing axes
set(get(p.handle,'XAxis'),'Visible','off');
set(get(p.handle,'YAxis'),'Visible','off');

%% Ensure we don't disrupt the plot
set(p.handle,'XLim',p.xlim);
set(p.handle,'YLim',p.ylim);
holdStatus = ishold(p.handle);
hold(p.handle,'on');

%% Drawing routines for x axis
    
% Axis line
plot(xAxisLine,[0,0]+xPos,'color',p.color,'linewidth',p.linewidth);

% Keep track of the height of tick labels
maxLabelHeight = yAxisLine(1);

% Ticks and tick labels
for i = 1:numel(p.xtick)
    % Draw ticks
    if strcmp(p.xaxislocation,'bottom')
        plot([0,0]+p.xtick(i),[xPos,xPos+xtickLength],... ensure the same length ticks on both axes
            'color',p.color,'linewidth',p.linewidth);
    elseif strcmp(p.xaxislocation,'top')
        plot([0,0]+p.xtick(i),[xPos,xPos-range(p.ylim)*p.ticklength*axpos(3)/axpos(4)],... ensure the same length ticks on both axes
            'color',p.color,'linewidth',p.linewidth);
    elseif strcmp(p.xaxislocation,'origin')
        plot([0,0]+p.xtick(i),[0,0]+xPos+xtickLength/2*[-1,1],... ensure the same length ticks on both axes
            'color',p.color,'linewidth',p.linewidth);
    end
    % Draw labels
    if ~isempty(p.xticklabel)
        if any(strcmp(p.xaxislocation,{'bottom','origin'}))
            h = text(p.xtick(i),xPos-range(p.ylim)*p.ticklength,p.xticklabel{i},...
                'fontsize',p.fontsize,'Interpreter',p.xinterpreter,...
                'horizontalalignment','center','verticalalignment','top');
        elseif strcmp(p.xaxislocation,'top')
            h = text(p.xtick(i),xPos+range(p.ylim)*p.ticklength,p.xticklabel{i},...
                'fontsize',p.fontsize,'Interpreter',p.xinterpreter,...
                'horizontalalignment','center','verticalalignment','bottom');
        end
        % Update the maximum height of x tick labels
        if h.Extent(2) < maxLabelHeight
        	maxLabelHeight = h.Extent(2);
        end
    end
end

% Axis label
if ~isempty(p.xlabel)
    text(mean(xAxisLine),maxLabelHeight,...
        p.xlabel,'Rotation',0,'Interpreter',p.xinterpreter,...
        'HorizontalAlignment','Center', 'VerticalAlignment','Top',...
        'FontSize',p.fontsize,'LineStyle','none');
end

%% Drawing routines for y axis

% Axis line
plot([0,0]+yPos,yAxisLine,'Color',p.color,'LineWidth',p.linewidth);

% Keep track of the width of tick labels
maxLabelWidth = xAxisLine(1);

% Ticks/labels
for i = 1:numel(p.ytick)
    % Draw ticks
    if strcmp(p.yaxislocation,'left')
        plot([yPos,yPos+range(xAxisLine)*p.ticklength],[0,0]+p.ytick(i),...
            'Color',p.color,'LineWidth',p.linewidth);
    elseif strcmp(p.yaxislocation,'right')
        plot([yPos,yPos-range(xAxisLine)*p.ticklength],[0,0]+p.ytick(i),...
            'Color',p.color,'LineWidth',p.linewidth);
    elseif strcmp(p.yaxislocation,'origin')
        plot([0,0]+(yPos+range(xAxisLine)*p.ticklength)/2*[-1,1],[0,0]+p.ytick(i),...
            'Color',p.color,'LineWidth',p.linewidth);
    end
    % Draw labels
    if ~isempty(p.yticklabel)
        if any(strcmp(p.yaxislocation,{'left','origin'}))
            h = text(yPos-range(p.xlim)*p.ticklength,p.ytick(i),p.yticklabel{i},...
                'FontSize',p.fontsize,'Interpreter',p.yinterpreter,...
                'HorizontalAlignment','Right','VerticalAlignment','Middle');
        elseif any(strcmp(p.yaxislocation,'right'))
            h = text(yPos+range(p.xlim)*p.ticklength,p.ytick(i),p.yticklabel{i},...
                'FontSize',p.fontsize,'Interpreter',p.yinterpreter,...
                'HorizontalAlignment','Left','VerticalAlignment','Middle');
        end
        % Update the maximum width of y tick labels
        if h.Extent(1) < maxLabelWidth
            maxLabelWidth = h.Extent(1);
            if p.ytick(i) < 0 % If there is a leading negative sign, text() adds way too much extra padding
                maxLabelWidth = maxLabelWidth+range(xAxisLine).*.01;
            end
        end
    end
end
% Draw axis label
if ~isempty(p.ylabel)
    text(maxLabelWidth-range(xAxisLine)*.005,mean(yAxisLine),...
        p.ylabel,'Rotation',90,...
        'HorizontalAlignment','Center', 'VerticalAlignment','Bottom',...
        'FontSize',p.fontsize,'LineStyle','none','Interpreter',p.yinterpreter);
end

%% Finish
set(p.handle,'units',units);
if ~holdStatus, hold(p.handle,'off'); end

% Axes object properties:
%
%                         ALim: [0 1]
%                     ALimMode: 'auto'
%                   AlphaScale: 'linear'
%                     Alphamap: [1×64 double]
%            AmbientLightColor: [1 1 1]
%                 BeingDeleted: off
%                          Box: on
%                     BoxStyle: 'back'
%                   BusyAction: 'queue'
%                ButtonDownFcn: ''
%                         CLim: [0 1]
%                     CLimMode: 'auto'
%               CameraPosition: [0 0 17.3205]
%           CameraPositionMode: 'auto'
%                 CameraTarget: [0 0 0]
%             CameraTargetMode: 'auto'
%               CameraUpVector: [0 1 0]
%           CameraUpVectorMode: 'auto'
%              CameraViewAngle: 6.6086
%          CameraViewAngleMode: 'auto'
%                     Children: [1×1 Line]
%                     Clipping: on
%                ClippingStyle: '3dbox'
%                        Color: [1 1 1]
%                   ColorOrder: [7×3 double]
%              ColorOrderIndex: 2
%                   ColorScale: 'linear'
%                     Colormap: [256×3 double]
%                  ContextMenu: [0×0 GraphicsPlaceholder]
%                    CreateFcn: ''
%                 CurrentPoint: [2×3 double]
%              DataAspectRatio: [1 1 1]
%          DataAspectRatioMode: 'auto'
%                    DeleteFcn: ''
%                    FontAngle: 'normal'
%                     FontName: 'Helvetica'
%                     FontSize: 10
%                 FontSizeMode: 'auto'
%                FontSmoothing: on
%                    FontUnits: 'points'
%                   FontWeight: 'normal'
%                    GridAlpha: 0.1500
%                GridAlphaMode: 'auto'
%                    GridColor: [0.1500 0.1500 0.1500]
%                GridColorMode: 'auto'
%                GridLineStyle: '-'
%             HandleVisibility: 'on'
%                      HitTest: on
%                InnerPosition: [0.1300 0.1100 0.7750 0.8150]
%                 Interactions: [1×1 matlab.graphics.interaction.interface.DefaultAxesInteractionSet]
%                Interruptible: on
%      LabelFontSizeMultiplier: 1.1000
%                        Layer: 'bottom'
%                       Layout: [0×0 matlab.ui.layout.LayoutOptions]
%                       Legend: [0×0 GraphicsPlaceholder]
%               LineStyleOrder: '-'
%          LineStyleOrderIndex: 1
%                    LineWidth: 0.5000
%               MinorGridAlpha: 0.2500
%           MinorGridAlphaMode: 'auto'
%               MinorGridColor: [0.1000 0.1000 0.1000]
%           MinorGridColorMode: 'auto'
%           MinorGridLineStyle: ':'
%                     NextPlot: 'replace'
%              NextSeriesIndex: 2
%                OuterPosition: [0 0 1 1]
%                       Parent: [1×1 Figure]
%                PickableParts: 'visible'
%           PlotBoxAspectRatio: [1 0.7903 0.7903]
%       PlotBoxAspectRatioMode: 'auto'
%                     Position: [0.1300 0.1100 0.7750 0.8150]
%           PositionConstraint: 'outerposition'
%                   Projection: 'orthographic'
%                     Selected: off
%           SelectionHighlight: on
%                   SortMethod: 'childorder'
%                     Subtitle: [1×1 Text]
%           SubtitleFontWeight: 'normal'
%                          Tag: ''
%                      TickDir: 'in'
%                  TickDirMode: 'auto'
%         TickLabelInterpreter: 'tex'
%                   TickLength: [0.0100 0.0250]
%                   TightInset: [0.0506 0.0532 0.0170 0.0202]
%                        Title: [1×1 Text]
%      TitleFontSizeMultiplier: 1.1000
%              TitleFontWeight: 'bold'
%     TitleHorizontalAlignment: 'center'
%                      Toolbar: [1×1 AxesToolbar]
%                         Type: 'axes'
%                        Units: 'normalized'
%                     UserData: []
%                         View: [0 90]
%                      Visible: on
%                        XAxis: [1×1 NumericRuler]
%                XAxisLocation: 'bottom'
%                       XColor: [0.1500 0.1500 0.1500]
%                   XColorMode: 'auto'
%                         XDir: 'normal'
%                        XGrid: off
%                       XLabel: [1×1 Text]
%                         XLim: [-1 1]
%                     XLimMode: 'auto'
%                 XLimitMethod: 'tickaligned'
%                   XMinorGrid: off
%                   XMinorTick: off
%                       XScale: 'linear'
%                        XTick: [-1 -0.8000 -0.6000 -0.4000 -0.2000 0 0.2000 0.4000 0.6000 0.8000 1]
%                   XTickLabel: {11×1 cell}
%               XTickLabelMode: 'auto'
%           XTickLabelRotation: 0
%                    XTickMode: 'auto'
%                        YAxis: [1×1 NumericRuler]
%                YAxisLocation: 'left'
%                       YColor: [0.1500 0.1500 0.1500]
%                   YColorMode: 'auto'
%                         YDir: 'normal'
%                        YGrid: off
%                       YLabel: [1×1 Text]
%                         YLim: [-1 1]
%                     YLimMode: 'auto'
%                 YLimitMethod: 'tickaligned'
%                   YMinorGrid: off
%                   YMinorTick: off
%                       YScale: 'linear'
%                        YTick: [-1 -0.8000 -0.6000 -0.4000 -0.2000 0 0.2000 0.4000 0.6000 0.8000 1]
%                   YTickLabel: {11×1 cell}
%               YTickLabelMode: 'auto'
%           YTickLabelRotation: 0
%                    YTickMode: 'auto'
%                        ZAxis: [1×1 NumericRuler]
%                       ZColor: [0.1500 0.1500 0.1500]
%                   ZColorMode: 'auto'
%                         ZDir: 'normal'
%                        ZGrid: off
%                       ZLabel: [1×1 Text]
%                         ZLim: [-1 1]
%                     ZLimMode: 'auto'
%                 ZLimitMethod: 'tickaligned'
%                   ZMinorGrid: off
%                   ZMinorTick: off
%                       ZScale: 'linear'
%                        ZTick: [-1 0 1]
%                   ZTickLabel: ''
%               ZTickLabelMode: 'auto'
%           ZTickLabelRotation: 0
%                    ZTickMode: 'auto'