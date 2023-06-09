function dist = circdist(theta)
% Utility for computing circular distance between 2 angles. This distance
% is bounded on [0,pi]
dist = [nan; abs(theta(2:end)-theta(1:end-1))];
dist( dist>pi ) = 2*pi - dist( dist>pi );