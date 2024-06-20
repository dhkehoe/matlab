function [r2,F,p,sse] = linreg(yhat,y,df)
yhat=yhat(:);
y=y(:);

if nargin < 3 % no df provided --> yhat is actually x and no model has been fit
    yhat = polynom(yhat,polyfit(yhat,y,1)); % assume linear model, fit here
    df = [1, numel(y)-1];
end

sse = sum((yhat-y).^2);
ssr = sum((mean(y)-yhat).^2);
r2 = ssr/(sse+ssr);
F = (ssr/df(1))/(sse/df(2));
p = 1-fcdf(F,df(1),df(2));