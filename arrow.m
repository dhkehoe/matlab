function arrow(xy1,xy2,varargin)
% Plotting function for drawing an arrow that connects the points in xy1 to
% the points in xy2 using the axis units from the current axis. The arrow
% is customizable using the same optional arguments as with native MATLAB
% function annotation('arrow',...).
%
% NOTE: This function plots the arrows as annotation objects, which are
% drawn to the current figure object. Resizing of the currents axes or
% figure object AFTER THE ARROWS ARE DRAWN will likely alter their
% position. Any figure or axes resizing must be performed prior to calling
% this function.
%
%   EXAMPLES:
% subplot('Position',[.1 .1 .8 .4]),
% xlim([10 20]),
% set(gcf,'OuterPosition',[.1 .1 .8 .8]),
%
%   The above three calls to figure and axes size/position properties will
%   alter the arrow position. Be sure to draw the arrow AFTER any such
%   calls.
%
% -------------------------------------------------------------------------
% USAGE:
%   arrow(xy1,xy2),
%   arrow(xy1,xy2,'Property name',value,...),
%
% -------------------------------------------------------------------------
% INPUTS:
%   xy1 - 1x2 vector containing the (x,y) position of arrow start point
%         in the native units of the current axes object.
%   xy2 - 1x2 vector containing the (x,y) position of arrow end point
%         in the native units of the current axes object.
%
% OPTIONAL INPUT:
%   Optional inputs must be input in property name/property value pairs
%   (see USAGE).
%   
%        'color' - Specifies the arrow color. Can be a string accepted by
%                  most MATLAB plotting functions (e.g., 'k' for black) or
%                  a 1x3 RBG vector. The default color is black.
%    'linestyle' - Specifies the line style. Options are
%                      '-' Solid line (default)
%                     '--' Dashed line
%                      ':' Dotted line
%                     '-.' Alternating dashed/dotted line
%                   'none' No line will be draw
%    'linewidth' - Scalar which specifies the width of the line. The
%                  default is 1.
%    'headstyle' - String which specifies the style of the arrowhead. See
%                  MATLAB's 'Arrow Properties' documentation for
%                  illustrations. The options are
%                       'plain'
%                       'ellipse',
%                       'vback1'
%                       'vback2' (default)
%                       'vback3'
%                       'cback1'
%                       'cback2'
%                       'cback3'
%                       'fourstar'
%                       'rectangle'
%                       'diamond'
%                       'rose'
%                       'hypocycloid'
%                       'asteroid'
%                       'deltoid'
%                       'none'
%   'headlength' - Scalar which specifies the length of the arrowhead. The
%                  default is 10.
%    'headwidth' - Scalar which specifies the width of the arrowhead. The
%                  default is 10.
%
%   For more information about these properties, see MATLAB's documentation
%   for 'Arrow Properties'.
%
%
%
%   DHK - July 30th, 2021

%% Manage input
if nargin < 2
    error('not enough arguments'),
end

% Reshape/check length of input
xy1 = xy1(:);
xy2 = xy2(:);
if length(xy1) ~= 2
    error('incorrect number of start points'),
end
if length(xy2) ~= 2
    error('incorrect number of end points'),
end

% Parse any optional arguments passed in
p = inputParser;
addOptional(p,'color','k',@(x)(isnumeric(x)&&numel(x)==3)||(ischar(x)&&numel(x)==1)),
addOptional(p,'linestyle','-',@(x)ischar(x)&&...
    any(strcmp(x,{'-','--',':','-.','none'}))),
addOptional(p,'linewidth',1,@(x)isnumeric(x)&&numel(x)==1),
addOptional(p,'headstyle','vback2',@(x)ischar(x)&&...
    any(strcmp(x,{'plain','ellipse','vback1','vback2','vback3','cback1',...
    'cback2','cback3','fourstar','rectangle','diamond','rose','hypocycloid',...
    'asteroid','deltoid','none'}))),
addOptional(p,'headlength',10,@(x)isnumeric(x)&&numel(x)==1),
addOptional(p,'headwidth',10,@(x)isnumeric(x)&&numel(x)==1),
parse(p,varargin{:});
p = p.Results;

%% Draw arrow
% Get position of current axes object within parent figure object
set(gca,'Units','Normalized'),
pos = get(gca,'Position');
pos(3:4) = pos(3:4) + pos(1:2);

% Get extent of current axes object in native units
xl = xlim;
yl = ylim;

% Switch xy_i vectors to x and y vectors
xpts = [xy1(1) xy2(1)];
ypts = [xy1(2) xy2(2)];

% Translate the x and y locations of the arrow start/end points into the
% normalized position units used by the parent figure object
xpos = (xpts-xl(1))/(xl(2)-xl(1)).*(pos(3)-pos(1))+pos(1);
ypos = (ypts-yl(1))/(yl(2)-yl(1)).*(pos(4)-pos(2))+pos(2);

% Draw arrow/set properties using MATLAB's handy annotation() function.
annotation('arrow','X',xpos,'Y',ypos,'color',p.color,'linestyle',p.linestyle,...
    'linewidth',p.linewidth,'headstyle',p.headstyle,'headlength',p.headlength,...
    'headwidth',p.headwidth);