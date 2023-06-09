function s = pval(p,type)
if nargin < 2, type = 1; end
if type == 1
    if p < .001, s = '< .001';
    elseif p < 1
        s = ['= ',strrep(sprintf('%.3f',p),'0.','.')];
    else, s = '= 1';
    end
elseif type == 2
    if p < .001, s = '***';
    elseif p < .01, s = '**';
    elseif p < .05, s = '*';
    else, s = '';
    end
else, error('unsupported ''type'' arg. must be 1 (text formatted string) or 2 (asterisks)');
end