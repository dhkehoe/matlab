function varargout = arrow(x,y,varargin)
% Plotting function for drawing an arrow that connects the points in 
% (x1,y1) to (x2,y2). These points are passed in 'x' and 'y' pairs. The
% points are in the same units as data from the current axis. The arrow
% is customizable using the same optional arguments as with native MATLAB
% function annotation('arrow','X',x,'Y',y,...), with a couple of extra
% options (see INPUTS below).
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
%   x - 1x2 vector containing the (x1,x2) coordinates of the arrow start-/
%       endpoint in the same units as the data in the current axes object.
%   y - 1x2 vector containing the (y1,y2) coordinates of the arrow start-/
%       endpoint in the same units as the data in the current axes object.
%
% OPTIONAL INPUT:
%          fig - A figure handle specifying on which figure object to draw
%                the arrow.
%         axes - An axes handle specifying on which axes object to draw the
%                arrow.
%         type - A string specifying which Arrow subtype to draw. Possible
%                choices are:
%                   'Line'
%                   'Arrow' (default)
%                   'DoubleArrow'
%                   'TextArrow'
%
%   You can also specify any other properties that belong to Line-type
%   Annotation objects in MATLAB. Several common examples are detailed
%   here:
%
%        color - Specifies the arrow color. Can be a string accepted by
%                most MATLAB plotting functions (e.g., 'k' for black) or
%                a 1x3 RBG vector. The default color is black.
%    linestyle - Specifies the line style. Options are
%                    '-'  Solid line (default)
%                    '--' Dashed line
%                    ':'  Dotted line
%                    '-.' Alternating dashed/dotted line
%                    'none' No line will be draw
%    linewidth - Scalar which specifies the width of the line. The
%                  default is 1.
%    headstyle - String which specifies the style of the arrowhead. See
%                MATLAB's 'Arrow Properties' documentation for
%                illustrations. The options are
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
%   headlength - Scalar which specifies the length of the arrowhead. The
%                default is 10.
%    headwidth - Scalar which specifies the width of the arrowhead. The
%                default is 10.
%
%   For a complete list of these properties, see MATLAB's documentation for
%   'Arrow Properties'.
%
%
%
%   DHK - July 30th, 2021

%% Manage input
if ~( numel(x)==2 && numel(y)==2 && isnumeric(x) && isnumeric(y) )
    error('Arguments ''x'' and ''y'' must be numeric vectors with 2 elements.');
end

% Parse any optional arguments passed in
try
    typecheck = @(x) ischar(x) && any(strcmpi(x,{'arrow','line','doublearrow','textarrow'}));
    [varargin,  fig] = inputChecker(varargin,'fig',      gcf, @isfigure, 'Optional argument ''Fig'' must be a handle to a figure object.');
    [varargin,   ax] = inputChecker(varargin,'axes',     gca, @isaxes,   'Optional argument ''Axes'' must be a handle to an axes object.');
    [varargin, type] = inputChecker(varargin,'type', 'arrow', typecheck, 'Optional argument ''Type'' must be one of the following strings: ''arrow'', ''line'', ''doublearrow'', or ''textarrow''.');
catch err
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end

%% Draw arrow

% Get position of current axes object within parent figure object
x = ax2fig(x,'X',ax);
y = ax2fig(y,'Y',ax);

% Draw arrow/set properties using MATLAB's annotation() function
try
    h = annotation(fig,type,'X',x,'Y',y,varargin{:});
catch err
    % Throw any errors from within this function
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end

if nargout
    varargout{1} = h;
end