function [x,y,d] = cart(w,h)
% Create Cartesian coordinates using a domain width and height.
%
% INPUT
%   w - Scalar specifying width of coordinate system.
%   h - Scalar specifying height of coordinate system.
% OUTPUT
%   x - (w by h) matrix of x values with range w/2 and 0 origin.
%   y - (w by h) matrix of y values with range h/2 and 0 origin.
%   d - (w by h) matrix of Euclidean distance values with range 
%           sqrt( (w/2)^2 + (h/2)^2 ) and 0 origin.
%
%   DHK - Nov. 26, 2024
[x,y] = meshgrid( (1:w)-(1+w)/2, (1:h)-(1+h)/2 );
d = sqrt( x.^2 + y.^2 );
