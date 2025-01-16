function str = cell2str(c)
% Quick check arguments
if ~iscell(c) || ~all(cellfun(@ischar,c),'all')
    error('Input must be a cell array that only contains chararcter arrays within each element.');
end

% Get the number of elements in each cell
N = cellfun(@numel,c);

% Initialize string
str = repmat(' ',1,sum(N,'all'));

% Linearly step through cell array
s = 1; % Start index to map i_th string in 'c' into total string 'str'
for i = 1:numel(c)
    e = s+N(i)-1; % End index
    str(s:e) = c{i}; % Copy
    s = e+1; % Update start
end