function b = isaxes(h)
try
    b = strcmp(get(h, 'type'), 'axes');
catch
    b = false;
end