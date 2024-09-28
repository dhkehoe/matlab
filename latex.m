function varargout = latex(value)
% Set the default text interpeter to latex or tex. Tex is the default in
% MATLAB. When the default is set to latex, this means every text object, 
% axis label, tick label, etc. will be rendered with the latex interpreter
% so you won't ever need to use
%   set(exampleGraphicsHandle,'Interpreter','latex');
%
% It accepts arguments exactly like the MATLAB function hold(). When a
% return value is specified, it behaves exactly like ishold().
%
% USAGE
%   % Default interpreter to latex 
%   latex; 
%   latex on;
%   latex('on');
%   latex("on");
%   latex(1);
%   latex(true);
%
%   % Default interpreter to tex
%   latex off;
%   latex('off');
%   latex("off");
%   latex(0);
%   latex(false);
%
%   % Get interpreter status; do not alter current interpreter
%   status = latex;
%
% OPTIONAL INPUT
%    value - Indicate whether to set the default interpreter to latex or
%            tex. Can be of type
%                  char:     'on' - sets the interpreter to latex
%                           'off' - sets the interpreter to tex
%                string:     "on" - sets the interpreter to latex
%                           "off" - sets the interpreter to tex
%               numeric: non-zero - sets the interpreter to latex
%                            zero - sets the interpreter to tex
%               logical:     true - sets the interpreter to latex
%                           false - sets the interpreter to tex
%            (default = 'on')
%
% OUTPUT
%   status - Logical scalar indicating whether the default interpreter is
%            currently set to latex (true) or tex (false). Whenever this
%            function returns 'status', the call to latex() is treated as
%            query-only and does not alter the default interpreter.
%
%
%   DHK - Sept 27, 2024

% Get a list of all the graphics root (alias "groot") object properties
p = fieldnames(get(groot,'factory'));
p = p(contains(p,'Interpreter'));

% A return value indicates that this is a query
if nargout
    varargout{1} = all(strcmp(get(groot,p),'latex'));
    return; % Do not alter default
end

% Set the default behavior
if nargin<1
    value = 1; % Default to latex (true), if no args
end

% Ensure a valid input; convert to integer
if isnumeric(value) || islogical(value)
    value = logical(value)+1;
else
    value = find(strcmpi(value,{'off','on'}));
    if isempty(value)
        error('Command option must be ''on'' or ''off''.');
    end
end

% Set all text interpreters to latex (true) or tex (false)
opt = {'tex','latex'}; % Interpreter options
arg = reshape([strrep(p,'factory','Default'),repmat(opt(value),size(p))]',[],1);
set(groot,arg{:});