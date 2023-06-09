% function roc

%% yes/no
% ht = .846;
% fa = .327; % false alarm 
% dprime = norminv(ht) - norminv(fa);

%% 2AFC
ht = mean([.846,.327]); % hit ratio (response==stimulus) for [A,B]
fa = 1-ht; % false alarm 
dprime = (norminv(ht) - norminv(fa)) / sqrt(2);

%% ROC
d = -3:.01:dprime+3; % decision variable domain
x = normcdf(d,dprime); % integral of HIT distribution for all values of decision variable 
y = normcdf(d); % integral of FA distribution for all values of decision variable
figure; hold on; set(groot,'DefaultAxesTickLabelInterpreter','LaTeX'); % Use latex tick labels
plot(x,y,'k'); % false alarm rate as a function of hit rate
fill([x,1,0],[y,0,0],'k','LineStyle','none','FaceAlpha',.1);
title(sprintf('Area under the curve = %s',strrep(num2str(trapz(x,y),'%.3f'),'0.','.')),...
    'Interpreter','latex'); % area under the curve
xlabel('$P$(Hit)','Interpreter','latex');
ylabel('$P$(FA)','Interpreter','latex');