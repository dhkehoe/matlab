function y = softmax(x,lambda,dim)

% Verify lambda argument
if nargin<2 || isempty(lambda)
    lambda = 1;
elseif ~isnumeric(x)
    error('Argument ''lambda'' must be numeric.');
end

% Define exponential of x
y = exp(x.*lambda);

% Let MATLAB pick the default dimension to sum over
if nargin<3 || isempty(dim)
    y = y./sum(y);
else
    try % Catch any misformatting errors thrown by sum() and rethrow them from here
        y = y./sum(y,dim);
    catch err
        error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
    end
end