function y = triwave(x,f,p,a)
% A triangular waveform on the domain 'x', with frequency 'f', phase 'p',
% and amplitude 'a'.
% 
%   DHK - June 1, 2024
if nargin<4
    a = 1;
end
if nargin<3
    p = 0;
end
if nargin<2
    f = 1;
end
y = a.*4./f.*abs(mod((x-p-f./4),f)-f./2)-a;