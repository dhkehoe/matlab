function [i,x,y,p] = linsegdiff(a,b)
% Find the intersection (x,y) coordinates for lines 'a' and 'b' each
% specified by two points:
%   a = [a_x1, a_y1;  a_x2, a_y2];
%   b = [b_x1, b_y1;  b_x2, b_y2];
%
% Also determine whether the intersection occurs specifically within both
% of these line segments (i==1) or somewhere else outside of these line
% segments (i==0).
%
% When (p==1), the lines are parallel.
% 
% If the lines are parallel and overlapping, (infinitely many
% intersections), both 'x' and 'y' are NaN.
% If the lines are parallel and non-overlapping (zero intersections), both
% 'x' and 'y' are Inf.

xa = -diff(a(:,1)); % x-difference of line a
xb = -diff(b(:,1)); % x-difference of line b
ya = -diff(a(:,2)); % y-difference of line a
yb = -diff(b(:,2)); % y-difference of line b

da = det(a); % determinant of line a
db = det(b); % determinant of line b

d  = ( xa*yb - ya*xb ); % denominator

x = ( da*xb - xa*db ) ./ d; % intersection x-coordinate
y = ( da*yb - ya*db ) ./ d; % intersection y-coordinate

p = ~d;
% If 'd' is zero, the lines ARE parallel
% If 'd' is non-zero, the lines are NOT parallel
if d
    % Determine whether the intersection occcurs within both of these
    % specific line segments
    i = all( sum(abs([a;b]-[x,y])) <= sum(abs([xa,ya;xb,yb])) );
else
    % The lines are parallel and no intersection exists
    i = false;
end