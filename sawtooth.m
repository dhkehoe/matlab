function y = sawtooth(x,freq,phase,alpha,delta)
% Sawtooth wave with parameters for frequency, phase, alpha (amplitude),
% and delta (floor).
%
%
%   DHK - June 06, 2025

%% Manage input
if nargin<2 || isempty(freq)
    freq = 1;
end
if nargin<3 || isempty(phase)
    phase = 0;
else
    phase = mod(phase,freq);
end
if nargin<4 || isempty(alpha)
    alpha = 1;
end
if nargin<5 || isempty(delta)
    delta = 0;
end

%% Compute function
x = x-phase;
y = ( x./freq-floor(x./freq) ) .* (alpha-delta) + delta;