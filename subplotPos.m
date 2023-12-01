function pos = subplotPos(varargin)
% This function computes position vectors [left, bottom, width, height] in
% normalized units to position subplots within a parent figure object. An
% Nx4 matrix is returned in which the i_th row corresponds to the position
% vector for i_th subplot, N = (number of rows) x (number of columns), and
% the subplot rows and columns are linearized. Optional arguments are
% specified using the MATLAB name-pair convention.
%
% USAGE
%   pos = subplotPos(nr,nc);
%   pos = subplotPos(nr,nc,'OptionalArgName',OptionalArgValue,...);
%
% INPUT
%     nr - Number of subplot rows.
%
%     nc - Number of subplot columns.
%
% OPTIONAL INPUT
%   lpad - Magnitude of leftward padding (empty space) to the left of each
%          subplot.
%           (default = 0)
%
%   rpad - Magnitude of rightward padding (empty space) to the right of
%          each subplot.
%           (default = 0)
%
%   dpad - Magnitude of downward padding (empty space) to the bottom of
%          each subplot.
%           (default = 0)
%
%   upad - Magnitude of upward padding (empty space) to the top of each
%           (default = 0)
%          subplot.
%
%   adjx - Magnitude of space at the very bottom of the figure reserved
%          regardless of the number of rows and the value of 'dpad'. Ideal
%          for plots with a shared abcissa across vertically stacked
%          subpanels with a single abcissa text label. If omitted or
%          specified as (0), this extra spacing is not computed (the white
%          space at the bottom of the figure is simply equal to 'dpad'.
%               (default = 0)
%   adjy - Magnitude of space at the very left of the figure reserved
%          regardless of the number of columns and the value of 'rpad'.
%          Ideal for plots with a shared abcissa across horizontally
%          stacked subpanels. If omitted or specified as (0), this extra
%          spacing is not computed (the white space at the left of the
%          figure is simply equal to 'rpad'.
%               (default = 0)
%
% OUTPUT
%  pos - Nx4 matrix containing linearized list of subplot positions where
%        N = (number of rows) x (number of columns).
%
% HISTORY
% (written)  June 12, 2018
% (modified) June 24, 2023: Added 'adjx' parameter to flexibly create
%                           vertically stacked plots.
% (modified)  Nov 16, 2023: Added 'adjy' parameter to flexibly create
%                           horizontally stacked plots.
% (modified)  Dec  1, 2023: Converted arguments to optionals (except nr/nc)numel(x)==1
%
%   DHK - June 12, 2018

%% Manage inputs
p = inputParser;
addRequired(p,'nr',@(x)isnumeric(x)&&isscalar(x)); % 
addRequired(p,'nc',@(x)isnumeric(x)&&isscalar(x)); % 
addOptional(p,'lpad',0,@(x)isnumeric(x)&&isscalar(x)); % 
addOptional(p,'rpad',0,@(x)isnumeric(x)&&isscalar(x)); % 
addOptional(p,'dpad',0,@(x)isnumeric(x)&&isscalar(x)); % 
addOptional(p,'upad',0,@(x)isnumeric(x)&&isscalar(x)); % 
addOptional(p,'adjx',0,@(x)isnumeric(x)&&isscalar(x)); % 
addOptional(p,'adjy',0,@(x)isnumeric(x)&&isscalar(x)); % 
parse(p, varargin{:});
p = p.Results;

%% Routine
pos = nan(p.nr * p.nc,4);
for i = 1:p.nr % Rows
    for j = 1:p.nc % Columns
        pos((i-1)*p.nc+j,:) = [ p.lpad + (j-1)/p.nc...
            (p.nr-i)/p.nr + p.dpad...
            1/p.nc-p.lpad-p.rpad...
            1/p.nr-p.upad-p.dpad];
    end
end 
if p.adjx
    pos(:,4) = pos(:,4)-p.adjx;
    pos(:,2) = pos(:,2)+reshape(repmat(1:p.nr,p.nc,1),[],1)*p.adjx;
end
if p.adjy
    pos(:,3) = pos(:,3)-p.adjy;
    pos(:,1) = pos(:,1)+repmat((p.nc:-1:1)',p.nr,1)*p.adjy;
end