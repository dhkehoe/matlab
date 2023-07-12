function figpos = ax2fig(pts, com, han)
% This function takes points in arbitrary units along a particular axis for
% some axes object and converts them into normalized points to situate them
% in the parent figure object. This is ideal for precisely positioning
% annotation objects in a figure using the arbitrary units of some axis.
%
%
% USAGE
%   figpos = ax2fig(x,'x');
%   figpos = ax2fig(x,'x',han);
%
% INPUT
%   pts - Matrix of an dimensions. Specifies points along relevant axis in
%         arbitrary units. These locations are converted into *normalized*
%         units for the parent figure object and returned by the function.
%
%   com - Either 'x' or 'y' specifying whether the points in 'pts' are 
%         situated on the x or y axis (respectively).
%         E.g., get(gca,xlim)
%
% OPTIONAL INPUT
%   han - Axes handle on which the points in 'pts' are situated.
%               (default = gca)
%
% OUTPUT
%   figpos - Matrix of size(pts), which contains the points in 'pts'
%            normalized with respect to the parent figure object for either
%            the x or y component as specified by 'com'.
%
% EXAMPLE
%   % Method 2 (recommended):
%   plot(x,y);
%   annotation('type', 'X',ax2fig(x,'x'), 'Y',ax2fig(y,'y'));
%
% HISTORY
% (written)  Mar  2, 2017: Created basic computation.
% (modified) May 18, 2023: Simplified argument list for end-user. Backwards
%                          compatability broken.
% 
% 
% DHK - March 2, 2017

% Default to current axes
if nargin<3
   han = gca;
end

% Unitize position/get position of axes object in parent figure
set(han,'Units','Normalized'),
pos = get(han,'Position');

% For relevant component, adjust position/get axes limits in axes object units
if lower(com)=='x'
    axpos = [0,pos(3)]+pos(1);
    lim = xlim;
elseif lower(com)=='y'
    axpos = [0,pos(4)]+pos(2);
    lim = ylim;
else
    error('String arg ''com'' specifies whether to compute position of the x or y component. Valid inputs: ''x'' or ''y''');
end

% Compute figure position
figpos = (pts-lim(1))/(lim(2)-lim(1)).*(axpos(2)-axpos(1))+axpos(1);