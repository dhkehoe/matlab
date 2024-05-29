function [lim, tix, lab] = axlim(mm,units,pad) 

if any(isnan(mm) | isinf(mm))
    error('''m'' must not contain NaN or Inf values.');
end
if nargin<3
    pad = .05;
end
if nargin<2
    % Ticks should be a factor of these numbers
    nice = [1,2,5,10];

    % Units if we use 4-10 ticks
    units = range(mm)./(4:10)';

    % Rescale to approximately between (1,10)
    scale = units./10.^floor(log10(units));

    % Best "nice" unit with resepect to the rescaled units
    cmp = abs(repmat(scale,1,numel(nice)) - repmat(nice,7,1));

    % Find minimum
    [i,j] = ind2sub([7,numel(nice)],find(cmp(:)==min(cmp(:)),1,'first'));

    % Back into original units
    units = nice(j)*10^floor(log10(units(i)));
end

% Add a little whitespace padding
lim = mm + [-1,1] * range(mm)*pad;

% [min,max] number of 'units' to capture all the data
tix = mm-mod(mm,units) + [0,units] .* (mod(mm,units)~=0);

% Out-of-bounds adjustments
if tix(1) < lim(1)
    tix(1) = tix(1)+units;
end
if tix(2) > lim(2)
    tix(2) = tix(2)-units;
end

% If the upper/lower bound is way below/above the data, reduce the ticks
if (mm(1)-tix(1)) > units/2
    tix(1) = tix(1) + units;
end
if (tix(2)-mm(2)) > units/2
    tix(2) = tix(2) - units;
end

% Generate full set of ticks, adjusting for precision errors
tix = round((tix(1) : units : tix(2))/units)*units;

% Return string labels
lab = cellstr(num2str(tix'));