function c = dirs(d)
% Returns a list of subfolder names for directory 'd'.
if nargin<1 || isempty(d)
    d = pwd;
end
c = dir(d);
c = { c( [c(:).isdir] ).name};
c(contains(c,'.')) = [];