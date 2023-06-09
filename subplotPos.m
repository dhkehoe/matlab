function pos = subplotPos(nr,nc,lpad,rpad,dpad,upad,adj)
% This function computes position vectors [left, bottom, width, height] in
% normalized units to position subplots within a parent figure object. An
% Nx4 matrix is returned in which the i_th row corresponds to the position
% vector for i_th subplot, N = (number of rows) x (number of columns), and
% the subplot rows and columns are linearized.
%
% INPUT
%     nr - Number of subplot rows.
%
%     nc - Number of subplot columns.
%
%   lpad - Magnitude of leftward padding (empty space) to the left of each
%          subplot.
%
%   rpad - Magnitude of rightward padding (empty space) to the right of
%          each subplot.
%
%   dpad - Magnitude of downward padding (empty space) to the bottom of
%          each subplot.
%
%   upad - Magnitude of upward padding (empty space) to the top of each
%          subplot.
%
% OPTIONAL INPUT
%    adj - Magnitude of space at the very bottom of the figure reserved
%          regardless of the number of rows and the value of 'dpad'. Ideal
%          for plots with a shared abcissa across vertically stacked
%          subpanels with a single abcissa text label. If omitted or
%          specified as (0), this extra spacing is not computed (the white
%          space at the bottom of the figure is simply equal to 'dpad'.
%               (default = 0)
%
% OUTPUT
%  pos - Nx4 matrix containing linearized list of subplot positions
%
% HISTORY
% (written)  June 12, 2018
% (modified) June 24, 2023: Added 'adj' parameter to flexibly create
%                           vertically stacked plots.
%
%
%   DHK - June 12, 2018
if nargin<7, adj = 0; end

pos = nan(nr*nc,4);
for i = 1:nr % Rows
    for j = 1:nc % Columns
        pos((i-1)*nc+j,:) = [ lpad + (j-1)/nc...
            (nr-i)/nr + dpad...
            1/nc-lpad-rpad...
            1/nr-upad-dpad];
    end
end
if adj
    pos(:,4) = pos(:,4)-adj;
    pos(:,2) = pos(:,2)+(1:size(pos,1))'*adj;
end