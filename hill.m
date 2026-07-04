function y = hill(x,V,K,n)
% Hill function
if nargin<4||isempty(n)
    n = 1;
end
if nargin<3||isempty(K)
    K = 1;
end
if nargin<2||isempty(V)
    V = 1;
end
y = (V.*x.^n)./(K.^n+x.^n);