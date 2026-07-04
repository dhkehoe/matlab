function varargout = mplot(Z,varargin)
% Needs documenting...
%
%
%   DHK - June 12, 2024


%% Manage input

p = inputParser;
% Marginal domains
addOptional(p,'x', []); %
addOptional(p,'y', []); %
addOptional(p,'mfun', @nanmean); %#ok
% Axis size/padding/limits
addOptional(p,'size', [.8,.8]); % [width,height]
addOptional(p,'lpad', .10); %
addOptional(p,'rpad', .10); %
addOptional(p,'dpad', .10); %
addOptional(p,'upad', .10); %
addOptional(p,'apad', .01); %
addOptional(p,'xlim',[]); %
addOptional(p,'ylim',[]); %
addOptional(p,'zlim',{}); %
% Plot object formats
addOptional(p,'imageformat',{}); %
addOptional(p,'colorbarformat',{}); %
addOptional(p,'lineformat',{}); %
% Miscellaneous behaviors
addOptional(p,'equalaxeslim',[]); %
addOptional(p,'addcolorbar',1); %
% Axis ticks and labels
addOptional(p,'cblabel',''); %
addOptional(p,'zlabel',''); %
addOptional(p,'xlabel',''); %
addOptional(p,'ylabel',''); %
addOptional(p,'xtick',[]); %
addOptional(p,'ytick',[]); %
addOptional(p,'ztick',{}); %
addOptional(p,'xticklabels',''); %
addOptional(p,'yticklabels',''); %
addOptional(p,'zticklabels',''); %
addOptional(p,'fontsize',10);

% Parse
parse(p,varargin{:});
p = p.Results;

% Check whether a reasonable marginalizing function was provided and set
% standard error function accordingly
pdfflag = strcmp(char(p.mfun),'pdf');
if pdfflag
    if isempty(p.equalaxeslim)
        p.equalaxeslim = false;
    end
elseif contains(char(p.mfun),'mean')
    p.efun = @nanste;
elseif contains(char(p.mfun),'sum')
    p.efun = @(x) nanstd(x) .* sqrt(sum(~isnan(x))); %#ok
else
    error('Use of ''%s'' as a marginalizing function is not supported.',char(p.mfun));
end

% Set default EqualAxesLim
if isempty(p.equalaxeslim)
    p.equalaxeslim = true;
end

%% Adjustments for data over repeated observations
sz = size(Z);

% Allow this for plotting errorbars on the marginals
if numel(sz)==3
    if pdfflag
        error('Repeated observations feature (''Z'' is a 3D matrix ) not supported when using joint PDF feature (argument ''mfun'' is the string ''pdf'').');
    end
    sjData = Z;
    Z = p.mfun(Z,3);
    sz = size(Z);
else
    sjData = [];
end

% Now ensure that we just have a square matrix
if any(sz(1:2)==1) || numel(sz) > 2
    error('''Z'' must be an N by M matrix where N and M are of length greater than 1.');
end

%%
% Set default marginalized domains
x = 1:size(Z,2); % pixel units
y = 1:size(Z,1); % pixel units
if isempty(p.x)
    p.x = x;  % data units
elseif numel(size(p.x))==2
    if all(equal(p.x,1))
        p.x = p.x(1,:);  % support for output from kde2()
    end
end
if isempty(p.y)
    p.y = y;
elseif numel(size(p.y))==2
    if all(equal(p.y,2))
        p.y = p.y(:,1);
    end
end

% Set default plot object properties
if isempty(p.imageformat)
    p.imageformat = ['CData',Z, p.imageformat];
end
if isempty(p.colorbarformat)
    p.colorbarformat = ['Tag','Colorbar', p.colorbarformat];
end
if isempty(p.lineformat)
    p.lineformat = {'-'};
end
if ~isempty(p.cblabel)
    p.addcolorbar = 1;
end

% Initialize axis handles
ax = 1:3;


%% Plot 2D image
fig = figure('SizeChangedFcn',@(scr,evn)resizefunc(scr,p));
pos = [1-p.size(1)+p.lpad, 1-p.size(2)+p.dpad, p.size(1)-p.rpad-p.lpad, p.size(2)-p.upad-p.dpad];
ax(1) = subplot('Position',pos); hold on;
imagesc(Z, p.imageformat{:});
box off;
drawnow;

% Set or get axis limits
xl = rangei(x);
yl = rangei(y);
setXLims(xl,p);
setYLims(yl,p);
p.xl = rangei(p.x(:));
p.yl = rangei(p.y(:));

% Set or get axis ticks
if isempty(p.xtick)
    [~,p.xtick] = Axlim(p.x,pdfflag);
    % while p.xtick(1)<p.xl(1), p.xtick(1) = []; end
    % while p.xl(2)<p.xtick(end), p.xtick(end) = []; end
end
if isempty(p.ytick)
    [~,p.ytick] = Axlim(p.y,pdfflag);
    % while p.ytick(1)<p.yl(1), p.ytick(1) = []; end
    % while p.yl(2)<p.ytick(end), p.ytick(end) = []; end
end
% Set or get axis tick labels
if isempty(p.xticklabels) && ischar(p.xticklabels)
    p.xticklabels = cellstr(num2str(p.xtick'));
end
if isempty(p.yticklabels) && ischar(p.yticklabels)
    p.yticklabels = cellstr(num2str(p.ytick'));
end

% Add colorbar
if p.addcolorbar
    cb = colorbar(p.colorbarformat{:});
    drawnow;
    pos = get(ax(1),'Position');
    if ~isempty(p.cblabel)
        cb.Label.String = p.cblabel;
    end
    set(cb,'FontSize',p.fontsize);
end

% Format
set(ax(1),'YDir','normal','XTick',[],'YTick',[],'ZTickLabel',[]);

xpos = [  pos(1), p.dpad,             pos(3), 1-p.size(2)-p.apad];
ypos = [  p.lpad, pos(2), 1-p.size(1)-p.apad,             pos(4)];

%% Determine the marginal data axes

% In case values were provided
if isnumeric(p.zlim)
    p.zlim = {p.zlim};
end
if isnumeric(p.ztick)
    p.ztick = {p.ztick};
end
if isscalar(p.zlim)
    p.zlim = repmat(p.zlim,2,1);
end
if isscalar(p.ztick)
    p.ztick = repmat(p.ztick,2,1);
end

% Otherwise, set defaults
if p.equalaxeslim
    if isempty(sjData)
        if pdfflag
            [zl,ztick] = Axlim([sum(Z,1)*range(p.yl)*diff(y(1:2))/range(y), sum(Z,2)'*range(p.xl)*diff(x(1:2))/range(x)],pdfflag);
        else
            [zl,ztick] = Axlim([p.mfun(Z,1),p.mfun(Z,2)'],pdfflag);
        end
    else
        t = [squeeze(p.mfun(sjData,1)); squeeze(p.mfun(sjData,2))]';
        [zl,ztick] = Axlim(p.mfun(t)+[-1;1].*p.efun(t),pdfflag);
        clear t;
    end
    if isempty(p.zlim)
        p.zlim = {zl;zl};
    end
    if isempty(p.ztick)
        p.ztick = {ztick;ztick};
    end
else
    if isempty(p.zlim)
        p.zlim = cell(2,1);
    end
    if isempty(p.ztick)
        p.ztick = cell(2,1);
    end

    if pdfflag
        [zl,ztick] = Axlim(sum(Z,1)*range(p.yl)*diff(y(1:2))/range(y),pdfflag);
    else
        [zl,ztick] = Axlim(p.mfun(Z,1),pdfflag);
    end
    if isempty(p.zlim{1})
        p.zlim{1} = zl;
    end
    if isempty(p.ztick{1})
        p.ztick{1} = ztick;
    end

    if pdfflag
        [zl,ztick] = Axlim(sum(Z,2)*range(p.xl)*diff(x(1:2))/range(x),pdfflag);
    else
        [zl,ztick] = Axlim([p.mfun(Z,2)],pdfflag);
    end
    if isempty(p.zlim{2})
        p.zlim{2} = zl;
    end
    if isempty(p.ztick{2})
        p.ztick{2} = ztick;
    end
end
if 2<numel(p.zlim) || 2<numel(p.ztick)
    error('Number of cells in arguments ''zlim'' and ''ztick'' must be <=2.');
end

%% Marginal X1
ax(2) = subplot('Position',xpos); hold on;
if isempty(sjData)
    if pdfflag
        plot(x, sum(Z,1)*range(p.yl)*diff(y(1:2))/range(y), p.lineformat{:});
    else
        plot(x, p.mfun(Z,1), p.lineformat{:});
    end
else
    fy = squeeze(p.mfun(sjData,1))';
    shadedline(x, p.mfun(fy),p.efun(fy), p.lineformat{:});
end
xlabel(p.xlabel);
ylabel(p.zlabel);
setXLims(xl,p);
ylim(p.zlim{1});
xtix = (p.xtick-p.xl(1)) ./ range(p.xl) * range(x) + x(1);
set(ax(2),'XTick',xtix,'XTickLabels',p.xticklabels,'YTick',p.ztick{1},'FontSize',p.fontsize);

%% Marginal X2
ax(3) = subplot('Position',ypos); hold on;
if isempty(sjData)
    if pdfflag
        plot(sum(Z,2)*range(p.xl)*diff(x(1:2))/range(x), y, p.lineformat{:});
    else
        plot(p.mfun(Z,2), y, p.lineformat{:});
    end
else
    % Marginalize over X1
    fy = squeeze(p.mfun(sjData,2))';
    
    % Plot mean
    ph = plot(p.mfun(fy), y, p.lineformat{:});

    % Compute M +/- SE
    sem = p.mfun(fy) + [-1;1].*p.efun(fy);

    % Draw shaded error bars
    fill([sem(1,:),fliplr(sem(2,:))], [y,fliplr(y)], 'k', 'FaceColor',ph.Color,'FaceAlpha',.1,'LineStyle','none');
end
xlabel(p.zlabel);
ylabel(p.ylabel);
xlim(p.zlim{2});
setYLims(yl,p);
ytix = (p.ytick-p.yl(1)) ./ range(p.yl) * range(y) + y(1);
set(ax(3),'XAxisLocation','top','XTick',p.ztick{2},'YTick',ytix,'YTickLabels',p.yticklabels,'FontSize',p.fontsize);

%% Return handles
if nargout
    varargout = {ax,fig};
end
% Make sure the axes are properly aligned before exiting
drawnow; resizefunc(gcf,p);

%% Automatically resize marginalized X1 subpanel
function resizefunc(fig,p)
c = get(fig,'Children');
if ~isempty(c) && p.addcolorbar
    xpos = [c(4).Position(1), p.dpad, c(4).Position(3), 1-p.size(2)-p.apad];
    set(c(2),'Position',xpos);
end

%% Dynamically set the axis limits
function setXLims(xl,p)
if isempty(p.xlim)
    xlim(xl);
elseif ~isempty(p.x) % 'xlim' should be in units
    xlim( (p.xlim-min(p.x))./range(p.x) * range(xl)+xl(1) );
end

%
function setYLims(yl,p)
if isempty(p.ylim)
    ylim(yl);
elseif ~isempty(p.y) % 'ylim' should be in units
    ylim( (p.ylim-min(p.y))./range(p.y) * range(yl)+yl(1) );
end

%% Adjust the axlim function
function [lim,tix] = Axlim(data,pdfflag)
r = rangei(data(:));
[lim,tix] = axlim(r);
if pdfflag
    lim(1) = 0;
end
% Ensure the ticks don't extend beyond the limits
while tix(1)<lim(1)
    tix(1) = [];
end
while lim(2)<tix(end)
    tix(end) = [];
end
% Ensure the full range of the data is captured within the ticks
while r(1)<tix(1)
    tix = [tix(1)-diff(tix(1:2)),tix];%#ok
    lim(1) = tix(1);
end
while tix(end)<r(2)
    tix = [tix,tix(end)+diff(tix(1:2))];%#ok
    lim(2) = tix(end);
end