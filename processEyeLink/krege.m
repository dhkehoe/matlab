% Memory and computationally efficient (Gaussian) kernel regression 
% function for MATLAB. Properly implemented (i.e., matrix-based) MATLAB
% solutions will run faster on small datasets, but they have an O(n * m)
% time complexity, whereas this .mex function has an O(n) time complexity
% making it a much better option for large datasets.
%
% USAGE
%   f = krege(x,y,d);
%   f = krege(x,y,d,bw);
%   [f,e] = krege(x,y,d,bw);
%
% INPUT:
%   x - Vector containing the x-domain values of the data to be regressed.
%   y - Vector containing the y-domain values of the data to be regressed.
%   d - Vector containing the exact x-domain to fit the regression
%       function.
%
% OPTIONAL INPUT:
%    bw - The kernel bandwidth (scalar).
%
% OUTPUT:
%   yhat - Vector of equal length to 'd' containing the fitted regression
%          function.
%   ehat - Vector of equal length to 'd' containing the fitted regression
%          function standard error.
%
% EXCEPTIONS:
%   1) Fewer than 3 arguments were passed.
%   2) Empty array passed as an argument for 'x', 'y', or 'd'.
%   3) Mismatched number of elements in 'x' and 'y'.