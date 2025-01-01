function varargout = printttest(x1,x2,varargin)
if nargin<2
    x2 = [];
end
if ischar(x2)
    varargin = [x2,varargin];
    x2 = [];
end

p = inputParser;
addOptional(p,'print',     [],@isscalar);
addOptional(p,'samples',   [],@isscalar);
addOptional(p,'args', {'tail','both'},@iscell);
parse(p,varargin{:});
p = p.Results;

if isempty(p.print)
    p.print = ~nargout;
end

if isempty(p.samples)
    if isempty(x2)
        p.samples = 1;
    else
        p.samples = 2;
    end
end

%%
switch p.samples
    case 1
        tfun = @ttest;
        if isempty(x2)
            md = nanmean(x1); %#ok
        elseif eqsize(x1,x2)
            md = nanmean(x1-x2); %#ok
        else
            error('The data in a dependent (paired) t-test must be the same size.');
        end
    case 2
        if isempty(x2)
            error('The data in an independent t-test must contain 2 samples.');
        end
        tfun = @ttest2;
        md = nanmean(x1)-nanmean(x2); %#ok
    otherwise
        error('Optional argument ''samples'' must be either 1 (dependent) or 2 (independent).');
end

%%
[~,tp,ci,stats] = tfun(x1,x2,p.args{:});
str = sprintf('t(%d) = %.2f, 95%%CI = [%.2f, %.2f], p %s, d = %.2f, MD = %.2f',...
    stats.df,stats.tstat,ci,pval(tp),abs(md)/stats.sd,md);

%%
if p.print
    fprintf('%s\n',str);
end
if nargout
    varargout{1} = str;
end