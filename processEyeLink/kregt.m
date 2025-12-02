% Memory and computationally efficient Gaussian kernel regression function
% for smoothing a time series. That is, the 'x' values are presumed to be
% (1) ordered and (2) equally-spaced, and thus are utilized as the
% regression function domain. Note that the data is not checked for invalid
% cases that will distort the results.
%
%
% USAGE (MATLAB):
%   yhat = kregt(x,y,bw);
%
% INPUT:
%     x - The x-coordinate values of the data to be regressed.
%     y - The y-coordinate values of the data to be regressed.
%    bw - The kernel bandwidth. Values of [], bw<0, Nan, or Inf will raise
%         an exception. 'bw' must be in the same units as 'x'.
%
%        NOTES: (1) 'x' and 'y' must contain the same number of elements.
%               (2) 'x' and 'y' are not checked for invalid cases (NaN, Inf),
%                   which, if present, will distort results.
%
% OUTPUT:
%   yhat - The fitted regression function. Equal length to 'x'.
%
% EXCEPTIONS:
%   1) Greater than 1 value was returned.
%   2) Less than or greater than 3 arguments were passed.
%   3) Empty array passed as an argument for 'x' or 'y'.
%   4) Mismatched number of elements in 'x' and 'y'.
%
%
%
% COMPILATION:
%   Compile with following instructions in the MATLAB Commmand Window:
%       MSVC:
%           mex krege.c -output krege COMPFLAGS="$COMPFLAGS /openmp"
%       GCC:
%           mex krege.c -output krege CFLAGS="$CFLAGS -fopenmp"
%       Clang:
%           mex krege.c -output krege CFLAGS="$CFLAGS -fopenmp=libomp"
%
% DEPENDENCIES:
%   OpenMP v2.0 or later (https://www.openmp.org/resources/openmp-compilers-tools/)
%
% AUTHOR:
%   Devin H. Kehoe
%   dhkehoe@gmail.com
%
% DATE:
%   December 2, 2025
%
% HISTORY:
%   author  date            task         
%   dhk     aug  6, 2023    -written (see krege.c)
%   dhk     nov 29, 2025    -adopted OpenMP for parallelization (x5 speed-up)
%   dhk     dec  2, 2025    -assuming ordered time series data, extra computational
%                            acceleration is possible (additional x2 speed-up)