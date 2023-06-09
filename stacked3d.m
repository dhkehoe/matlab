function [h,cb] = stacked3d(x,y,z,varargin)
%
%
% USAGE
%
%
% INPUT
%
%
% OPTIONAL INPUT
%
%
% OUTPUT
%
%
%
%   DHK

%% manage input
p = inputParser;
addOptional(p,'step',[],@(x)numel(x)==1&&isnumeric(x));
addOptional(p,'zoff',.1,@(x)numel(x)==1&&isnumeric(x));
addOptional(p,'null',[]);%,@(x)numel(x)==1&&isnumeric(x));
addOptional(p,'cmap',[]);
addOptional(p,'edgealpha',.1);
parse(p,varargin{:});
p = p.Results;

% set some defaults
if isempty(p.cmap), p.cmap = colormap; end
if isempty(p.null), p.null = ones(size(z));
else, p.null(p.null<0) = nan;
end

%% perform all necessary re-scaling
zmin = min(z(:)); % minimum in set of z
zran = range(z(:)); % range over set of z
% p.zoff = .1; % proportion of z-range to raise up the manifold off of the heatmap

% find ztick step size
if isempty(p.step)
    p.step = 1;
end

% get z ticks in the original units of z
ztix = ( ceil(zmin/p.step) : floor(max(z(:)/p.step)) )*p.step;

% create z labels
zlab = cell(size(ztix));
for i = 1:numel(zlab), zlab{i} = num2str(ztix(i)); end


%% create visible axis, draw heatmap/manifold

% Plot heatmap with z rescaled z to (-1,0)
imagesc( (z-zmin)/zran-1 ,'alphadata',p.null); hold on,

% Plot manifold with z rescaled z to (0,1) elevated up off of heatmap by range(z)*zoff.
surf( (x-x(1))/range(x(1,:))*size(x,2),... Rescale x and y to integer range (0,N) and
    (y-y(1))/range(y(:,1))*size(y,1),...   (0,M), so that they align with heatmap.
    (z-zmin)/zran+p.zoff,'edgealpha',p.edgealpha);

% Make a copy of handle for visible axis
h = gca;

% Adjust colormap
colormap(h,[p.cmap; ones(floor(size(p.cmap,1)*p.zoff),3); p.cmap]), % Dummy code (range(z)*zoff) into the colormap



% Set units on visible axis
set(h,'ztick',(ztix-zmin)/zran+p.zoff,'zticklabel',zlab);
grid on,

%% Create hidden axis, add regular color bar
newax = axes(gcf,'Position',get(h,'Position'),'NextPlot','Add','Color','None','Visible','off');
colormap(newax,p.cmap), % use original colormap

% add colorbar to invisible axis, return handle
cb = colorbar(newax,'fontsize',12);

% set units on visible colorbar
set(cb,'Ticks',(ztix-zmin)/zran,... rescale z ticks into (0,1) range
    'TickLabels',zlab ,...
    'Position',get(cb,'Position')+[.095 0 0 0]),

set(gcf, 'CurrentAxes', h);