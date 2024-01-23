function s = mbitand(v,dim)
% Matrix-based bitand. Computes a cumulative bitand over the matrix in 'v'
% along the dimension 'dim'.

if nargin<2
    dim = 1;
    if isvector(v)
        v = v(:);
    end
end

s = collapsedim(v,dim,@mbitand_);

%%
function s = mbitand_(v)
s = v(1);
for i = 2:numel(v)
    s = bitand(s,v(i));
end