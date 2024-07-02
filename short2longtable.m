function t = short2longtable(varargin)
% Convert a short fortmat data table to a long format data table.
%
% INPUTS
%   y - short format data table.
%
% OPTIONAL INPUT

%% Manage input
p = inputParser;
addRequired(p,'y');
addOptional(p,'header',      [],@iscell);
addOptional(p,'variablename',[],@ischar);
addOptional(p,'table',       [],@(x)isnumeric&&isscalar(x));
addOptional(p,'category',    [],@isnumeric);
parse(p,varargin{:});
p = p.Results;

% Set defaults

% Convert to a 'table' data type.
if isempty(p.table)
    p.table = 1;
end

% Give a name to the outcome variable?
if isempty(p.variablename)
    p.variablename = 'y';
end

%% Get the short table dimensions
facs = size(p.y);
nrow = numel(p.y);
nfac = numel(facs);

%% Couple more defaults

% Default factor names are X_1, ..., X_n
if isempty(p.header)
    p.header = cellstr([repmat('x',nfac,1),num2str((1:nfac)')]);
end
p.header = reshape(p.header,[],1); % Force into a column vector

% Categorical variables?
if isempty(p.category)
    p.category = true(1,nfac);
else
    if numel(p.category) ~= nfac
        error('Optional argument ''category'' must be a numeric vector with as many elements as dimensions in ''y''.');
    end
end

%% Fill the table
t = [nan(nrow,nfac), p.y(:)];
for i = 1:nrow
    t(i,1:nfac) = ind2submat(facs,i);
end

% Convert into an actual 'table' data type
if p.table
    t = array2table(t,'VariableNames',[p.header;p.variablename]);
    for i = 1:nfac
        if p.category(i)
            t.(p.header{i}) = categorical(t.(p.header{i}));
        end
    end
end