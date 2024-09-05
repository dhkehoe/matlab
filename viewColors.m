function viewColors(cols,radius,order)
% Draw an assortment of colors onto a color wheel (annulus).
%
%  cols  - Must be an N x 3 matrix of N colors that are RGB encoded along
%          the columns. It can be in either double or uint8 format, where
%          doubles are on the interval (0,1) and uint8 are on the interval
%          (0,255).
% radius - The inner radius of the color wheel on the interval (0,1). A
%          value of 0 makes a circle. A value of 1 makes a ring. Default is
%          .5.
%  order - Indicates whether to order the colors according to the color
%          wheel. By default, we will order them to ensure it doesn't look
%          like trash when we draw them.

%% Check inputs
if nargin<3 || isempty(order)
    order = 1;
end
if nargin<2 || isempty(radius)
    radius = .5;
elseif radius < 0 || 1 < radius
    error('Optional argument ''radius'' must be in the interval (0,1).');
end

if size(cols,2)~=3
    error('Incorrect format: input must contain an (N by 3) matrix of (N) RGB values.');
end
if isa(cols,'uint8')
    cols = double(cols)/255;
end
if any(cols(:)<0 | cols(:)>1 | isnan(cols(:)))
    error('One or more invalid RGB values: values must be uint8 (0 <= x <= 255) or double (0 <= x <= 1).');
end

%% Set up
n = size(cols,1);
if order
    l = rgb2hsv(cols); % convert to hsv to get hue color wheel location
    [~,l] = sort(l(:,1)); % sort them
    cols = cols(l,:);
end

%% Draw
hold on;
for i = 1:n
    t = linspace( (i-1)/n, i/n, 100 )*2*pi;
    fill( [cos(t),fliplr(cos(t)*radius)],[sin(t),fliplr(sin(t)*radius)],'k','FaceColor',cols(i,:),'EdgeColor','none'); % hemi-circle
end
daspect([1,1,1]); 
axis off;

% Color wheel
% >>viewColors(pickColors(100));