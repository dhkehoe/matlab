function c = vec2str(x,varargin)
% Convert the elements of 'x' into an equally-sized cell array of strings.
c = reshape(cellstr(num2str(x(:),varargin{:})),size(x));