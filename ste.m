function e = ste(varargin)

% Determine the dimension whose size gives 'n' in the denominator
if 3 <= numel(varargin)
    % Case 1: 'dim' argument is provided
    dim = varargin{3};
else
    s = size(varargin{1});
    if sum(s>1)==1
        % Case 2: 'dim' argument is not provided; data is a vector; use dimension whose size is greater than one 
        dim = find( s==numel(varargin{1}) );
    else
        % Case 3: 'dim' argument is not provided; data is not a vector; use dimension 1
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