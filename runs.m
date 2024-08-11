function y = runs(x)
% For an ordered, discrete random variable 'x', return all the ordered
% sequence lengths.
% 
% Example: runs([1,2,2,2,4,4,5,7]) returns [0,0,1,2]
% 0: for 4 transiting to 5
% 0: for 5 transiting to 7
% 1: 4 repeated once
% 2: 2 repeated twice
%
%
%   DHK - July 26th, 2024
y = ~diff(x(:));
s = sequence(y,1);
if numel(s)
    s = s(:,3);
end
y = [zeros(sum(~y)-numel(s),1); sort(s)];