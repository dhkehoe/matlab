function varargout = printtime(t)
%
%
if isa(t,'uint64')
    t = toc(t);
end
t = t(:);
ft = [floor(t/60^2),floor(rem(t,60^2)/60),rem(t,60)];

if nargout==1
    % return time formatted as [hrs, mins, seconds.milliseconds; ...]
    varargout{1} = ft; 
else
    % return nothing, print the time
    fprintf('\nTime elasped (h:mm:ss.ms):\n');
    fprintf('%d:%02d:%05.2f\n',ft');
end