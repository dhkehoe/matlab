function forcefs(fs,han)
% Force the font size to be 'fs' for all Children/Properties of the handle
% 'han'. This is necessary because MATLAB surreptitiously resizes font
% sizes for certain plot components (e.g., axes labels).
%
% This function recurses through the entire object tree of 'han', so this
% function could be utilized for a single axes object or a figure handle
% interchangably. 'han' can also be a cell array of handles.
% 
% The default value of 'fs' is (10), consistent with MATLAB.
% The default value of 'han' is the current figure handle (gcf).
%
%
%
%   DHK - May 12, 2025

if nargin<2
    han = gcf;
end
if nargin<1
    fs = 10;
end
if ~iscell(han)
    han = {han};
end


for i = 1:numel(han)

    %% Skip this element if it isn't a handle
    if ~ishandle(han{i})
        continue;
    end

    %% Iterate through children, stepping back in
    obj = get(han{i},'Children');
    for j = 1:numel(obj)
        forcefs(fs,obj(j));
    end

    %% Iterate through properties
    P = properties(han{i});
    for j = 1:numel(P)

        % Skip this element if this is a parent handle
        if strcmp('Parent',P{j})
            continue;
        end

        % Force the FontSize property, if applicable
        if strcmp('FontSize',P{j})
            set(han{i},'FontSize',fs);
        end

        % Step back in if this property has sub-properties
        p = properties(han{i}.(P{j}));
        if ~isempty(p)
            forcefs(fs,p);
        end
    end
end