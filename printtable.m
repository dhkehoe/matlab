function varargout = printtable(mat,varargin)
% This function prints the data in the 2 dimensional matrix 'mat' with nice
% formatting not afforded by disp(array2table(mat)). A number of formatting
% options can be specified using optional arguments input using the MATLAB
% name-pair convention. Can optionally return the table as a string, which
% is useful for writing the formatted table to file.
%
%
% USAGE
%   printtable(mat);
%   printtable(mat,'OptionalArg1Name',OptionalArg1Value,...);
%   str = printtable(mat);
%
%
% INPUT
%   mat - An n x m matrix containing data to be printed.
%
%
% OPTIONAL INPUT
%      cols - Cell array of column header strings. Must contain exactly m
%             or m+1 elements. If m+1 elements are passed, the first
%             element is the header for the row labels. It is possible to
%             print multicolumns using a recursive format:
%               {..., {'parent',{'child1','child2'}}, ...}
%             This indicates that columns 'child1' and 'child2' are
%             subcategories of 'parent'. It is also possible to recursively
%             stack these parent-child subarrays:
%               {...,
%                   {'grandparent',...
%	                    {...
%		                    {'parent1',{'child1','child2'}}, {'parent2',{'child3','child4'}}...
%	                    }
%                   },
%               ...}
%             Note that the length (m) of 'cols' is considered using the
%             inner most (bottom) layer of recursive subarrays. In the
%             'grandparent' example above, the inner most layer contains 4
%             elements: {'child1','child2', 'child3', 'child4'}.
%               (default = no column headers are printed)
%
%      rows - Cell array of row label strings, which must contain exactly n
%             elements. Alternatively, scalar logical (false) or empty sets
%             [] and {} indicate to not print row labels. However, these
%             are superceded when 'cols' contains m+1 elements, triggering
%             default row labels: '1', '2', etc. Default row labels can
%             also be selected by passing scalar logical (true), even when
%             'cols' contains just m elements.
%               (default = no row labels are printed)
%
%     title - A string that is printed atop the table.
%               (default = no title is printed)
%
%       fmt - A string, function handle, or cell array of strings or
%             function handles specifying the numerical format of the data.
%             If a string, must be a valid format specifier as used
%             by MATLAB's sprintf() function. If a function handle to a
%             custom function, the function must take a single numeric
%             arguement and return a string. If a scalar, the format will
%             be applied to all data. If a cell array, must contain exactly
%             m elements, where each element specifies the format of the
%             corresponding column.
%               (default = '%.2f' across all columns)
%
%     delim - Positive integer or string specifying the delimiter between
%             columns. If a string, the string will be used as a literal.
%             If an integer, specifies the number of white spaces between
%             rows. Suitable string examples are '\t' and ',' .
%               (default = 5)
%
%     nline - The newline character.
%               
%   spacing - A Boolean specifying whether to add spacing between columns.
%             (true) indicates that you want equal spacing between columns.
%             This will give the table a tidy appearance in the MATLAB
%             Command Window, or any text editors you past the text into
%             (e.g., Notepad in Windows). However, this is not suitable for
%             printing to a delimited data file, as it adds extra white
%             space as padding. To remove spacing, specify (false). (See
%             EXAMPLES.)
%               (default = (true) )
%
%      just - Either the character '-' or '+' indicating whether to left or
%             right justify the columns (respectively).
%               (default = left justified: '-')
%
%
% OPTIONAL OUTPUT
%   str - The table returned as a string. If no return argument is
%         specified, the string is printed to the MATLAB Command Window
%         instead (see EXAMPLES).
%
%
% EXAMPLES:
%   1) Print the data to the MATLAB Command Window:
%   printtable(mat,'delim','\t','spacing',1);
%
%   2) Write a tab delimited table directly to file:
%   fid = fopen('data.txt');
%   fprintf(printtable(mat,'delim','\t','spacing',0));
%
%
%
%   DHK - Sept. 20, 2022

%   Wish list: Multirows

%% Process input
p = inputParser;
addOptional(p,'cols',[]); % Cell array of column names
addOptional(p,'rows',[]); % Cell array of row names; or true (print numbers) or false (do not include this column)
addOptional(p,'title',[]); % Title string
addOptional(p,'fmt','%.2f'); % Format operator for numerical format of data
addOptional(p,'delim',5); % Value specifying delimiter; characters are used as literals. Integers specify number of spaces.
addOptional(p,'nline',newline); % Valye specifying newline character. Used as literals.
addOptional(p,'spacing',1); % Value specifying whether to add spaces to align columns
addOptional(p,'just','-'); % Value specifying whether to right or left justify columns
parse(p,varargin{:});
p = p.Results;

% Set/protect against empty values
if numel(size(mat))~=2, error('Argument ''mat'' must be a 2-dimensional matrix.'); end
if isempty(p.cols), p.cols = {}; end % Make sure it's an empty cell array
if isempty(p.rows), p.rows = {}; end % Make sure it's an empty cell array
if isempty(p.fmt); p.fmt = '%.2f'; end
if isempty(p.delim); p.delim = 5; end
if isempty(p.nline); p.nline = newline; end
if isempty(p.spacing); p.spacing = true; end
if isempty(p.just); p.just = '+'; end

%% Error checking
% cols
if ~isempty(p.cols) && ~iscell(p.cols)
    error('Optional argument ''cols'' must be a cell array.');
end
hdr = buildHeader(p.cols,size(mat,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rows
prows = false; % Default to false
if isscalar(p.rows) && (islogical(p.rows) || isnumeric(p.rows)) % It's a logical scalar
    prows = logical(p.rows);
    p.rows = {};
end
if ~isempty(p.rows) && ~iscell(p.rows) % It's not a cell
    error('Optional argument ''rows'' must be a cell array or logical scalar.');
end
if ~isempty(p.rows) && iscell(p.rows) % It's a non-empty cell
    if numel(p.rows) ~= size(mat,1) % It does not contain the correct number of indices
        error('Optional argument ''rows'' as cell array must contain the same number of elements as there are rows in argument ''mat''.');
    end
    for i = 1:numel(p.rows)
        if ~ischar(p.rows{i}) % It contains a non-string element
             error('Optional argument ''rows'' as cell array must contain strings in every element.');
        end
    end
    prows = true; % Passed error checks. Set printing to (true).
end
if size(hdr,2) == size(mat,2)+1 % A string for the row label column was provided
    prows = true;
end
if isempty(p.rows) && prows % Print default row numbers
    p.rows = cellstr(num2str((1:size(mat,1))')); % Use row numbers
end
if isempty(p.rows), p.rows = {0}; end % Necessary for computing 'c' below
if prows && size(hdr,2) == size(mat,2) % Printing row labels, but row label string was not provided in 'cols'
    hdr = [cell(size(hdr,1),1),hdr];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% title
if ~isempty(p.title) && ~ischar(p.title), error('Optional argument ''title'' must be a string.'); end

% delim
if isnumeric(p.delim) && isscalar(p.delim), p.delim = repmat(char(32),1,p.delim);
elseif ischar(p.delim), p.delim = sprintf(p.delim); % convert '\t' to char(9); leave comma as char(44)
else, error('Optional argument ''delim'' must be either a positive integer or a string.');
end

% nline
if ~ischar(p.nline), error('Optional argument ''nline'' must be a string.'); end
p.nline = sprintf('%s',safe(p.nline));

% fmt
if iscell(p.fmt)
    if numel(p.fmt)~=size(mat,2)
        error('If optional argument ''fmt'' is a cell array, it must be of equal length to the number of columns in data matrix.');
    end
elseif ischar(p.fmt) || isa(p.fmt,'function_handle'), p.fmt = repmat({p.fmt},1,size(mat,2));
else, error('Optional argument ''fmt'' must be either a cell array, a string, or a function handle.');
end
w = warning; warning('off','all'); % Turn off warnings for this test
for i = 1:numel(p.fmt)
    if isa(p.fmt{i},'function_handle')
        if ~ischar(p.fmt{i}(1))
            error('Function handles passed to optiona argument ''fmt'' must return a string');
        end
    elseif contains(p.fmt{i},{'$','*','\a','\b','\f','\n','\r','\t','\v'})
        error(['Unsupported character in optional argument ''fmt'': fmt{%d} = %s\n',...
            '\tUnsupported charaters are ',...
            '{''$'', ''*'', ''\\a'', ''\\b'', ''\\f'', ''\\n'', ''\\r'', ''\\t'', ''\\v''}'],...
            i,p.fmt{i});
    else
        [~,err]=sprintf(p.fmt{i},1);
        if ~isempty(err)
            error('Bad format specifier passed to Optional argument''fmt''. See MATLAB help article on ''Formating Text''.');
        end
    end
end
warning(w); % Resume original warning state
clear w;

% spacing
try p.spacing = logical(p.spacing);
    if ~isscalar(p.spacing), error(''); end
catch; error('Optional argument ''spacing'' must be a logical scalar.');
end
w = nan(1,numel(p.fmt)); % Find the maximum width of each column
for j = 1:numel(p.fmt)
    for i = 1:size(mat,1)
        if isa(p.fmt{j},'function_handle')
            w(j) =  max([w(j),size(fmt(p.fmt{j},mat(i,j)),2)]);
        else, w(j) = max([w(j),size(num2str(mat(i,j),p.fmt{j}),2)]);
        end
    end
end
if p.spacing
    c = max([max(cellfun(@(x)numel(safe(x,0)),hdr(:))),...
        max(cellfun(@numel,p.rows))]); % Find minimum column width
    c = max([c,w]);
else, c = 0;
end

% justify
if ~any(strcmp(p.just,{'+','-'}))
    error('Optional argument ''just'' must be either ''+'' or ''-''.');
end
if p.just == '+', w(:) = 0; end

%% Format/collate table text

% Print title
if isempty(p.title), str = '';
else, str = ['<strong>Table.</strong> ',p.title(:)',p.nline];
end

% Format horizontal line separating rows
if p.spacing
    n = c*size(mat,2) + c*prows +... 
        (size(mat,2)-1*~prows)*~strcmp(p.delim,char(9))*numel(p.delim) +... % not char(9) tab
        (size(mat,2)-1*~prows)* strcmp(p.delim,char(9))*abs((mod(c,4))-4);  %  is char(9) tab
    line = repmat(char(95),1,n); % another option is char(8212) = em-dash (—), but the spacing needs to be adjusted...
end

% Print first horizontal line
if p.spacing, str = [str,line,p.nline];
end

% Print headers
for i = 1:size(hdr,1)
    if p.spacing, rep = true(size(line)); end
    for j =1:size(hdr,2)
        if isempty(hdr{i,j}) || (j>1 && strcmp(hdr{i,j},hdr{i,j-1}))
            str = [str,sprintf(['%',p.just,'s'],repmat(char(32),1,c))]; %#ok Empty space
            if j>1 && strcmp(hdr{i,j},hdr{i,j-1})
                rep( (j-2)*(c+numel(sprintf('%s',p.delim)))+1 :...
                    j*(c+numel(sprintf('%s',p.delim)))-1 ...
                    ) = false;
            end
        else
            str = [str,'<strong>',sprintf(['%',p.just,num2str(c),'s'],hdr{i,j}),'</strong>']; %#ok
        end
        if j<size(hdr,2), str = [str,sprintf(['%',p.just,'s'],p.delim)]; end %#ok      
    end
    if p.spacing && ~(all(rep))
        tline = line; tline(rep) = ' ';
        str = [str,p.nline,tline]; %#ok
    end
    str = [str,p.nline]; %#ok
end

% Print horizontal line separating headers and data
if p.spacing, str = [str,line,p.nline]; end

% Print data
for i = 1:size(mat,1)
    if prows, str = [str,sprintf(['%',p.just,num2str(c),'s%',p.just,'s'],p.rows{i},p.delim)]; end %#ok
    for j = 1:size(mat,2)
        if j>1, str = [str,sprintf(['%',p.just,'s'],p.delim)]; end %#ok
        str = [str,sprintf(['%',p.just,num2str(c),'s'],...
            sprintf(['%',num2str(w(j)),'s'],fmt(p.fmt{j},mat(i,j))))]; %#ok
    end
    str = [str,p.nline]; %#ok
end

% Print last horizontal line
if p.spacing, str = [str,line,'\n']; end

%% Print or return string?
if nargout==1
    varargout{1} = str;
else
    fprintf(str);
end
%% Utilities
function hdr = buildHeader(cll,c)
[nc,nr] = getDim(cll); % Preallocate size

if ~isempty(cll) && nc~=c && nc~=c+1 % Check that the correct number of column labels is specified
    error(['Optional argument ''cols'' must specify an equal number of column labels as there are columns in argument ''mat''.',...
        'You can provide one extra column label (always the first element) to label the row names.']);
end
hdr = fillCell(cell(nr,nc),cll,1); % Fill the header cell array

function [nc,nr] = getDim(cll,nc,nr,ri)
% Cell array must be organized like a tree for recursive traversal. Will
% perform data formatting checks here and send the errors back up.
%
% INPUT
%   cll - 1D cell array of header labels with recursive (tree) format
%    ri - Current depth in 'cll' tree
% INPUT/OUTPUT
%    nc - Number of columns
%    nr - Number of rows

% Recursive calls must include these arguments. Outside callers can omit them.
if nargin==1
    nc = 0; % Total number of columns
    nr = 0; % Total number of rows
    ri = 1; % Current row
end

% Throw an error if a non-1D cell array was passed
if numel(size(cll))>2 || all(size(cll)>1)
    error('Optional argument ''cols'' must be a 1 dimensional cell array. All subarrays must also be 1 dimensional.');
end

% Update max tree depth
nr = max([nr,ri]);

% Terminating condition
if all(cellfun(@ischar,cll)) % Cell only contains strings
    nc=nc+numel(cll);
    return;
end
% else, 'cll' contains subarrays
% Traverse through 'cll' and recursively step into sub-arrays
for i = 1:numel(cll)
    if iscell(cll{i}) % Recursive step
        % Give extremely detailed error message if strict format is violated
        if ~(numel(cll{i})==2 && ischar(cll{i}{1}) && iscell(cll{i}{2}))
            error(sprintf(['Subarrays in optional argument ''cols'' must contain exactly 2 elements. ',...
                'The first element is a string labelling the parent-category. ',...
                'The second element is a cell array of strings labelling the child-categories:\n',...
                '{''parent'',{''child1'',''child2''}}\n',...
                'It is also possible to recursively stack these parent-child subarrays:\n',...
                '{''grandparent'',...\n\t{...\n\t\t{''parent1'',{''child1'',''child2''}}, ',...
                '{''parent2'',{''child3'',''child4''}}...\n\t}\n}']));
        end
        [nc,nr] = getDim(cll{i}{2},nc,nr,ri+1); % Add 1 to tree depth (nr) upon stepping in
    elseif ischar(cll{i}) % New column label
        nc = nc+1;
    else % Bad format
        error('Optional argument ''cols'' must only contain elements that are either strings or cell sub-arrays grouped to specify categorical hierarchy');
    end
end

function [hdr,nc] = fillCell(hdr,cll,nc)
% Recurse back through tree to fill a grid representation of the header

nr = size(hdr,1); % Current row (have to work bottom-to-top)

% Traverse through 'cll' and recursively step into sub-arrays
for i = 1:numel(cll)
    if iscell(cll{i}) % Recursive step
        [c,r] = getDim(cll{i}{2}); % Get dimensions of this subarray
        for j = 0:c-1 % Add the parent to child columns in the respective parent row
            hdr{nr-r,nc+j} = safe(cll{i}{1});
        end
        [hdr,nc] = fillCell(hdr,cll{i}{2},nc); 
    elseif ischar(cll{i}) % New column label
        hdr{nr,nc} = safe(cll{i});
        nc = nc+1;
    end
end

function str = safe(str,mode)
% Ensure strings are interpreted literally and not altered by escape
% characters '\' and '%'.
%
% INPUT:
%   str - Any string.
%
% OPTIONAL INPUT:
%   mode - Either true or false.
%
% OUTPUT:
%   str - Safe (mode==1) or unsafe (mode==0) string.
if isempty(str); return; end
if nargin<2, mode=1; end
if ~isscalar(mode), error('Optional argument ''mode'' must be a logical scalar'); end
if mode, str = strrep(strrep(strrep(str,'\n',newline),'\','\\'),'%','%%');
else, str = strrep(strrep(strrep(str,'%%','%'),'\\','\'),newline,'\\n');
end

function str = fmt(f,d)
% Allow either ANSI-C escape sequence string formatters or custom functions
% passed with handles to format the text in each column. This function is
% only called during construction of table text, meaning the formatter has
% already passed rigorous error checking.
%
% INPUT:
%   f - A formatter. Either an ANSI-C escape sequence (e.g., '%.3f') or a
%       custom function passed as a handle.
%   d - The numeric data being formatted.
%
% OUTPUT:
%   str - A formatted string.
if ischar(f)
    str = sprintf(f,d);
elseif isa(f,'function_handle')
    str = f(d);
end