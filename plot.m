function varargout = plot(varargin)
% Overload the plot() function so that I can include a line alpha argument,
% which MATLAB desperately needs.
% 
% NOTE: The mere existence of this .m file on your file path will give
% persistent annoying warning messages anytime you save another .m file on
% that path. You can suppress them by creating (or modifying) a file
% specifically called "startup.m" on the same path and adding this line:
%   warning('off', 'MATLAB:dispatcher:nameConflict');

% Add any additional wishlist args here...
[varargin, a] = inputChecker(varargin,'linealpha',[],@(x)isnumeric(x)&&isscalar(x)&&0<=x&&x<=1,...
    'Optional argument ''LineAlpha'' must be a numeric scalar in the interval (0,1).');

% Invoke the MATLAB executable plot()
try
    h = builtin('plot',varargin{:});
catch err
    throwAsCaller(err);
end

% Utilize the line alpha argument
for i = 1:numel(h) * ~isempty(a)
    h(i).Color(4) = a;
end

% Return handle if necessary
if nargout
    varargout = {h};
end