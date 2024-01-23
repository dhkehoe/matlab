function s = mbitor(v,dim)
% Matrix-based bitor. Computes a cumulative bitor over the matrix in 'v'
% along the dimension 'dim'.

if nargin<2
    dim = 1;
    if isvector(v)
        v = v(:);
    end
end

s = collapsedim(v,dim,@mbitor_);

%%
function s = mbitor_(v)
s = v(1);
for i = 2:numel(v)
    s = bitor(s,v(i));
end