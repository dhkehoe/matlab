function c = vec2cell(x)
% Convert the elements of 'x' into an equally-sized cell array of doubles.
s = size(x);
c = cell(s);
for i = 1:numel(c)
    c{i} = x(i);
end