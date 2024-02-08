function pim = pinken2(im,a)
% Adjust the power spectral density of 2D image 'im' so that the image has
% a PSD of 
%   S(f) ~ 1/f^a,
% where 'f' is the frequency and 'a' is any real number. When (a==1), this
% will ensure that 'im' has a pink PSD. Positive values of 'a' act as a
% low-pass filter, while negative values of 'a' act as a high-pass filter.
%
%
%   DHK - Nov. 11, 2022

% Ensure this is an image
s = size(im);
if numel(s)<2 || 3<numel(s)
    error('''im'' must contain between 2 and 3 dimensions');
end

% Default to pink noise
if nargin<2
    a = 1;
end

% Conver to double, if necessary
uint8flag = false;
if isa(im,'uint8')
    im = double(im)/255;
    uint8flag = true;
end

% Preserve the scaling of the image
mm = [min(im(:)),max(im(:))]; 

% Define the spatial frequency domain
y = [linspace(1,floor(s(1)/2),floor(s(1)/2)), -linspace(ceil(s(1)/2),1,ceil(s(1)/2))];
x = [linspace(1,floor(s(2)/2),floor(s(2)/2)), -linspace(ceil(s(2)/2),1,ceil(s(2)/2))];
[x,y] = meshgrid(x,y);
f = sqrt(x.^2+y.^2).^a;

% Scale the PSD
pim = rescale(real(ifft2(fft2(im)./f)),mm(1),mm(2));

% Convert back to uint8, if necessary
if uint8flag
    pim = uint8(round(pim*255));
end