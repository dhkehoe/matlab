function y = owens_t(h,a)
% Owen's T function, T(h, a), gives the probability of the event 
%   (X > h and 0 < Y < aX)
% where X and Y are independent standard normal random variables.
%
% Defined in
% Owen, D B (1956). "Tables for computing bivariate normal probabilities".
%       Annals of Mathematical Statistics, 27, 1075–1090.

% This is a wrapper around a .mex file, which wraps boost::math::owens_t()
% written in C++.
% 
% Compiled under
%   MSVC    19.40.33813
%   boost   1.87.0

% .mex linearizes data, so ensure the shape is preserved
if isscalar(a)
    s = size(h);
else
    s = size(a);
end
y = reshape(owens_t__(h,a),s);