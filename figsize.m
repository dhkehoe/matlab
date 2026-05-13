function figsize(pos,state)
if nargin<2
    state = [];
end
if nargin<1
    pos = [];
end

units = get(gcf,'Units');
try
    if ~isempty(pos)
        set(gcf,'Units','normalized','OuterPosition',pos);
    end
    if ~isempty(state)
        states = {'normal','maximized','minimized','fullscreen'};
        set(gcf,'WindowState',states{find(contains(states,state),1,'first')});
    end
catch err
    throwAsCaller(err);
end
set(gcf,'Units',units);