function [targOrig, targRect, scale] = parsescrn(n,varargin)
% Exhaustively parse a display into 'n' sections and return the (x,y)
% screen coordinates according to the PsychToolbox 'rect' convention: pixel
% (0,0) cooresponds to the top-left pixel and pixel (n,m) corresponds to
% the bottom-right pixel on a display with n by m resolution. The number of
% columns and rows can be specified or, when omitted, are optimized to fit
% the monitor's aspect ratio given the number of sections (n). Optional
% arguments may be specified using the MATLAB name-pair convention.
%
% USAGE
%   targOrig = scrcoord(n);
%   [targOrig, targRect, scale] = scrcoord(n);
%   [targOrig, targRect, scale] = scrcoord(n,'OptionalArgName',OptionalArgValue,...);
%
% INPUT
%      n - The number of screen positions to parse the display into.
%
% OPTIONAL INPUT
%   rect - The subsection of the display to parse.
%               (default = [0,0,1920,1080]; i.e., the full display,
%                assuming an HD monitor)
%   ncol - The number of columns to parse the display into. If empty while
%          'nrow' is provided, then ncol = ceil(n/nrow). If both 'ncol' and
%          'row' are empty, then they are optimized to maximize screen
%          coverage given the current monitor aspect ratio.
%               (default = [])
%   nrow - The number of rows to parse the display into. If empty while
%          'ncol' is provided, then nrow = ceil(n/ncol). If both 'ncol' and
%          'row' are empty, then they are optimized to maximize screen
%          coverage given the current monitor aspect ratio.
%               (default = [])
%   type - An integer code specifying the stimulus configuration:
%           1: Square grid with stimuli aligned into columns/rows.
%           2: Honeycomb configuration with stimuli all equidistant to
%              their nearest neighbor.
%                (default = 1)
%   plot - Show a plot of the parsed display (true/false)?
%                (default = false)
%   scrn - Only used when (plot==true). The monitor resolution as distinct
%          from 'rect', which is the subsection of the monitor to parse.
%                (default = [0,0,1920,1080], i.e., an HD monitor)
%
% OUTPUT
%   targOrig - N by 2 matrix. The (x,y) center of each parsed screen
%              position.
%   targRect - N by 4 matrix. The (x1,y1,x2,y2) PsychToolbox 'rect'
%              coordinates of each parsed screen position; i.e., the
%              top-left/bottom-right pixel positions of a bounding box that
%              encompasses each parsed screen position.
%      scale - Scalar. The width and height of the bounding boxes that
%              encompass all parsed screen positions.
%
%
%   DHK - Oct. 13, 2023

%% Valiate input
p = inputParser;
addParameter(p,'rect', [0,0,1920,1080], @isnumeric);
addParameter(p,'ncol', [],              @(x)numel(x)==1&isnumeric(x));
addParameter(p,'nrow', [],              @(x)numel(x)==1&isnumeric(x));
addParameter(p,'type', 1,               @(x)numel(x)==1&isnumeric(x));
addParameter(p,'plot', false,           @(x)numel(x)==1&islogical(logical(x)));
addParameter(p,'scrn', [0,0,1920,1080], @isnumeric);
parse(p,varargin{:});
p = p.Results;

% Validate 'type' argument
if p.type < 1 || 2 < p.type
    error('Optional argument ''type'' must be either 1 (grid) or 2 (honeycomb).');
end

% Set default rect container
rect = p.rect(:)';
switch numel(p.rect)
    case 4
    case 2
        rect = [0, 0, p.rect];
    case 1
        rect = [0, 0, p.rect, p.rect];
    case 0
        rect = [0, 0, 1920, 1080];
    otherwise
        error('Bad format for optional argument ''rect''.')
end

% Compute some useful variables
wh = rect(3:4)-rect(1:2); % [width, height]
ar = wh(1)/wh(2); % aspect ratio

% Set default number of columns
if isempty(p.ncol) && isempty(p.nrow) % No column/row information given

    % Find best-fitting number of columns/rows given screen aspect ratio
    switch p.type
        case 1 % Grid
            lfun = @(x) abs( n./x^2 - ar ) +... closest matching aspect ratio
                any(rem(n,round(x)))*1e0;     % penalty if not square

        case 2 % Honeycomb
            lfun = @(x)...
                abs( (n/x+mod(n,round(x))/2)./(x*sin(pi/3)) - ar ) +... closest matching aspect ratio
                any(rem(n,round(x)))*2e0;                % penalty if not square
    end
    p.nrow = round(fminsearch( lfun,... provide loss function
        ceil( sqrt(n) / ar ),...        initial guess
        optimset('display','off')...    set options
        ));                             % number of rows
    p.ncol = ceil(n/p.nrow);

elseif isempty(p.ncol) % Number of columns empty, number of rows provided
    p.ncol = ceil(n/p.nrow);

elseif isempty(p.nrow) % Number of columns provided, number of rows empty
    p.nrow = ceil(n/p.ncol);

end % else, Number of columns provided, number of rows provided
ncr = [p.ncol, p.nrow]; % Number of [columns, rows]

%% Compute positions
switch p.type
    case 1 % Grid

        % Compute scaling factor
        scale = min(floor(wh./ncr));

        % Compute origins
        targOrig = [...
            reshape(repmat( (0:ncr(1)-1)*scale+scale/2, ncr(2), 1      ),[],1)...
            reshape(repmat( (0:ncr(2)-1)*scale+scale/2, 1,      ncr(1) ),[],1)...
            ];
        targOrig = targOrig(1:n,:);
        
        % Center the display within 'rect'
        targOrig = targOrig + rect(1:2) + ( wh-max(targOrig+scale/2) )/2;
        
    case 2 % Honeycomb

        % Compute scaling factor
        scale = min( wh ./ ( ncr.*[1,sin(pi/3)]+[.5,0]*(mod(n,p.nrow)~=1) ) );
        
        % Compute origins
        targOrig = [...
            reshape( repmat( (0:ncr(1)-1),ncr(2),1 ) + repmatr( [0;1],ncr(2)/2,1 )/2, [],1)...
            reshape( repmat( (0:ncr(2)-1)*sin(pi/3),1,ncr(1) ), [],1)...
            ] * scale;
        targOrig = targOrig(1:n,:);
        
        % Center the display within 'rect'
        targOrig = targOrig + rect(1:2) + ( wh-max(targOrig+scale) )/2 + scale/2;
end

% Covert to origins to rect coordinates
targRect = repmat(targOrig,1,2) + [-1,-1,1,1]*scale/2;

%% Plot the display if requested
if p.plot

    % Set default rect container
    scrn = p.scrn(:)';
    switch numel(p.rect)
        case 4
        case 2
            scrn = [0, 0, p.scrn];
        case 1
            scrn = [0, 0, p.scrn, p.scrn];
        case 0
            scrn = [0, 0, 1920, 1080];
        otherwise
            error('Bad format for optional argument ''scrn''.')
    end

    % Plot each location
    t = 0:.01:2.1*pi;
    figure; hold on; title(['n = ',num2str(n),', AR = ',num2str(ncr(1)/ncr(2))]);
    for i = 1:n
        text(targOrig(i,1),targOrig(i,2),num2str(i),'FontSize',12,...
            'HorizontalAlignment','center','VerticalAlignment','middle');
        plot(...
            [targRect(i,1),targRect(i,1),targRect(i,3),targRect(i,3),targRect(i,1)],...
            [targRect(i,2),targRect(i,4),targRect(i,4),targRect(i,2),targRect(i,2)],...
            'k-');
        plot(cos(t)*scale/2+targOrig(i,1),sin(t)*scale/2+targOrig(i,2),'k:');
    end
    plot( [rect(1),rect(1),rect(3),rect(3),rect(1)], [rect(2),rect(4),rect(4),rect(2),rect(2)], 'k--');
    daspect([1,1,1]);
    xlim(scrn([1,3]));
    ylim(scrn([2,4]));
    set(gca, 'YDir','reverse');
end