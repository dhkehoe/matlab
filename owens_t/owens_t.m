%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Owen's T function, T(h, a), gives the probability of the event 
%   (X > h and 0 < Y < aX)
% where X and Y are independent standard normal random variables.
%
% Defined in
% Owen, D B (1956). "Tables for computing bivariate normal probabilities".
%       Annals of Mathematical Statistics, 27, 1075–1090.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% USAGE
%   p = owens_t(h,a);
%
% INPUT
%   h - Array of any number of dimensions. Must be either scalar or contain
%       the same number of elements as 'a'.
%   a - Array of any number of dimensions. Must be either scalar or contain
%       the same number of elements as 'h'.
%
% OUTPUT
%   p - Array with the same size as 'h' or 'a'.
%
% EXCEPTIONS
%   (1) Fewer or more than 2 arguments were passed.
%           MESSAGE: "Must pass 2 arguments."
%
%   (2) 'h' or 'a' are not type double.
%           MESSAGE: "Can't convert the Array to this TypedArray"
%
%   (3) 'h' or 'a' are empty.
%           MESSAGE: "One or more empty argument(s) passed."
%
%   (4) Size mismatch between 'h' and 'a'. They must be the same size or at
%       least one must be scalar.
%           MESSAGE: "Input size mismatch. Arguments must be either the same size or at least one argument must be scalar."

% COMPILATION
%   This is a wrapper around the boost::math::owens_t() C++ function to
%   port an Owen's T function into MATLAB. The code is architecture
%   independent, so it should recompile on any system.
% 
%   Current version compiled under
%       MSVC    19.40.33813
%       boost   1.87.0
%
%   Compilation instructions:
%       (1) Boost libraries are available for download at https://www.boost.org/
%       (2) Ensure MEX is configured for C++ language compilation. To
%           verify, type the following in the Command Window:
%               >> mex -setup c++
%       (3) In MATLAB, set working directory to location of owens_t.cpp
%       (4) Type in the Command Window:
%               >> mex owens_t.cpp -I'<boost_parent_directory>' -output owens_t
%           where <boost_parent_directory> is the top directory of boost.
%           Example:
%               >> mex owens_t.cpp -I'C:\boost_1_87_0' -output owens_t
%
%
% AUTHOR:
%   Devin H. Kehoe
%   dhkehoe@gmail.com
%   April 24, 2025