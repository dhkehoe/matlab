function t = short2longtable(y,header,varname,table)
% Convert a short fortmat data table to a long format data table.
%
% INPUTS
%   y - short format data table.
%

% Convert to a 'table' data type.
if nargin<4
    table = 1;
end

% Give a name to the outcome variable?
if nargin<3
    varname = 'y';
end

% Get the short table dimensions
facs = size(y);
nrow = numel(y);
nfac = numel(facs);

% Default factor names are X_1, ..., X_n
if nargin<2
    header = cellstr([repmat('x',nfac,1),num2str((1:nfac)')]);
end
header = reshape(header,[],1); % Force into a column vector

% Fill the table
t = [nan(nrow,nfac), y(:)];
for i = 1:nrow
    t(i,1:nfac) = ind2submat(facs,i);
end

% Convert into an actual 'table' data type
if table
    t = array2table(t,'VariableNames',[header;varname]);
    for i = 1:nfac
        t.(header{i}) = categorical(t.(header{i}));
    end
end