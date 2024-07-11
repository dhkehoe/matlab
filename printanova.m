function varargout = printanova(a,prnt)

if nargin<2
    prnt = true;
end
if isa(a,'GeneralizedLinearMixedModel')
    a = anova(a);
end

% Delete intercept
a(1,:) = [];

% Find number of fixed effects
n = size(a,1);

% Pull the strings out
str = cell(n,1);
for i = 1:n
    s = a.Term(i);
    str{i} = s{:};
end
clear s;

% Get the buffer size for the strings
bufstr = max( cellfun(@numel,str) + 2*cellfun(@numel,strfind(str,':')) );

% Get the buffer size for DF1
bufdf = size(num2str(a.DF1),2);

% Get the buffer size for F
bufF = size(num2str(round(a.FStat*10^2)),2)+1;

%% Print
strs = cell(n,1);
for i = 1:n
    strs{i} =...
        sprintf(['%',num2str(bufstr),'s: F(%',num2str(bufdf),'d,%d) = %',num2str(bufF),'.2f, p %s'],...
        strrep(str{i},':',[' ',char(0xD7),' ']),...
        a.DF1(i),a.DF2(i),a.FStat(i),pval(a.pValue(i)));
    if prnt
        fprintf('%s\n',strs{i});
    end
end

%%
if nargout
    varargout{1} = strs;
end