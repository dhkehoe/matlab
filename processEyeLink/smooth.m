function [sx,sy] = smooth(x,y,sigmaT,sigmaS,overlap)
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
%   
% HISTORY
%   (written)  May 5, 2022: Created routine
%   (appendum) May 9, 2023: Catch block for greatly improved memory allowance
%
%
%   DHK - May 5, 2022

%% Manage input
if nargin<5, overlap = 5; end
x = x(:);
y = y(:);
if numel(x)~=numel(y)
    error('Dimension mismatch between inputs ''x'' and ''y''.');
end

%% Smooth data
try
    % Try entire data set
    [sx,sy] = smooth_(x,y,sigmaT,sigmaS);
catch

    % Out of memory... recursively split the data
    n = numel(x);
    i = 1:n;
    sx = nan(n,1);
    sy = nan(n,1);
    
    % Split the data; smooth the first half via recursive call
    [fx,fy] = smooth( x( i<floor(n/2)+sigmaT*overlap ), y( i<floor(n/2)+sigmaT*overlap ), sigmaT, sigmaS );
    sx( i<=floor(n/2) ) = fx( 1:floor(n/2) ); % Fill first half
    sy( i<=floor(n/2) ) = fy( 1:floor(n/2) );
    clear fx, clear fy;

    % Smooth the second half via recursive call
    [fx,fy] = smooth( x( i>floor(n/2)-sigmaT*overlap ), y( i>floor(n/2)-sigmaT*overlap ), sigmaT, sigmaS );
    sx( i>floor(n/2) ) = fx( sigmaT*overlap+1:end ); % Fill second half
    sy( i>floor(n/2) ) = fy( sigmaT*overlap+1:end );

end
    
function [sx,sy] = smooth_(x,y,sigmaT,sigmaS)

%% Compute temporal kernels
t = 1:numel(x); % sample numbers
[mu_t,t] = meshgrid(t,t);
t = exp( -(t-mu_t).^2/sigmaT ); % temporal kernel
clear mu_t; % this function seriously risks running out of memory, so free some up whenever possible

%% Compute spatiotemporal kernels
[mu_x,x] = meshgrid(x,x);
[mu_y,y] = meshgrid(y,y);
t = t .* exp( ( -(x-mu_x).^2 -(y-mu_y).^2 )/sigmaS ); % spatial kernel * temporal kernel
clear mu_x, clear mu_y;

%% Kernel regress the raw data
sx = reshape( nansum(x.*t) ./ nansum(t) ,[],1); %#ok
sy = reshape( nansum(y.*t) ./ nansum(t) ,[],1); %#ok