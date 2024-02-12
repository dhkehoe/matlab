function y = shorttable(data,col,fun,varargin)
% Create a short-format data table. First, input a (presumably raw) data
% table 'data' with observations across the rows and variables across the 
% columns. Specify the outcome variable of interest 'col', where 'col' is a
% logical vector to indicate which column hosts the outcome variable of
% interest. Next, specify a function to apply to all instances of 
%   data(:,col)
% in each marginalized cell of 'data'. Finally, provide all columns
%   C1, ..., Cn
% that will be used to parse 'data' into cells. Each column is also
% specified as a logical vector to index 'data'. The size of the output
% short-format table 'y', will be equal to the number of unique levels in
% each of columns (factors) specified:
%   size(y) == [ numel(unique(data(:,C1))), ..., numel(unique(data(:,Cn)))]
% Instances of 'nan' will be automatically discounted from consideration as
% a level of factor Ci.
%
% Alternatively, if 'fun' is numeric, 'y' will contain the proportion of
% cases in each cell as a function of the number of cases across each level
% of the factors, specified by their subscript, given in place of 'fun'.
% See examples below.
%
%--------------------------------------------------------------------------
% USAGE
%   y = sjtable(data,col,fun, C1,...,Cn);
%
%--------------------------------------------------------------------------
% EXAMPLES
%   For all examples, imagine a matrix 'data', where each row is a trial,
%   and it contains columns 'subject', 'correct', 'condition', and
%   'outcome'. These variables are all of the same width as 'data'; e.g.,
%       numel(subject) == size(data,2)
%   and logically index a column of 'data'; e.g.,
%       data(:,subject)   % returns the subject number on every trial [1,..m]
%       data(:,correct)   % returns whether each trial was correct    {correct:1, incorrect:0}
%       data(:,condition) % returns the condition on each trial       {condition1:1, condition2:2}
%       data(:,outcome)   % returns some outcome on every trial       (e.g., response time)
%   Furthermore, we can extract the unique levels in each factor such that
%       sjs = unique(data(:,subject));   % [1,..m]
%       cor = unique(data(:,correct));   % [0,1]
%       con = unique(data(:,condition)); % [1,2]
%
%   _______
%   CASE 1:
%           y = sjtable(data,outcome,@mean,subject,condition);
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
%           y = sjtable(data,[],[1],subject,correct);
%
%       This gives an m by 2 matrix with the proportion of [incorrect,correct]
%       trials for each subject. C1,...,Cn determine the marginalized cells 
%       in the numerator of the proportion, while 'fun' (i.e., [1]) 
%       determines the demoninator of the proportion. Thus
%
%           y(i,j) == sum( data(:,subject)==sjs(i) & data(:,correct)==cor(j) ) / sum( data(:,subject)==sjs(i) )
%
%   _______
%   CASE 3:
%       When 'fun' is empty or is of equal length to the number of factors:
%
%           numel(fun)==n || isempty(fun)
%
%       where 'n' is the number of factors in C1,...,Cn, then the
%       demoninator in the proportion is simply the size of the data set:
%
%           y = sjtable(data,[],[1,2],subject,correct);
%           y = sjtable(data,[],[],subject,correct);
%
%       These equvalently give an m by 2 matrix with the number of
%       [incorrect,correct] trials for each subject as a proportion of the
%       entire data set. Thus
%           y(i,j) == sum( data(:,subject)==sjs(i) & data(:,correct)==cor(j) ) / size( data,2 )
%
%--------------------------------------------------------------------------
%
%
%   DHK - Feb. 11, 2024

% Get the matrix size
m = size(data);

% Check that 'col' can logically index column of 'data'
if numel(col) ~= m(2) && isa(fun,'function_handle')
    error('When argument ''fun'' is a function handle, argument ''col'' must be a logical vector to index a column of ''data''.');
end

% Get the number of factors
n = numel(varargin);

% Get the unique levels of each factor, validating as we go
lvls = cell(1,n);
for i = 1:n
    % Check that the i_th factor can logically index column of 'data'
    if numel(varargin{i}) ~= m(2)
        error('Arguments sjtable(data,col,fun, C1,...Cn) ');
    end

    % Get the unique levels
    lvls{i} = unique(data(:,varargin{i}));
    lvls{i}( isnan(lvls{i}) ) = []; % Trim out NaNs
end

%% Compute subject table
ind = ones(1,n); % Current level across factors
sz = cellfun(@numel,lvls); % Size of all factors
if numel(sz)==1, sz = [sz,1]; end % Protect against vectors
y = nan(sz); % Output matrix

% Linearly step through 'y'
for i = 1:numel(y)
    idx = false(m(1),n); % Default this to true

    % Step through factors
    for j = 1:n
        % Index data where the j_th factor is equal to the k_th level, where k = ind(j)
        idx(:,j) = data(:,varargin{j})==lvls{j}(ind(j));
    end

    % Apply the function '@fun' to the indexed data in the column specified
    % by 'col'
    if isa(fun,'function_handle')
        y(i) = fun(data(all(idx,2),col));
    elseif isnumeric(fun)
        % Or, if 'fun' is a numeric vector, compute the proportion of true
        % indices in this cell to the true indices across marginalized
        % cells specified by factors 'fun'.
        if numel(fun)==n || isempty(fun)
            y(i) = sum(all(idx,2)) / m(1);
        else
            y(i) = sum(all(idx,2)) / sum(all(idx(:,fun),2));
        end
    else
        % Otherwise, it's misspecified.
        error('Argument ''fun'' must be either a function handle or numeric indices used to compute a proportion.');
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