function c = experm(n)
% Return exhaustive subsets from set with size n.
if mod(n,1)||n<0, error('Argument ''n'' must be a positive integer >= 2'), end

c = bitand(...
    repmat( (0:2^n-1)',1,n ),...
    repmat( 2.^(0:n-1),2^n,1 )...
    ) & 1;