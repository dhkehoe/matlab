function y = runs(x)
% For an ordered, discrete random variable 'x', return all the ordered
% sequence lengths.
% 
% Example: runs([1,2,2,2,4,4,5,7]) returns [0,0,0,1,2]
% 0: for 1 transitioning to 2
% 2: 2 repeated twice
% 0: for 2 transitioning to 4
% 1: 4 repeated once
% 0: for 4 transitioning to 5
% 0: for 5 transitioning to 7


%
%
%   DHK - July 26th, 2024
x(isnan(x)) = []; % remove nans
y = ~diff(x(:)); % encode transitions (0) and repeats (1)
s = sequence(y,1); % get the sequence length of all repeats
if numel(s)
    s = s(:,3);
end
y = [y(~y); sort(s)];