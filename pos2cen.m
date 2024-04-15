function varargout = pos2cen(pos,xl,yl)
% Compute the [x,y] center of a drawing object (e.g., axes object, text
% object, etc.) from the 4-element position vector that defines the
% position of the object. This vector is structed as
%   [left,bottom,width,height]
% and is passed as the 'Position' argument.
% 
% You can convert this into axis data units for the x or y axes by passing
% the 'xl' or 'yl' arguments (respectively).
%
% Returns either an N by 2 matrix of [x,y] positions or 2 vectors
% containing x and y centers (respectively).
%
% USAGE
%   xy = pos2cen(pos);
%   xy = pos2cen(pos,xl,yl);
%   xy = pos2cen(pos,[],[]);
%   [x,y] = pos2cen(pos);
%
% 
%
%   DHK - Apr. 1, 2024

if nargin<3 || isempty(yl)
    yl = [1,1];
else
    if numel(yl)~=2 || ~issorted(yl)
        error('Argument ''yl'' must be a sorted 2 element vector indicating the ylim of the figure in axis units.');
    end
    yl = reshape(yl,1,2);
end
if nargin<3 || isempty(xl)
    xl = [1,1];
else
    if numel(xl)~=2 || ~issorted(xl)
        error('Argument ''xl'' must be a sorted 2 element vector indicating the ylim of the figure in axis units.');
    end
    xl = reshape(xl,1,2);
end

if numel(pos)==4
    pos = reshape(pos,1,4);
elseif size(pos,2)~=4
    error('Argument ''pos'' must be an N by 4 matrix of positions.');
end


%%
x = mean( [pos(:,1),sum(pos(:,[1,3]),2)].*xl, 2);
y = mean( [pos(:,2),sum(pos(:,[2,4]),2)].*yl, 2);

switch nargout
    case 1
        varargout{1} = [x,y];
    case 2
        varargout{1} = x;
        varargout{2} = y;
end