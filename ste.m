function e = ste(varargin)

% Determine the dimension size that gives 'n' in the denominator
if 3 <= numel(varargin)
    % Case 1: it's provided
    dim = varargin{3};
else
    if isvector(varargin{1}) && ~isscalar(varargin{1})
        % Case 2: not provided; data is vector; use first non-zero dimension
        dim = find( size(varargin{1})==numel(varargin{1}) );
    else
        % Case 3: not provided; data is not a vector; use dimension 1
        dim = 1;
    end
end

% Compute 'n', possibly adjusting for 'omitnan' flag
if contains( lower(varargin(cellfun(@ischar,varargin))), 'omitnan' )
    n = sum( ~isnan(varargin{1}), dim);
else
    n = size(varargin{1},dim);
end

% Compute and let var() catch any argument errors
e = sqrt( var(varargin{:}) ./ n);