function a = confEllipseArea(x,y,varargin)
try
    [~,~,~,~,~,a] = confEllipse(x,y);
catch err
    % Throw the error from within this function
    error(struct('identifier',err.identifier,'message',err.message,'stack',err.stack(end)));
end