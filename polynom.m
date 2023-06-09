function y = polynom(x,beta)
n = length(beta);
if n==1, y = beta; return, end
x = x(:);
% y = zeros(size(x));                   % iterative method
% for k = 1:n-1 % for every coefficient %
%     y = y + beta(k)*x.^(n-k);         %
% end                                   %
% y = y + beta(end);                    %
y = beta(1)*x.^(n-1) + polynom(x,beta(2:n)); % recursive method