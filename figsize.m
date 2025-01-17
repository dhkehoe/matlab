function figsize(pos)
units = get(gcf,'Units');
try
    set(gcf,'Units','normalized','OuterPosition',pos);
catch err
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end
set(gcf,'Units',units);