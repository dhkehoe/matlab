function varargout = hist2sq(x,y,z,varargin)
% Plot a 2D histogram with rectangular bins, as opposed to points. The list
% of arguments replicates those that are passed to MATLAB's surf()
% function. 'x', 'y', and 'z' must be equally-sized, 2D matrices. Optional
% arguments specify formatting parameters passed directly to surf().
%  
% USAGE
%   hist2sq(x,y,z);
%   h = hist2sq(x,y,z);
%   h = hist2sq(x,y,z, 'OptionalArgName',OptionalArgValue, ...);
%
%  INPUT
%   x - An N by M matrix of x domain values.
%   y - An N by M matrix of y domain values.
%   z - An N by M matrix of z function values.
%
% OPTIONAL INPUT
%   see documentation for surf()
%
% OPTIONAL OUTPUT
%   h - handle to the surf() object.
%
% EXAMPLE 1
%   [z,d] = hist3(mydata);
%   [x,y] = meshgrid(d{1},d{2});
%   hist2sq(x,y,z);
%
% EXAMPLE 2
%   [z,x,y] = kde2(mydata);
%   hist2sq(x,y,z);
%
%
%
%   dhk - January 29, 2025


% Ensure 'x', 'y', and 'z' are equally-sized matrices
[b,s] = eqsize(x,y);
if ~(b && eqsize(y,z))
    error('''x'', ''y'', and ''z'' must be equally-sized matrices.');
end
if 2<numel(s)
    error('''x'', ''y'', and ''z'' must be 2-dimensional matrices.');
end

%% Transform x

% Replicate the columns/rows of x, adjust to lower/upper bound of each
% rectangle
dx = diff(x(1,:))/2;
x = repcolrow(x) + reshape([ -[dx(1), dx]; [dx,dx(end)] ],1, s(2)*2);

% Pad with zeros to close the boundary rectangles
x = [x(:,1),x,x(:,end)];
x = [x(1,:);x;x(end,:)];

%% Transform y

% Replicate the columns/rows of y, adjust to lower/upper bound of each
% rectangle
dy = diff(y(:,1))'/2;
y = repcolrow(y) + reshape([ -[dy(1), dy]; [dy,dy(end)] ], s(1)*2, 1);

% Pad with zeros to close the boundary rectangles
y = [y(:,1),y,y(:,end)];
y = [y(1,:);y;y(end,:)];

%% Transform z

% Replicate the columns/rows of y, adjust to lower/upper bound of each
% rectangle
z = repcolrow(z);

% Pad with zeros to close the boundary rectangles
z = [zeros(size(z,1),1),z,zeros(size(z,1),1)];
z = [zeros(1,size(z,2));z;zeros(1,size(z,2))];

%% Plot

% Catch any optional argument errors thrown by surf() and rethrow them from here
try
    h = surf(x,y,z,varargin{:});
catch err
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end

% Rectangles should have the same color for all visible edges; by default, 
% the edges will be colored by the order in which they appear along the
% domain, which looks awful
for i = 2:size(z,1)
    j = h.CData(i-1,:) < h.CData(i,:);
    h.CData(i-1,j) = h.CData(i,j);
end
for i = 2:size(z,2)
    j = h.CData(:,i-1) < h.CData(:,i);
    h.CData(j,i-1) = h.CData(j,i);
end

% Return plot handle, optionally
if nargout
    varargout{1} = h;
end