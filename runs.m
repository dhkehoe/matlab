function [r,xi,i] = runs(x)
% For an ordered, discrete random variable 'x', return all the ordered
% run lengths.
%
% USAGE
%   [r,xi,i] = runs(data);
%
% INPUT
%   x - An n-dimensional numeric array.
%
% OUTPUT
%    r - A length N vector of run lengths.
%   xi - A length N vector of the 'x' values repeated within each run.
%    i - An N by 2 matrix of the start and stopping indices of each of the
%        N runs.
%
% EXAMPLE
%   [r,xi,i] = runs([1,2,2,2,4,4,5,7])
%
%    r =    xi =     i =
%       1       1       1,1
%       3       2       2,4
%       2       4       5,6
%       1       5       7,7
%       1       7       8,8
%
%
%
%   DHK - July 26th, 2024

x = x(:);
ss = ~[1; diff(x)]; % switch/stay (false/true)

nrun = 0; % Number of runs
lrun = 0; % Length of current run
arun = nan(numel(x),4); % All run info

for j = numel(x) : -1 : 1 % Step through data (backwards)
    if ss(j) % Stay
        lrun = lrun+1;
    else % Switch
        nrun = nrun+1; % End of this run
        arun(nrun,:) = [lrun, x(j), j, j+lrun];
        if lrun % If on-going run (run length > 0)...
            lrun = 0; % reset run length
        end
    end
end

% Trim the unused indices
arun = flipud(arun(1:nrun,:));

% Split into the return values
r  = arun(:,1)+1;
xi = arun(:,2);
i  = arun(:,3:4);