function x = repcolrow(x)
% Repeats all columns and rows into continguous pairs of columns/rows. 
% 'x' must be a 2D matrix.
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
%   >> repcolrow(x)
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
s = size(x);
if 2<numel(s)
    error('''x'' must be an N by M matrix.');
end

% Replicate the rows
x = reshape(repmat(x(:)',2,1),s(1)*2,s(1));

% Replicate the columns (backwards loop ensures preallocation)
for i = s(2)*2 : -2 : 2
    x(:,i+[-1,0]) = repmat(x(:,i/2),1,2);
end