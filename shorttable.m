function y = shorttable(data,col,fun,varargin)
% Create a short-format data table. First, input a 2D data matrix or a
% table 'data' with observations across the rows and variables across the 
% columns. Specify the outcome variable of interest 'col', where 'col'
% indexes the outcome variable of interest (see below for indexing
% instructions). Next, specify a function to apply to all instances of
%   data(:,col)
% in each marginalized cell of 'data'. Finally, provide all columns
%   C1, ..., Cn
% that will be used to parse 'data' into cells. Each 'C_i' argument is also
% specified as a columnar index of 'data'. The size of the output
% short-format table 'y', will be equal to the number of unique levels in
% each of the factors specified:
%   size(y) == [ numel(unique(data(:,C1))), ..., numel(unique(data(:,Cn)))]
% Instances of 'nan' will be automatically discounted from consideration as
% a level of factor 'Ci'.
%
% Alternatively, if 'fun' is empty, 'y' will contain the count of cases in
% in each cell. If 'fun' is a vector, 'y' will contain the proportion of
% cases in each cell. The denominator of each proportion is specified by
% the combinatoric number of cases across each factor specified in 'fun'.
% The factors are ordered in the same order as they appear in arguments
%   C1, ..., Cn.
% See examples below.
%
% The indexing format for variables 'col' and C1, ..., Cn depends on the
% format of the input data:
%   (1) When 'data' is a table, indices must be a case-sensitive string
%       specifying a variable in the table.
%   (2) When 'data' is a matrix, indices must be a numeric (scalar) or
%       logical (vector) columnar index of the matrix.
%
%--------------------------------------------------------------------------
% USAGE
%   y = shorttable(data,col,fun, C1,...,Cn);
%
%--------------------------------------------------------------------------
% EXAMPLES
%   For all examples, imagine a matrix 'data', where each row is a trial,
%   and the matrix contains variables 'subject', 'correct', 'condition',
%   and 'outcome' arranged along the columns.
%
%   This can be formatted into a table:
%       data.subject   % returns the subject number on every trial [1,..m]
%
%   This can also be formatted into a 2D matrix and indexed numerically:
%       subject = 1;
%       data(:,subject)   % returns the subject number on every trial [1,..m]
%
%   or logically:
%       % numel(subject) == size(data,2)
%       subject = [true, false, false, false];
%       data(:,subject)   % returns the subject number on every trial [1,..m]
%
%   Regardless of the format utilized, imagine the variables are defined as
%   follows:
%       data(:,subject)   % returns the subject number on every trial [1,..m]
%       data(:,correct)   % returns whether each trial was correct    {correct:1, incorrect:0}
%       data(:,condition) % returns the condition on each trial       {condition1:1, condition2:2}
%       data(:,outcome)   % returns some outcome on every trial       (e.g., response time)
%
%   Now we can extract the unique levels in each factor such that
%       sjs = unique(data(:,subject));   % [1,..m]
%       cor = unique(data(:,correct));   % [0,1]
%       con = unique(data(:,condition)); % [1,2]
%
%   _______
%   CASE 1:
%           y = shorttable(data,outcome,@mean, subject,condition);
%
%       This gives an m by 2 matrix with the mean "outcome" of each subject
%       in each condition. Thus
%
%           y(i,j) == mean(data( data(:,subject)==sjs(i) & data(:,condition)==con(j), outcome ))
%
%       If 'condition' contains NaN for any reason, these trials will not
%       be included in the mean() computation as they're not treated as a
%       valid level of factor 'condition'.
%
%   _______
%   CASE 2:
%           y = shorttable(data,[],[1], subject,correct);
%
%       This gives an m by 2 matrix with the proportion of [incorrect,correct]
%       trials for each subject. C1,...,Cn determine the marginalized cells 
%       in the numerator of the proportion, while 'fun' (i.e., [1]) 
%       determines the marginalized cells of the demoninator of the
%       proportion. Here, the [1] specifies that the denominator is the sum
%       of cases for each subject (C1). Thus
%
%           y(i,j) == sum( data(:,subject)==sjs(i) & data(:,correct)==cor(j) ) / sum( data(:,subject)==sjs(i) )
%
%   _______
%   CASE 3:
%       A special case of the above is when 'fun' contains all factors,
%       i.e., C1,...,Cn:
%
%           y = shorttable(data,[],[1,2],subject,correct);
%       
%       Here, the proportion in each cell is the proportion of the total
%       number of cases in 'data'.
%
%           y(i,j) == sum( data(:,subject)==sjs(i) & data(:,correct)==cor(j) ) / size( data,2 )
%
%   _______
%   CASE 4:
%       When 'fun' is empty 
%
%           y = shorttable(data,[],[],subject,correct);
%
%       'y' simply contains counts of cases in each marginalized cell:
%
%           y(i,j) == sum( data(:,subject)==sjs(i) & data(:,correct)==cor(j) )
%           
%
%--------------------------------------------------------------------------
% HISTORY
%   11/02/2024 - written
%   22/04/2025 - updated to accept table; updated/fixed documentation
%   30/06/2025 - improved error handling/feedback

%
%   DHK - Feb. 11, 2024


% Get the matrix size
m = size(data);

% Check that 'data' is either a 2D matrix or a table
if ~( isa(data,'table') || isnumeric(data) && 2==numel(m) )
    error('Argument ''data'' must be either a 2D matrix or a table.');
end

% Standardize the data format if a table was passed
if isa(data,'table')
    header = data.Properties.VariableNames; % Get the table header
    data = table2array(data); % Convert to a matrix
else
    header = [];
end

%% Validate varargin arguments

% Ensure any errors are thrown from shorttable()
try
    % Convert varagin (headers) to indices
    h = index(varargin,m(2),header);
    n = numel(h);

    % Get the unique levels of each factor, validating as we go
    lvls = cell(1,n);
    for i = 1:n

        % Check that the i_th factor can index some column of 'data'
        if ~h(i)
            error('');
        end

        % Get the unique levels, ignoring NaNs
        lvls{i} = nanunique(data(:,h(i)));
    end

catch err
    msg = sprintf([...
        'Argument ''C%d'' is misformatted to index a column in ''data'' during function call\n',...
        '\tshorttable(data,col,fun, C1,...,Cn)\n\n',...
        'Use the following format for arguments C1,...,Cn:\n',...
        '\t(1) When ''data'' is a table, ''Ci'' must be a case-sensitive string specifying a variable in the table.\n',...
        '\t(2) When ''data'' is a matrix, ''Ci'' must be a numeric scalar or logical vector to index a column of ''data''.'...
        ],i);
    error(struct('identifier',err.identifier,'message',msg,'stack',err.stack(end)));
end

%% Validate 'col' argument

% Check that 'col' can actually index some column of 'data', if using a
% function to collapse the outcome variable 'col'
if isa(fun,'function_handle')

    % Throw any errors from shorttable()
    try
        % Convert 'col' to an index
        col = index(col,m(2),header);

        % Check that there is a single index and it is valid (non-zero)
        if ~( isscalar(col) && col )
            error('');
        end

    catch err
        % Create detailed error string
        msg = sprintf([...
            'When argument ''fun'' is a function handle, argument ''col'' must be one of the following:\n',...
            '\t(1) When ''data'' is a table, ''col'' must be a case-sensitive string specifying a variable in the table.\n',...
            '\t(2) When ''data'' is a matrix, ''col'' must be a numeric (scalar) or logical (vector) columnar index of the matrix.'...
            ]);
        error(struct('identifier',err.identifier,'message',msg,'stack',err.stack(end)));
    end

elseif isnumeric(fun)
    % Check that, alternatively, fun is a set of indices that correspond to factors in varargin
    if any( isnan(fun) | isinf(fun) | fun<1 | n<fun )
        error(sprintf(...
            ['When ''fun'' is numeric, it must be one of the following:\n',...
            '\t(1) An empty set, which specifies raw counts in each cell.\n',...
            '\t(2) Numeric indices, which must be between (1,N), where N is the number of factors. ',...
            'Numeric indices specify proportions in each cell, where each index specifies a factor to marginalize the proportions over.',...
            ]));
    end
    fun = unique(fun);
    
else
    % Otherwise, it's misspecified.
    error(sprintf(...
        ['Argument ''fun'' must be one of the following:\n',...
        '\t(1) A function handle, which specifies how to collapse the data within each cell.\n',...
        '\t(2) An empty set, which specifies raw counts in each cell.\n',...
        '\t(3) Numeric indices, which specifies proportions in each cell where the indices specify which factors to marginalize the proportions over.',...
        ]));
end

%% Compute subject table
ind = ones(1,n); % Current level across factors
sz = cellfun(@numel,lvls); % Size of all factors
if isscalar(sz), sz = [sz,1]; end % Protect against vectors
y = nan(sz); % Output matrix

% Linearly step through 'y'
for i = 1:numel(y)
    idx = false(m(1),n); % Default this to logical

    % Step through factors
    for j = 1:n
        % Index data where the j_th factor is equal to the k_th level, where k = ind(j)
        idx(:,j) = data(:,h(j))==lvls{j}(ind(j));
    end

    % Apply the function '@fun' to the indexed data in the column specified
    % by 'col'
    if isa(fun,'function_handle')
        % Protect against ~any(idx)==1, where isempty(data(idx,col))==1
        if any(idx)
            y(i) = fun(data(all(idx,2),col));
        end % By default, if ~any(idx), then y(i) = nan
    elseif isnumeric(fun)
        % Or, if 'fun' is a numeric vector, compute the proportion of true
        % indices in this cell to the true indices across marginalized
        % cells specified by factors 'fun'.
        if isempty(fun)
            y(i) = sum(all(idx,2));
        elseif numel(fun)==n
            y(i) = sum(all(idx,2)) / m(1);
        else
            y(i) = sum(all(idx,2)) / sum(all(idx(:,fun),2));
        end
    end

    % Increment the first factor
    j = 1;
    ind(j) = ind(j)+1;

    % Check whether this increment goes out of bounds ( ind(j) > sz(j) )
    while ind(j) > sz(j) && j<n
        % If so, increment the next factor
        ind(j+1) = ind(j+1)+1;
        % Then bring this factor back down to the first level
        ind(j) = 1;
        % And so on, checking all factors, until there are no additional
        % factors to increment (terminate on j<n)
        j=j+1;
    end
end

%% Utility
function idx = index(x,m,header)
% Convert various indices to a common format (numeric indices)

% Ensure x is always a cell array
if ~iscell(x)
    x = {x};
end

% Initialize output
n = numel(x);
idx = zeros(1,n);

for i = 1:n % Step through x

    xi = x{i}; % Matlab, give us enumerators please

    % Convert table headers to logical indices
    if ~isempty(header) && ( ischar(xi) || isstring(xi) )
        xi = strcmp(header,xi);
    end

    % Convert logical indices to numeric indices
    if islogical(xi)
        xi = find(xi);
    end

    % Check that it is a valid numeric index
    if isnumeric(xi) && isscalar(xi) && ~mod(xi,1) && 1<=xi && xi<=m
        idx(i) = xi;
    else
        idx(i) = 0; % Invalid
    end
end