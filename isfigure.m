function b = isfigure(h)
try
    b = strcmp(get(h, 'type'), 'figure') && isa(h,'matlab.ui.Figure');
catch
    b = false;
end