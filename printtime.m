function varargout = printtime(t)
%% manage input
t = uint64(t(:)); % toc will crash otherwise

%% format time
ft = nan(numel(t),3);
for i = 1:numel(t)
    ft(i,:) = [floor(toc(t(i))/60^2),floor(rem(toc(t(i)),60^2)/60),rem(toc(t(i)),60)];
end
if nargout==1, varargout{1} = ft; return; % return time formatted as [hrs, mins, seconds.milliseconds; ...]
elseif nargout>1, error('only one return argument for ''printtime''');
end
% else, return nothing, print the time

%% print
fprintf('\nTime elasped (h:mm:ss.ms):\n');
if numel(t) > 1, fprintf('['); end
for i =1:numel(t)
    fprintf('%d:%02d:%05.2f',ft(i,:));
    if numel(t) > 1 && i<numel(t), fprintf(', '); end
end
if numel(t) > 1, fprintf(']'); end
fprintf('\n');