function p = hist2sq(p)
% Repeats all columns and rows into a continguous column/row. 'p' must be a
% 2D matrix.
%  
% EXAMPLE
%
%   >> x = [1,3;2,4]
%    
%   x =
%    
%         1     3
%         2     4
%
%   >> hist2sq(x)
%
%   ans =
%   
%        1     1     3     3
%        1     1     3     3
%        2     2     4     4
%        2     2     4     4
%
%
%
%   dhk - August 9, 2024

% Get the size and ensure it's a matrix
s = size(p);
if 2<numel(s)
    error('''p'' must be an N by M matrix.');
end

% Replicate the rows
p = reshape(repmat(p(:)',2,1),s(1)*2,s(1));

% Replicate the columns (backwards loop ensures preallocation)
for i = s(2)*2 : -2 : 2
    p(:,i+[-1,0]) = repmat(p(:,i/2),1,2);
end