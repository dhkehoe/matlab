function [varg, val] = inputChecker(varg,vstr,dval,efun,estr)
% This function works quite similar to addOptional(). It takes a varargin
% argument 'varg' and the name of an optional argument specified as a
% string 'vstr'. It searches varargin for the optional argument and returns
% the value for this optional argument upon exiting the function. The value
% is assumed to be the subsequent element of varargin after the specifer.
% The specifier and subsequent value from varargin are trimmed and this
% trimmed varargin is returned upon exiting. Additionally, the value is
% defaulted to 'dval' and subjected to an integrity check 'efun'. 'efun' is
% a handle to an inline function that returns true when the value is
% acceptable. If the value is not acceptable according to 'efun', an error
% is throw. The error string is 'estr'.
val = dval;
for i = 1:numel(varg)
    if i<numel(varg) && ischar(varg{i}) && strcmpi(varg{i},vstr)
        val = varg{i+1};
        if ~efun(val)
            error(estr);
        end
        varg(i:i+1) = [];
        break;
    end
end