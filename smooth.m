function [sx,sy] = smooth(x,y,sigmaT,sigmaS)
% Use Gaussian kernels to smooth the gaze position samples in 'x' and 'y'
% as a function of both time and space. Must pass kernel bandwidths as
% required arguments since the data can be in any units.
%
% USAGE
%   [sx,sy] = smooth(x,y,sigmaT,sigmaS);
%
% INPUT
%   x      - X component of raw eye position samples.
%   y      - Y component of raw eye position samples.
%   sigmaT - The temporal 1D Gaussian kernel bandwidth in units of number
%            of samples.
%   sigmaS - The spatial 2D (circular) Gaussian kernel bandwidth in the
%            same units as the data in 'x' and 'y'. For example, if the
%            data is left in units of screen pixels, this must be passed in
%            units of pixels also.
%
% OUTPUT
%   sx - The smooothed x component of the eye position samples.
%   sy - The smooothed y component of the eye position samples.
%
%   DHK - May 5, 2022

%% Compute temporal kernels
t = 1:numel(x); % sample numbers
[mu_t,t] = meshgrid(t,t);
k_t = exp( -(t-mu_t).^2/sigmaT ); % temporal kernel
clear mu_t, clear t; % this function seriously risks running out of memory, so free some up whenever possible

%% Compute spatial kernels
[mu_x,x] = meshgrid(x,x);
[mu_y,y] = meshgrid(y,y);
k_s = exp( ( -(x-mu_x).^2 -(y-mu_y).^2 )/sigmaS ); % spatial kernel
clear mu_x, clear mu_y; 

%% Compute spatiotemporal kernels
k = k_t .* k_s;
clear k_t, clear k_s;

%% Kernel regress the raw data
sx = nansum(x.*k) ./ nansum(k); %#ok
sy = nansum(y.*k) ./ nansum(k); %#ok