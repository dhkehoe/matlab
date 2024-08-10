function p = hist2sq(p)
s = size(p);
p = reshape(repmat(p(:)',2,1),s(1)*2,s(1)); % replicate the rows
% replicate the columns (there might be a better way to do this?)
for i = s(2)*2 : -2 : 2
    p(:,i+[-1,0]) = repmat(p(:,i/2),1,2);
end