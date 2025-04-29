function figsize(pos,state)
if nargin<2
    state = [];
end
if nargin<1 || isempty(pos)
    pos = get(gcf,'OuterPosition');
end

units = get(gcf,'Units');
try
    set(gcf,'Units','normalized','OuterPosition',pos);
    if ~isempty(state)
        states = {'normal','maximized','minimized','fullscreen'};
        set(gcf,'WindowState',states{find(contains(states,state),1,'first')});
    end
catch err
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end
set(gcf,'Units',units);