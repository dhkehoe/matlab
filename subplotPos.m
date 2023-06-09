function pos = subplotPos(nr,nc,lpad,rpad,dpad,upad)
% This function computes position vectors [left, bottom, width, height] in
% normalized units to position subplots within a parent figure object. An
% Nx4 matrix is returned in which the i-th row corresponds to the position
% vector for i-th subplot, N = (number of rows) x (number of columns), and
% the subplot rows and columns are linearized.
%
%   DHK - June 12, 2018
%
%   INPUT
%   nr - number of subplot rows
%
%   nc - number of subplot columns
%
% lpad - magnitude of leftward padding (empty space) to the left of each
%        subplot
%
% rpad - magnitude of rightward padding (empty space) to the right of each
%        subplot
%
% dpad - magnitude of downward padding (empty space) to the bottom of each
%        subplot
%
% upad - magnitude of upward padding (empty space) to the top of each
%        subplot
%
%   OUTPUT
%  pos - Nx4 matrix containing linearized list of subplot positions

pos = nan(nr*nc,4);
for i = 1:nr % Rows
    for j = 1:nc % Columns
        pos((i-1)*nc+j,:) = [ lpad + (j-1)/nc...
            (nr-i)/nr + dpad...
            1/nc-lpad-rpad...
            1/nr-upad-dpad];
    end
end