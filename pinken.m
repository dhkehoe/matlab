function pim = pinken(im,f)
s = size(im);
if numel(s)>3, error('''im'' cannot contain more than 3 dimensions'); end
if nargin<2, f = 1; end
mm = nan(size(im,3),2);
for i = 1:size(mm,1)
    x = reshape(im(:,:,i),[],1);
    mm(i,:) = [min(x),max(x)];
end
y = [linspace(1,floor(s(1)/2),floor(s(1)/2)), -linspace(ceil(s(1)/2),1,ceil(s(1)/2))]*f;
x = [linspace(1,floor(s(2)/2),floor(s(2)/2)), -linspace(ceil(s(2)/2),1,ceil(s(2)/2))]*f;
[x,y] = meshgrid(x,y);
f = sqrt(x.^2+y.^2).^f; % 2D spatial frequency domain

pim = real(ifft2(fft2(im)./f));
for i = 1:size(mm,1)
    pim(:,:,i) = rescale(pim(:,:,i)) * (mm(i,2)-mm(i,1)) + mm(i,1);
end
% fim = fim/std(fim(:))*std(im(:));