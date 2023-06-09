function c = pairwise(n)
% Return all pairwise contrasts between n factors.
if n~=round(n)||n<2, error('Argument ''n'' must be a positive integer >= 2'), end

c = false( ((n-1)*n)/2 ,n);
t = 0;
for i = 0:n-2
    for j = i+1:n-1 % O(n^2)... oh well
        t=t+1;
        c(t,:) = bitand(2^i+2^j,2.^(0:n-1));
    end
end