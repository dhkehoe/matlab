function h = fmtcolheader(header)
% Outputs a struct to easily access variables in a column-labelled table.
% Convert a cell vector of strings into a struct containing identical field
% names, where each fieldname is a logical index to the corresponding
% column.
%
% USAGE
%   h = fmtColHeader(header);
%
% INPUT
%   header - Cell vector of strings.
%
% OUTPUT
%        h - Struct with identical fields names as those in 'header'.
%
% EXAMPLE
%   d = importdata('mydata.txt');   % column 1 labelled "var1"
%   header = d.colheaders;          % header{1} == 'var1'
%   d = d.data;
%   h = fmtcolheader(header);
%   
%   d(:,h.var1)                     % indexes column 1
%
%
%   DHK - Oct. 21, 2023

%% Process
if ~iscell(header) || ~isvector(header) || ~all(cellfun(@ischar,header))
    error('Input must be a 1D array of strings.');
end

h = struct;
for i = 1:numel(header)
    h.(header{i}) = strcmp(header,header{i});
end