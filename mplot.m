function varargout = mplot(Z,varargin)
%
%
%
%


%% Manage input
sz = size(Z);
if any(sz(1:2)==1) || numel(sz) > 2
    error('''Z'' must be an N by M matrix where N and M are of length greater than 1.');
end

p = inputParser;
% Marginal domains
addOptional(p,'x', []); %
addOptional(p,'y', []); %
% Axis size/padding/limits
addOptional(p,'size', [.8,.8]); % [width,height]
addOptional(p,'lpad', .10); %
addOptional(p,'rpad', .10); %
addOptional(p,'dpad', .10); %
addOptional(p,'upad', .10); %
addOptional(p,'apad', .01); %
addOptional(p,'xlim',[]); %
addOptional(p,'ylim',[]); %
addOptional(p,'zlim',nan(2)); %
% Plot object formats
addOptional(p,'imageformat',{}); %
addOptional(p,'colorbarformat',{}); %
addOptional(p,'lineformat',{}); %
% Miscellaneous behaviors
addOptional(p,'equalaxeslim',1); %
addOptional(p,'addcolorbar',1); %
% Axis ticks and labels
addOptional(p,'cblabel',''); %
addOptional(p,'zlabel',''); %
addOptional(p,'xlabel',''); %
addOptional(p,'ylabel',''); %
addOptional(p,'xtick',[]); %
addOptional(p,'ytick',[]); %
addOptional(p,'ztick',[]); %
addOptional(p,'xticklabels',''); %
addOptional(p,'yticklabels',''); %
addOptional(p,'zticklabels',''); %
addOptional(p,'fontsize',10);

% Parse
parse(p,varargin{:});
p = p.Results;

% Set default marginalized domains
if isempty(p.x)
    p.x = 1:size(Z,2);
end
if isempty(p.y)
    p.y = 1:size(Z,1);
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
if isempty(p.xlim)
    p.xlim = xlim;
else
    xlim(p.xlim);
end
if isempty(p.ylim)
    p.ylim = ylim;
else
    ylim(p.ylim);
end
% Set or get axis ticks
if isempty(p.xtick)
    [~,p.xtick] = axlim(rangei(p.x));%get(ax(1),'XTick');
end
if isempty(p.ytick)
    [~,p.ytick] = axlim(rangei(p.y));%p.ytick = get(ax(1),'YTick');
end
% Set or get axis tick labels
if isempty(p.xticklabels) && ischar(p.xticklabels)
    p.xticklabels = cellstr(num2str(p.xtick'));%get(ax(1),'XTickLabels');
end
if isempty(p.yticklabels) && ischar(p.yticklabels)
    p.yticklabels = cellstr(num2str(p.ytick'));%get(ax(1),'YTickLabels');
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

%% Make the marginal data axes equally scaled
if p.equalaxeslim
    [zl,ztick] = axlim(rangei([mean(Z,1),mean(Z,2)']));
    if all(isnan(p.zlim(:)))
        p.zlim = [zl;zl];
    end
    if all(isnan(p.ztick(:)))
        p.ztick = [ztick;ztick];
    end
else
    [zl,ztick] = axlim(rangei([mean(Z,1)]));
    if all(isnan(p.zlim(1,:)))
        p.zlim(1,:) = zl;
    end
    if all(isnan(p.ztick(1,:)))
        p.ztick(1,:) = ztick;
    end

    [zl,ztick] = axlim(rangei([mean(Z,2)]));
    if all(isnan(p.zlim(2,:)))
        p.zlim(2,:) = zl;
    end
    if all(isnan(p.ztick(2,:)))
        p.ztick(2,:) = ztick;
    end
end

%% Marginal X1
ax(2) = subplot('Position',xpos); hold on;
plot(p.x, mean(Z,1), p.lineformat{:});
xlabel(p.xlabel);
ylabel(p.zlabel);
xlim(p.xlim);
ylim(p.zlim);
set(ax(2),'XTick',p.xtick,'XTickLabels',p.xticklabels,'YTick',p.ztick,'FontSize',p.fontsize);

%% Marginal X2
ax(3) = subplot('Position',ypos); hold on;
plot(mean(Z,2), p.y, p.lineformat{:});
xlabel(p.zlabel);
ylabel(p.ylabel);
xlim(p.zlim);
ylim(p.ylim);
set(ax(3),'XAxisLocation','top','XTick',p.ztick,'YTick',p.ytick,'YTickLabels',p.yticklabels,'FontSize',p.fontsize);

%% Return handles
if nargout
    varargout = {ax,fig};
end

%% Automatically resize marginalized X1 subpanel
function resizefunc(fig,p)
c = get(fig,'Children');
if ~isempty(c) && p.addcolorbar
    xpos = [c(4).Position(1), p.dpad, c(4).Position(3), 1-p.size(2)-p.apad];
    set(c(2),'Position',xpos);
end