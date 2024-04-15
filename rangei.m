function r = rangei(x,varargin)
% Get the range interval values of (min,max)

x0 = squeeze(min(x,varargin{:}));
x1 = squeeze(max(x,varargin{:}));

if isscalar(x1)
    r = [x0,x1];
else
    s = size(x1);
    if isvector(x1) % vector
        r = cat(find(~(s>1)),x0,x1); % Stack along the size 1 dimension
    else % Matrix
        r = cat(numel(s)+1,x0,x1); % Stack along the next highest dimension
    end
end