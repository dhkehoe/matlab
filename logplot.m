function varargout = logplot(x,y,varargin)
% Plot 'x' and 'y' with the axes rescaled to the logarithm of an arbitrary
% base. The 'x' and 'y' components can be independently rescaled by setting
% the 'XBase' and 'YBase' optional arguments. Otherwise, this function
% wraps the MATLAB function plot() and behaves identically: it accepts an
% identical argument list as plot() and optionally returns a handle to a
% Line object.
%
% USAGE
%   logplot(y);
%   logplot(x,y);
%   h = logplot(x,y);
%   h = logplot(x,y, 'optionalArgName',optionalArgValue, ... );
%
%
%
%   DHK - Feb 26, 2025

% Check whether 'x' was omitted
xflag = false;
if nargin<2
    % Only a single argument
    xflag = true;
elseif ischar(y)
    % If 'y' is a string, it's a property name belonging to varargin
    varargin = [y, varargin];
    xflag = true;
elseif numel(x) ~= size(y,2)
    % 'x' was provided, but the size is mismatched with matrix 'y'
    error('''x'' must contain as many elements as columns in ''y''.');
end

% Create 'x'
if xflag
    y = x;
    x = 1:size(y,2);
else % Ensure x is a row vector
    x = reshape(x,1,numel(x));
end

% Retrieve optional arguments that cannot be passed to plot()
try
    fun = @(x)isempty(x)||isnumeric(x)&&isscalar(x)&&1<x;
    [varargin, bx] = inputChecker(varargin,'xbase',[], fun, 'Optional argument ''XBase'' must be a numeric scalar greater than 1.');
    [varargin, by] = inputChecker(varargin,'ybase',[], fun, 'Optional argument ''YBase'' must be a numeric scalar greater than 1.');

    % Check that any additional arguments are valid when passed directly to
    % plot()
    plot(nan,nan,varargin{:});
catch err
    % Rethrow the error from within this function instead of plot()
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end

% Set defaults
if isempty(bx)
    lx = @(x)x;
else
    lx = @(x)logn(x,bx);
end
if isempty(by)
    ly = @(y)y;
else
    ly = @(y)logn(y,by);
end

%% Plot
h = plot(lx(x),ly(y),varargin{:});
setTicksAndLabels('x',bx,lx);
setTicksAndLabels('y',by,ly);

% Return handle
if nargout
    varargout{1} = h;
end

%% Set ticks and labels
function setTicksAndLabels(com,b,lf)

if ~isempty(b)

    % Get the ticks
    tix = round(get(gca, [com,'Tick']),10);

    % Find the ticks that are some power of the base
    tix = tix(~mod(tix,1));

    % Determine how many ticks to put between integer bases
    ntix = min([max([round(b), 2]), 10])+1;

    % Compute the tick values
    tix = unique(repmat(tix(1:end-1),ntix,1) + repmat( lf(linspace(1,b,ntix)'), 1,numel(tix)-1));

    % Convert base to string
    if b == exp(1) % Special--but predictable--case
        bstr = 'e';
    else
        bstr = num2str(b);
    end

    % Label the ticks
    lab = cell(numel(tix),1);
    for i = 1:numel(tix)
        if mod(tix(i),1)
            lab{i} = '';
        else
            lab{i} = [num2str(bstr),'^{',num2str(tix(i)),'}'];
        end
    end
    set(gca, [com,'Tick'],tix, [com,'TickLabel'],lab);
end