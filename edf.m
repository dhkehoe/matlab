function [p,x] = edf(data,edges,norm)
% Empirical distribution functions:
% Computes some empirical distribution function for a collection of data
% using a specified domain and a specified normalization type. Provides a
% good alternative to histogram(), i.e., it offers the same flexibility 
% without the annoying plot handle creation. 
%
% USAGE
%   
% INPUT
%    data - Matrix of numeric data to be binned. Matrix can have any number
%           of dimensions. NaNs and Infs are ignored.
%   edges - Vector of bin edges. Data in the ith bin is binned such that
%               edges(i) <= data & data < edges(i+1)
%           As such, the number of bins == length(edges)-1. Note that bin
%           edges do not need to be evenly spaced, but do need to be sorted
%           in ascending order.
%
% OPTIONAL INPUT
%    norm - Type of normalization across bins passed as a string:
%                 'pdf' Probability density function (default)
%                'prob' Probability/proportion
%                 'cdf' Cumulative distribution function
%                'freq' Frequency
%               'cfreq' Cumulative frequency
%
% OUTPUT
%       p - Empirical distribution function values with respect to user
%           defined bin edges and normalization.
%       x - Bin centers where the ith bin is the halfway point between 
%           edges(i) and edges(i+1). As such, length(x) == length(edges)-1.
%
%   DHK - March 10, 2021

%% Error checking and preallocation
% Ensure an adequate number of bins edges have been provided
if length(edges)<2, error('At least 2 bin edges required.'), end
% Ensure the bins are sorted in either ascending or decending order
if ~issorted(edges), error('PDF edges must be sorted in ascending order.'), end
if nargin < 3, norm = 'cdf'; end % Default to CDF
t = find(strcmp(norm,{'pdf','prob','cdf','freq','cfreq'})); % Determine type of normalization
if isempty(t), error(['Unrecognized normalization type ''',norm,'''.']), end

% Linearize the data discarding any NaNs or Infs
data = reshape( data( ~(isnan(data)|isinf(data)) ) ,[],1);

% Trim data outside of the range of bin edges to ensure the CDF sums to 1
data(data<edges(1) | data>=edges(end)) = [];

% Preallocate
p = nan(1,length(edges)-1); % P(x) = f(x)
x = p;                      % Domain of x (bin centers)
n = numel(data);            % Number of observations

%% Compute 'p' and 'x'
for i = 1:length(p)
    x(i) = (edges(i+1)+edges(i))/2; % Compute bin centers
    p(i) = sum(data>=edges(i) & data<edges(i+1)); % Compute frequencies
    if t == 1 % PDF needs the following adjustment
        p(i) = p(i) / (edges(i+1)-edges(i));
    end
end

% If this is a cumulative function (CDF or cumulative frequency)
if t == 3 || t == 5, p = cumsum(p); end

% If necessary, normalize
if t < 4 % PDF, probability, and CDF require normalization
    p = p / n;
end