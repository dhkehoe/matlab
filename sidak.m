function pc = sidak(p,dim)
% Apply the Šidák correction for a set of p-values
%
%   https://en.wikipedia.org/wiki/%C5%A0id%C3%A1k_correction

% Sort, not allowing for ties
if nargin<2 || isempty(dim)

    % Use defaults
    [~,r] = sort(p);
    [~,r] = sort(r);

elseif isscalar(dim) && isnumeric(dim) && ~mod(dim,1) && 0<dim

    % Adjustment along a specific dimension
    [~,r] = sort(p,dim);
    [~,r] = sort(r,dim);

elseif ischar(dim) && strcmpi(dim,'all')

    % Adjustmment along all dimensions
    [~,r] = sort(p(:));
    [~,r] = sort(r);
    r = reshape(r,size(p));

else
    % Bad format
    error('Invalid optional argument ''dim''. Must be a positive integer or ''all''.' );

end

% Adjust p-values
pc = p .* r;