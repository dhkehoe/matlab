function [ah,lh,x] = barplot(y,e,varargin)
% Contruct bar graph with flexible, intuitive settings for data with
% N x M conditions. M conditions are plotted along x-axis. N conditions are
% specified in the legend and grouped together at each level of M. Returns
% axes and legend handles.
%
%   USAGE:
%
%   barplot(y)
%   barplot(y,e)
%   barplot(y,'OptionalArgName',OptionalArgValue,...)
%   barplot(y,e,'OptionalArgName',OptionalArgValue,...)
%
%   INPUT:
%
%          y - N x M matrix of values to be plotted with bars. Values along
%              the N dimension will be grouped together, while values along
%              the M dimension will be separated by conditions plotted
%              along the x-axis.
%
%   OPTIONAL INPUT:
%
%          e -  N x M matrix of errors associated with each corresponding
%               value of y
%    barwidth - Width of each individual bar. Must be between 0 and 1. Bar
%               width values of 1 specify that bars will touch within a
%               particular group. Bar width values less than 1 will not be
%               touching in their respective groups.
%     spacing - The amount of spacing in between each group of bars. NOTE:
%               a value of 0 indicates that groups will not be separated.
%               A value of 1 indicates that groups will be separated by the
%               width of one bar, assuming 'barwidth' is 1.
%        xpad - The amount of symetrical x-axis padding before and after
%               the first and last groups of bars. Must be between 0 and 1.
%               Corresponds to the proportion of 'spacing' to use as
%               padding.
%      constr - Cell array of strings to plot along the x-axis for each
%               group of bars. Correspond to values in the M dimension of
%               'y'.
%      grpstr - Cell array of strings to plot in legend indicating
%               conditional membership within each group. Correspond to
%               values in the N dimension of 'y'. Legend will not be
%               plotted if these are not specified.
%       color - N x 3 matrix of color values to assign to bars within each
%               group.
%   linewidth - Line width to use for plotting error bars.
%    whisklen - Error bar whisker length to use for plotting error bars.
%               Must be between 0 and 1. Corresponds to proportion of total
%               x-axis size (.01 is a reasonable choice.)
%
%   OUTPUT
%          ah - Current axes object handle.
%          lh - Current legend object handle.
%
%   DHK - June 5, 2020

% If 'e' is not passed in
if nargin < 2 % Only y is passed in
    e = nan;
elseif ischar(e) % A string is passed as second argument, so it is a property name
    varargin = [e varargin];
    e = nan;
elseif ~all(size(y)==size(e)) % 'e' is passed as second argument; check for consistent dimensions
    error('Dimension mismatch between ''y'' and ''e'''), % 'e' was passed as a
end

%% Manage Inputs

% Set up input parser
p = inputParser;
addOptional(p,'spacing',.5,@(x) isnumeric(x) && isscalar(x) && x >= 0 ); % Spacing between groups
addOptional(p,'barwidth',1,@(x) isscalar(x) && isnumeric(x) && x>=0 && x<=1); % Bar width (0 <= bar width <= 1)
addOptional(p,'color',[],@(x) isnumeric(x) && size(x,1)==size(y,1) && size(x,2)==3 ); % Color matrix (1st Dim = conditions, 2nd Dim = 1x3 color vector)
addOptional(p,'xpad',1,@(x) isnumeric(x) && isscalar(x) && x>=0 && x<=1); % Proportion of 'spacing' to pad around first/last group of bars
addOptional(p,'whisklen',nan,@(x) isscalar(x) && isnumeric(x) && x>=0 && x<=1); % Error bar whisker length
addOptional(p,'constr',[],@(x) all(iscell(x)) && length(x)==size(y,2)); % Condition labels (along x-axis)
addOptional(p,'grpstr',[],@(x) iscell(x) && length(x)==size(y,1)); % Group labels (legend)
addOptional(p,'linewidth',3,@(x) isnumeric(x) && isscalar(x) && x>=0); % Error bar line width
addOptional(p,'position',[],@(x) isnumeric(x) && numel(x)==4); % Legend position argument
addOptional(p,'location',[],@ischar); % Legend location argument
addOptional(p,'autoupdate','off',@ischar); % Legend autoupdate argument

parse(p,varargin{:}); % Parse input values
p = p.Results;

%% Set up
% Set x coordinates
offset = p.spacing:p.spacing:size(y,2)*p.spacing; % Set space between groups
x = repmat( size(y,1):size(y,1):size(y,2)*size(y,1) ,[size(y,1) 1])... % Group centers
    +repmat( (0:size(y,1)-1)' ,[1 size(y,2)])... % Add within group displacement
    +repmat(offset,[size(y,1) 1]); % Add between groups displacement

% If no colour is specified, just use maximally distant HSV hue values
if isempty(p.color)
    hvals = linspace(1,1/size(y,1),size(y,1));
    p.color = hsv2rgb([ hvals', repmat([.75,1], [size(y,1),1]) ]);
end

% Set the x limits
xl = [min(x(:))-p.spacing*p.xpad-p.barwidth/2, max(x(:))+p.spacing*p.xpad+p.barwidth/2];

% Plot handles for legend if necessary
if ~isempty(p.grpstr), h = 1:size(x,1); end

%% Plot

% Check if hold is on, then force it on
ih = ishold;
hold on;

for i =1:size(x,1)
    % Get plot handles for legend if necessary
    if ~isempty(p.grpstr), h(i) = bar(0,0,'FaceColor',p.color(i,:)); end
    for j = 1:size(x,2)
        % Draw bars
        if y(i,j)>0
            rectangle('Position',[x(i,j)-p.barwidth/2, 0, p.barwidth, y(i,j)],...
                'FaceColor',p.color(i,:),'LineStyle','none'); %[left, bottom, width, height]
        else
            rectangle('Position',[x(i,j)-p.barwidth/2, y(i,j), p.barwidth, abs(y(i,j))],...
                'FaceColor',p.color(i,:),'LineStyle','none'); %[left, bottom, width, height]
        end
        % Put lines around bars, except along x axis
        plot(x(i,j)+[-1,-1,1,1]*p.barwidth/2, [0,1,1,0]*y(i,j),'k-');

        % Plot error bars
        if isnan(e), continue, end
        plot( [x(i,j), x(i,j)], [y(i,j)-e(i,j), y(i,j)+e(i,j)],'-','Color','k','LineWidth',p.linewidth );
        % Plot error bar whiskers
        plot( [x(i,j)-p.whisklen, x(i,j)+p.whisklen], [y(i,j)-e(i,j), y(i,j)-e(i,j)],'-','Color','k','LineWidth',p.linewidth );
        plot( [x(i,j)-p.whisklen, x(i,j)+p.whisklen], [y(i,j)+e(i,j), y(i,j)+e(i,j)],'-','Color','k','LineWidth',p.linewidth );
    end
end

% Get locations for printing category labels
if ~isempty(p.constr)
    set(gca,'XTick',mean(x,1),'XTickLabel',p.constr);
else
    set(gca,'XTick',[]);
end

% Set x limits
xlim(xl);

% Set legend if necessary
if isempty(p.grpstr)
    lh = [];
else
    lh = legend(h,p.grpstr); % Return legend handle

    % Adjust position?
    if ~isempty(p.position)
        lh.Position = p.position;
    elseif ~isempty(p.location)
        lh.Location = p.location;
    end
    lh.AutoUpdate = p.autoupdate;
end

% Return the axes handle
ah = gca;

% Turn hold back off
if ~ih
    hold off;
end