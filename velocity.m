function v = velocity(x,y,dt)
% Simple function for computing instantanous velocity for all spatial
% position samples split into 'x' and 'y' components. 'dt' is the sampling
% rate in seconds (i.e., time between samples in seconds). 'dt' is
% optional and can be omitted (defaul = .005, i.e., 2 kHz).
%
% NOTE: You can use this function to find acceleration also such that:
%   v = velocity(x, y, dt);
%   a = velocity(v, zeros(size(v)), dt); % <-- acceleration
%
% or you can find separate x and y velocity components such that:
%   vx = velocity(x, zeros(size(x)), dt);
%   vy = velocity(y, zeros(size(y)), dt);
%
%   DHK - May 5, 2022
if nargin == 2 || isempty(dt), dt = .0005; end % Default sampling rate to 2 kHz
v = [x(:),y(:)];
v = [0; sqrt(sum((v(2:end,:)-v(1:end-1,:)).^2,2))] / dt;