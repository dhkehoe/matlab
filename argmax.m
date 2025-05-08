function w = argmax(x,fnd,varargin)
if nargin<2 || isempty(fnd)
    fnd = true;
end
w = x == max(x,varargin{:});
if fnd
    w = find(w);
end