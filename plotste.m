function h = plotste(x,y,varargin)
% 
%
% USAGE
%   h = plotste(y);
%   h = plotste(x, y);
%   h = plotste(y, 'OptionalArgName',optionalArgValue, ...);
%   h = plotste(x, y, 'OptionalArgName',optionalArgValue, ...);
%
% INPUT
%   y - 
%
% OPTIONAL INPUT
%               x -
%   whiskerlength -
%            line - 
%            type - 
%         weights - 
%
% OUTPUT
%   h - 
%
%
%   DHK - June 12, 2024

%% Manage input

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

% Retrive optional arguments that cannot be passed to plot()
[varargin, wl  ] = inputChecker(varargin,'whiskerlength',0, @(x)isnumeric(x)&&isscalar(x),                         'Optional argument ''WhiskerLength'' must be a numeric scalar.');
[varargin, lin ] = inputChecker(varargin,'line',         1, @(x)isnumeric(x)&&isscalar(x),                         'Optional argument ''Line'' must be a numeric scalar.');
[varargin, type] = inputChecker(varargin,'type',    'cont', @(x)ischar(x)&&any(contains(lower(x),{'cont','prop'})),'Optional argument ''Type'' must be a string, with accepted values ''cont'' or ''prop''.');
[varargin, n   ] = inputChecker(varargin,'weights',     [], @(x)isnumeric(x)&&all(size(x)==size(y)),               'Optional argument ''Weights'' must be a matrix with the same shape as ''y''.');
[varargin, ign ] = inputChecker(varargin,'ignoreinf',    0, @(x)isnumeric(x)&&isscalar(x),                         'Optional argument ''IgnoreInf'' must be a logical scalar.');

% Convert 'type' to an integer
type = find(strcmpi(type,{'cont','prop'})); 

% Set additional error checking + default behavior
if type==2 && isempty(n) % Must provide 'n' if data is proportional
    error('When optional argument ''Type'' is ''prop'', optional argument ''Weights'' must be provided.');
end
if ~isempty(n) % If 'weights' arg is provided, 'type' is set to proportional data
    type = 2;
end

%% Compute plotting variables

% Save initial hold state, temporarily turn hold on
ish = ishold;
hold on;

% Compute means and standard errors
switch type
    case 1
        if ign
            i = ~(isinf(y)|isnan(y));
            m = nan(1,size(y,2));
            e = m;
            for j = 1:numel(m)
                m(j) = mean(y(i(:,j),j));
                e(j) = sqrt(  sum( (y(i(:,j),j)-m(j)).^2 ) ./ (sum(i(:,j))-1) ./sum(i(:,j))  );
            end
        else
            m = nanmean(y); %#ok
            e = nanste(y);
        end
    case 2
        if ign
            i = ~(isinf(y)|isnan(y));
            s = sum(i);
            m = nan(1,size(y,2));
            for j = 1:numel(m)
                m(j) = sum(y(i(:,j),j)) ./ s(j);
            end
        else
            s = nansum(n); %#ok
            m = nansum( y.* n ) ./ s; %#ok            
        end
        e = sqrt( m.*(1-m) ./ s );
end
e = m + [-1;1] .* e;

% Compute whiskers
if wl
    w = x + [-1;1] .* wl/2;
end

%% Plot

% Draw means
if lin
    h = plot(x, m, varargin{:});
else
    h = [];
end

% Draw error bars
for i = 1:size(y,2)
    plot([0;0]+x(i), e(:,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color); % Override the marker property, ensure color matches
    if wl
        plot(w(:,i), [0;0]+e(1,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color);
        plot(w(:,i), [0;0]+e(2,i), varargin{:}, 'LineStyle','-','Marker','none','Color',h.Color);
    end
end

%% Restore initial hold state
if ~ish
    hold off;
end

%% Utilities
function [varg, val] = inputChecker(varg,vstr,dval,efun,estr)
% This function works quite similar to addOptional(). It takes a varargin
% argument 'varg' and the name of an optional argument specified as a
% string 'vstr'. It searches varargin for the optional argument and returns
% the value for this optional argument upon exiting the function. The value
% is assumed to be the subsequent element of varargin after the specifer.
% The specifier and subsequent value from varargin are trimmed and this
% trimmed varargin is returned upon exiting. Additionally, the value is
% defaulted to 'dval' and subjected to an integrity check 'efun'. 'efun' is
% a handle to an inline function that returns true when the value is
% acceptable. If the value is not acceptable according to 'efun', an error
% is throw. The error string is 'estr'.
val = dval;
for i = 1:numel(varg)
    if i<numel(varg) && ischar(varg{i}) && strcmpi(varg{i},vstr)
        val = varg{i+1};
        if ~efun(val)
            error(estr);
        end
        varg(i:i+1) = [];
        break;
    end
end