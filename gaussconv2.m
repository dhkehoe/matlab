function varargout = gaussconv2(im,varargin)
% im = imread('photo-1503424886307-b090341d25d1.jpg');
%%
p = inputParser;
addOptional(p,'order',1,@(x)isnumeric(x)&&numel(x)==1), % Derivative order
addOptional(p,'scale',2,@(x)isnumeric(x)&&numel(x)==1), % Spatial scale (2 = every other pixel)
addOptional(p,'sigma',10,@(x)isnumeric(x)&&numel(x)==1), % Gaussian width
parse(p,varargin{:});
p = p.Results;

%%
if isa(im,'uint8')
    im = double(im)/255;
end

[h,w,c] = size(im); % [height,width,channels]

yi = [round(linspace(p.scale,h,h/p.scale));...
    round(linspace(1,h-p.scale,h/p.scale))]; % Indices of y
xi = [round(linspace(p.scale,w,w/p.scale));...
    round(linspace(1,w-p.scale,w/p.scale))]; % Indices of x
h = size(yi,2);
w = size(xi,2);

[x,y] = meshgrid(xi(1,:),yi(1,:));

%% Generate exhaustive 1D kernels (dx and dy)
%   dx(:,:,j) .* dy(:,:,i) gives the 2D kernel for pixel (i,j)
switch p.order 
    case 0 % zero-order (blur)
        dx = exp( -( repmat(x,1,1,w) - reshape(repmat( x,w,1),h,w,w) ).^2 / (2*p.sigma^2) ); % 1D x kernels
        dy = exp( -( repmat(y,1,1,h) - reshape(repmat(y',h,1),h,w,h) ).^2 / (2*p.sigma^2) ); % 1D y kernels
    case 1 % first-order (sharpen)
        p.sigma = 1/p.sigma;
        dx = repmat(x,1,1,w) - reshape(repmat( x,w,1),h,w,w); % ( x - mu_x )
        dy = repmat(y,1,1,h) - reshape(repmat(y',h,1),h,w,h); % ( y - mu_y )
        dx = exp( -( dx ).^2 / (2*p.sigma^2) ) .* dx; % 1D x kernels
        dy = exp( -( dy ).^2 / (2*p.sigma^2) ) .* dy; % 1D y kernels
        dx = dx / max(dx(:)); % bound kernels on (-1,1)
        dy = dy / max(dy(:));
%     case 2 % second-order (contrast)
%         dx = 2*exp( -( repmat(x,1,1,w) - reshape(repmat( x,w,1),h,w,w) ).^2 / (2*p.sigma^2) )-...
%             exp( -( repmat(x,1,1,w) - reshape(repmat( x,w,1),h,w,w) ).^2 / (2*p.sigma^2) ); % 1D x kernels
%         dy = 2*exp( -( repmat(y,1,1,h) - reshape(repmat(y',h,1),h,w,h) ).^2 / (2*p.sigma^2) )-...
%             exp( -( repmat(y,1,1,h) - reshape(repmat(y',h,1),h,w,h) ).^2 / (2*p.sigma^2) ); % 1D y kernels
    otherwise
        error('Gaussian derviative out of bounds. Valid options: (0-1)');
end

%% process image
imp = zeros(size(im));
bw = max([ min([p.sigma(1)*3,50]), 5]); % bound the kernels between a size of (5,50)

for i = 1:size(yi,2)
    if any(i==round(linspace(.1,1,10)*h))
        fprintf('Processing image... %.2f%%\n',i/h*100);
    end
    yh = -bw+yi(1,i) <= yi(1,:) & yi(1,:) <= bw+yi(1,i);

    for j = 1:size(xi,2)
        xh = -bw+xi(1,j) <= xi(1,:) & xi(1,:) <= bw+xi(1,j);

        f = dy(yh,xh,i).*dx(yh,xh,j);
        imp(yi(2,i):yi(1,i),xi(2,j):xi(1,j),:) = ...
            repmat( ...
                sum( im(yi(1,yh),xi(1,xh),:) .* repmat(f,1,1,c), [1,2] ),...
                [yi(1,i)-yi(2,i)+1, xi(1,j)-xi(2,j)+1]...
            ) / sum(abs(f(:)));
    end
end

%% ensure correct image contrast
contrast   = [min( im(:)),max( im(:))];
contrast_p = [min(imp(:)),max(imp(:))];
imp = (imp-contrast_p(1))./(contrast_p(2)-contrast_p(1)) ...
    * (contrast(2)-contrast(1)) + contrast(1);

%% set output
if nargout==1
    varargout{1} = imp;
else
    figure; imshow(imp); set(gca,'YDir','normal');
end