function h = shadedline(x,y,e,varargin)

x = x(:)';
y = y(:)';
% e = e(:);

hold on;

varargin0 = {'k','LineStyle','none','Marker','none'};
i = 1; ex = 0;
while i < numel(varargin)
    j = i-ex;
    if any(strcmpi(varargin{j},{...
            'FaceAlpha',...
            'FaceColor',...
            'EdgeAlpha',...
            'EdgeColor',...
            }))

        varargin0 = [varargin0, varargin(j:j+1)]; %#ok
        varargin(j:j+1) = [];

        i=i+1;
        ex = ex+2;
%         keyboard
    end

    i=i+1;
end

% Set default FaceAlpha property
if ~strcmpi('FaceAlpha',varargin0)
    varargin0 = [varargin0, 'FaceAlpha', .1];
end

%%
h = plot(x,y,varargin{:});

% If FaceColor isn't provided, default to whatever color is used for the
% line
if ~strcmpi('FaceColor',varargin0)
    varargin0 = [varargin0, 'FaceColor', h.Color];
end
if size(e,1)==1
    fill([x,fliplr(x)],[y-e,fliplr(y+e)],varargin0{:});
else
    fill([x,fliplr(x)],[e(1,:),fliplr(e(2,:))],varargin0{:});
end
