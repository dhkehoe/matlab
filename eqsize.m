function [b,szx,szy] = eqsize(x,y)
% Return whether 2 matrices are of equal size along all dimensions
szx = size(x);
szy = size(y);
b = numel(szx)==numel(szy) && all(szx==szy);