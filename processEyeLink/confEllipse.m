function [ex,ey,varargout] = confEllipse(x,y,varargin)
% Compute a bivariate normal confidence ellipse around the scatter data in
% 'x' and 'y' at the confidence level 'ci'. The polygon is drawn with the
% number of points specified by 'npoints'. Returns seperate x and y
% components of the confidence ellipse polygon (i.e., 'ex' and 'ey'
% respectively). Optional returns include the width, height, rotation
% angle, and area (in that order) of the fitted ellipse. Follows the MATLAB
% argument name/pair convention for optional arguments. 
%
%   USAGE:
%   [ex,ey] = confEllipse(x,y);
%   [ex,ey] = confEllipse(x,y,'OptionalArgName',OptionalArgValue,...);
%   [ex,ey,width,height,theta,area] = confEllipse(x,y,'OptionalArgName',OptionalArgValue,...);
%
%
%   INPUT:
%       'x' - The x component for the bivariate scatter data.
%       'y' - The y component for the bivariate scatter data.
%       
%       NOTE: user must ensure that each element in the 'x' and 'y'
%             components are matched correctly and that 'x' and 'y'
%             therefore contain the same number of elements.
%
%
%   OPTIONAL INPUT:
%            'ci' - The confidence level for the fitted ellipse. Must be a
%                   scalar greater than 0 and less than 1.
%                       default = .95
%       'npoints' - The number of points used to draw the confidence
%                   ellipse as a polygon.
%
%   OUTPUT:
%       'ex' - The x component of the fitted confidence ellipse polygon.
%       'ey' - The y component of the fitted confidence ellipse polygon.
%
%
%   OPTIONAL OUTPUT:
%        'width' - The width of the fitted confidence ellipse.
%       'height' - The height of the fitted confidence ellipse.
%        'theta' - The rotation angle of the fitted confidence ellipse.
%         'area' - The area of the fitted confidence ellipse.
%
%
%   DHK - Jan.19, 2022

%% manage input
ip = inputParser; % parse optional arguments
addOptional(ip,'ci',.95,@(x)numel(x)==1&&isnumeric(x)); % confidence level of ellipse
addOptional(ip,'npoints',100,@(x)numel(x)==1&&isnumeric(x)); % number of points to draw ellipse with
parse(ip,varargin{:});
ip = ip.Results;
if 0>=ip.ci || ip.ci>=1, error('bad confidence level. ''ci'' must be in the interval 0<ci<1 '), end
if ip.npoints < 3, error('bad number of points. ''npoints'' must be greater than 3 '), end
x = x(:); % vectorize data
y = y(:);
x(isnan(x)) = [];
y(isnan(y)) = [];

%% compute ellipse
[evc,evl] = eig(cov(x,y)); % run PCA
evl = evl(eye(2)==1); % get scaling factors
[~,order] = sort(-evl); % order components by greatest to least
theta = atan2( evc(2,order(1)),evc(1,order(1)) ); % get rotation angle
wh = sqrt( chi2inv(ip.ci,2) * evl(order) ); % fit 95% CI
uc = linspace(0,2.01*pi,ip.npoints)'; % unit circle in radians
% xy = [cos(uc)*wh(1), sin(uc)*wh(2)] * [cos(theta) sin(theta); -sin(theta) cos(theta)] + mean([x,y]); % create ellipse
ex = cos(uc)*wh(1)*cos(theta) - sin(uc)*wh(2)*sin(theta) + mean(x);
ey = cos(uc)*wh(1)*sin(theta) + sin(uc)*wh(2)*cos(theta) + mean(y);

%% manage output
if nargout > 2, varargout{1} = wh(1); end
if nargout > 3, varargout{2} = wh(2); end
if nargout > 4, varargout{3} = theta; end
if nargout > 5, varargout{4} = prod(wh)*pi; end