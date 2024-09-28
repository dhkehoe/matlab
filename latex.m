function varargout = latex(on)
% Set the default text interpeter to latex or tex. Tex is the default in
% MATLAB. When the default is set to latex, this means every text object, 
% axis label, tick label, etc. will be rendered with the latex interpreter
% so you won't ever need to use
%   set(exampleGraphicsHandle,'Interpreter','latex');
%
% USAGE
%   latex; % Default to latex interpreter
%   latex(1); Default to latex interpreter
%   latex(0); % Default to tex interpreter
%   status = latex; % Get interpreter status; does not alter default
%
% OPTIONAL INPUT
%       on - Logical scalar indicating whether to set the default
%            interpreter to latex (true) or tex (false).
%               (default = true)
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

% Set some default behaviors
if nargin<1
    on = true; % Default to latex (true), if no args
end

% Set all text interpreters to latex (true) or tex (false)
opt = {'tex','latex'}; % Interpreter options
arg = reshape([strrep(p,'factory','Default'),repmat(opt(logical(on)+1),size(p))]',[],1);
set(groot,arg{:});