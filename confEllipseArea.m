function a = confEllipseArea(x,y,varargin)
% Compute the area 'a' of a bivariate normal confidence ellipse around the
% scatter data in 'x' and 'y' at the confidence level 'ci'.
%
% See confEllipse() for details.
%
%
%   DHK - Dec.27, 2024
try
    [~,~,~,~,~,a] = confEllipse(x,y);
catch err
    % Throw the error from within this function
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end