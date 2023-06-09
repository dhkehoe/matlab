function y = owens_t(h,a)
s = size(h);
if numel(h)==1, s = size(a); end
y = reshape(owens_t__(h(:),a(:)),s);