function [h,f,fmt] = buildheader(varargin)
% Utility to build a tab delimited format string to write a 2D data matrix
% to text format, with other useful header information. Part of a suite of
% utilities I've built because I bitterly refuse to use the awfully
% implemented Table structures in MATLAB and opt to use 2D matrices
% instead.
%
% USAGE
%   [h,f,fmt] = buildheader('var1','datatype1', ...,'varN','datatypeN');  
%
% INPUT
%   A list of sequentially paired inputs, where each pair consists of a
%   header string and an subsequent datatype format specifier. The format
%   specifier indicates how the data in the column should be encoded when
%   written to text on disk. Valid options are {'int', 'float', 'char'} or
%   {1, 2, 3}, interchangably. These corresponds to {'%d', '%f', '%s'}
%   when writing to file using fprintf().
%
% OUTPUT
%     h - A struct where each field is one of the header strings in
%         varargin and can be used to logically index columns in the data
%         matrix. See also fmtcolheader()
%         
%     f - A cell array of strings that correspond to the header string
%         names.
%
%   fmt - The format string that can be passed directly to fprintf() to
%         write 2D matrix to file.
%
% EXAMPLE
%   [h,header,fmt] = buildheader('var1','int', 'var2','float');
%   % h == fmtcolheader(header);
%   % header == {'var1', 'var2'};
%   % fmt == '%d\t%f\n';
%
%   % Create some data matrix with 1 column of ints and 1 column of floats:
%   data = [randi(10,1), rand(10,1)];
%
%   % Write this data to disk
%   fid = fopen('data.txt','Wt');
%   fprintf(fid,fmt,data');
%   fclose(fid);
%
%   % NOTE: after testing, this method outperforms MATLAB's writetable(),
%   % writematrix(), and the like.
%
%
%   DHK - Jan. 10, 2025

%   1 - int
%   2 - float
%   3 - char

%% Process input + error check

% Unpack if necessary
if isscalar(varargin)
    varargin = [varargin{:}];
end

% Check number of arguments
if ~mod(numel(varargin),2)
    error('');
end

% Locate fields
f = varargin(1:2:end);

% Error check fields
if ~all(cellfun(@ischar,f))
    error('');
end

% Locate values
v = varargin(2:2:end);

% Convert string format specifiers to integers
str2int = {'int','float','char'};
for i = find(cellfun(@ischar,v))
    j = strcmp(v{i},str2int);
    if any(j)
        v{i} = find(j);
    else
        error('');
    end
end
v = [v{:}];

% Error check values
if ~all(any( (1:3)' == v ))
    error('');
end

%% Compute fmt string and header struct
fmt = {'d','f','s'};
fmt = reshape( [repmat('%',numel(v),1), vertcat(fmt{v}), repmat('\t',numel(v),1)]', [],1)';
fmt(end) = 'n';

% Error check
h = fmtcolheader(f);