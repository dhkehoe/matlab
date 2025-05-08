function w = argmin(x,fnd,varargin)
if nargin<2 || isempty(fnd)
    fnd = true;
end
w = x == min(x,varargin{:});
if fnd
    w = find(w);
end