function varargout = edf(data,edges,norm)
% Empirical distribution functions.
%
% Computes some empirical distribution function for a sample of data using
% a specified set of bins and a specified normalization type. Provides a
% good alternative to histogram(), i.e., it offers the same flexibility 
% without the annoying plot handle creation. 
%
% USAGE
%   
% INPUT
%    data - Matrix of numeric data to be binned. Matrix can have any number
%           of dimensions. NaNs and Infs are ignored.
%   edges - Vector of bin edges. Data in the ith bin is binned such that
%               f(i) = sum( edges(i) <= data & data < edges(i+1) )
%           As such, the number of bins == numel(edges)-1. Note that bin
%           edges do not need to be evenly spaced, but do need to be sorted
%           in ascending order.
%
% OPTIONAL INPUT
%    norm - Type of normalization across bins passed as a string:
%                 'pdf' - Probability density function (default)
%                'prob' - Probability/proportion
%                 'cdf' - Cumulative distribution function
%                'freq' - Frequency
%               'cfreq' - Cumulative frequency
%
% OUTPUT
%       p - Empirical distribution function values with respect to user
%           defined bin edges and normalization.
%       x - Bin centers where the ith bin is the halfway point between 
%           edges(i) and edges(i+1). As such, length(x) == length(edges)-1.
%
%   DHK - March 10, 2021

%% Error checking and preallocation

% Linearize the data, discard any NaNs or Infs
data = reshape( data( ~(isnan(data)|isinf(data)) ) ,[],1);

% Number of observations
n = numel(data);

% Default normalization
if nargin < 3 || isempty(norm)
    norm = 'pdf';
end 

% Default bin edges
if nargin < 2 || isempty(edges)
    edges = linspace(min(data),max(data),ceil(sqrt(n)));
    edges = [edges(1)-diff(edges(1:2))/2, edges+diff(edges(1:2))/2];

else
    % Ensure this is a row vector
    edges = reshape(edges,1,numel(edges));

    % Ensure an adequate number of bins edges have been provided
    if numel(edges)<2
        error('At least 2 bin edges required.');
    end

    % Ensure the bins are sorted in either ascending or decending order
    if ~issorted(edges)
        error('EDF edges must be sorted in ascending order.');
    end

    % Trim data outside of the range of bin edges to ensure the CDF sums to 1
    data(data<edges(1) | edges(end)<data) = [];
end

% Determine type of normalization
t = find(strcmp(norm,{'pdf','prob','cdf','freq','cfreq'})); 
if isempty(t)
    error(['Unrecognized normalization type ''',norm,'''.']);
end


%% Compute 'p' and 'x'

% Compute bin centers (domain of x)
x = mean([edges(2:end); edges(1:end-1)]);

% Compute frequencies
p = sum( edges(1:end-1)<=data & data<edges(2:end), 1);

% f(x) adjustments
if t == 1
    % PDF needs to be rescaled
    p = p ./ diff(edges);

elseif t == 3 || t == 5
    % If this is a cumulative function (CDF or cumulative frequency)
    p = cumsum(p);
end

% If necessary, normalize
if t < 4 % PDF, probability, and CDF require normalization
    p = p / n;
end

%% Output
switch nargout
    case 1
        varargout = {p};
    case 2
        varargout = {x,p};
end