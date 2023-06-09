function [auc,roc] = emroc(x0,x1,prec)
% Compute  the receiver operator characteristic (ROC) for null (x0) and
% alternative (x1) empirical distributions. Outputs the area under the ROC
% curve (AUC) as 'auc' and the ROC curve as 'roc'. 'auc' is a scalar, while
% 'roc' is a 2 x N matrix, where the top row contains the x-values of the
% ROC curve and the bottom row contains the y-values of the ROC curve. By
% default, the ROC curve is computed using 100 linearly-spaced values
% across the shared domain of x0 and x1 (i.e., N = 100). This precision can
% be changed by passing a value to 'prec'.
%
%   DHK - Nov. 17th, 2021

%% manage input
if nargin<3, prec = 99; 
else, prec = prec-1; % zero gets concatenated to the start of roc curve (see below)
end
x0 = x0(:);
x1 = x1(:);

%% compute roc curve
roc = nan(2,prec); % for plotting roc curve and computing area under curve
x = linspace(min([x0; x1]),max([x0; x1]),prec); % x domain that emcompasses all of x0 and x1
for i = 1:numel(x)
    roc(:,i) = [sum(x1<=x(i)); sum(x0<=x(i))];
end
roc(1,:) = roc(1,:)/numel(x1);
roc(2,:) = roc(2,:)/numel(x0);
roc = [zeros(2,1) roc]; % This is why we take 1 from 'prec'

%% compute area under roc curve
auc = sum( (roc(2,2:end)+roc(2,1:end-1))/2.*(roc(1,2:end)-roc(1,1:end-1)) ); % trapezoid method: (a+b)/2*c