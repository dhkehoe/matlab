function [p,F,df,H,strs] = coefTestMu(model,h0)
% Test all of the cell means (mu parameters) from a fitted GLM or GLME
% model against some null hypothesis. See fitglm() and fitglme() in the
% Statistics and Machine Learning toolbox.
%
% Returns a matrix of p-values (from marginal F-tests), where the size is
% such that the p-values are arranged into a short table, i.e., one
% dimension for each factor with the length of each dimension equal to the
% number of levels for the respective factor. Also returns equally sized
% vectors of F-values and degrees of freedom error for each mu parameter.
% Also return an N by N coefficient contrast matrix, 'H', where each row
% corresponds to a cell mean of the design matrix and each column
% corresponds to a fitted coefficient. Can be used to subsequently test
% contrasts of individual cell means with coefTest(). I have subsequently
% decided it should also optionally return the string names of the model
% factors in the same order that they were entered into the model.
%
%
%   DHK - June 12, 2024

if nargin<2
    switch lower(model.Distribution)
        case 'normal'
            h0 = 0;
        case 'binomial'
            h0 = .5;
        case 'poisson'
            h0 = 0;
    end
end

% Put this in the correct units
h0 = model.Link.Link(h0);
if isinf(h0)
    error('Link-transformed null hypothesis ''h0'' is infinite.');
end

% Get the number of coefficients
n = model.NumCoefficients;

% Get the coefficient names
c = model.CoefficientNames;

%% Build the contrast matrix
H = eye(n); % Every parameter
H(:,1) = 1; % Every parameter against the intercept

% Format the interaction terms
for i = find(contains(c,':'))
    ni = strfind(c{i},':'); % Find the interaction string indicators
    m = numel(ni)+1; % Get the number of interactions
    f  = cell(1,m); % List of factor string names

    % Parse the string to retrieve the interaction factor string
    s = 1; % Start of string
    for j = 1:numel(ni) % Number of factors minus 1
        f{j} = c{i}(s:ni(j)-1);
        s = ni(j)+1;
    end
    f{end} = c{i}(s:end); % Retrive final factor

    % Horrendous method to test whether lower coefficient contains
    % exclusively the factors in 'f'
    v = false(1,n);
    for j = 2:i
        sidx = c{j} == ':';
        for k = 1:m
            ci = max([0, strfind(c{j},f{k})]);
            if ci
                sidx(  ci : ci+numel(f{k})-1 ) = 1;
            end
        end
        v(j) = all(sidx);
    end

    % Fill the contrast matrix
    H(i,v) = 1; % All instances of this factor, not belonging to higher interactions
end

%% Rearrange the contrasts into a sensible order

% Get the factor level for each singleton coefficient
s = c(~contains(c,':') & contains(c,'_')); % Not an interaction / is not the intercept
f = cell(1,numel(s)); % Factor names as strings
k = nan( 1,numel(s)); % Factor levels
for i = 1:numel(s)
    j = strfind(s{i},'_');
    f{i} = s{i}(1:j-1); % Factor name
    k(i) = str2double(s{i}(j+1:end)); % Factor level
end

% Get the number of levels for each unique factor
s = unique(f,'stable');
lvls = nan(1,numel(s));
for i = 1:numel(s)
    lvls(i) = max(k(strcmp(s{i},f)));
end

% Rearrange the contrasts into a sensible order, where p(i,j,k,...) is the
% i_th level of the first factor, j_th level of the second factor, etc...
map = nan(n,numel(s));
for i = 1:n
    for j = 1:numel(s)
        k = strfind(c{i},s{j})+numel(s{j})+1; % Start position of j_th factor string in the i_th coefficient string
        if isempty(k) % Doesn't exist, factor level is 1
            map(i,j) = 1;
        else % Does exist, get factor level
            m = strfind(c{i},':'); % Find the end of the factor string
            m = min([ min(m( k<m ))-1, numel(c{i})]); % Find position of next factor, if it exists
            map(i,j) = str2double( c{i}(k:m) );
        end
    end
end

% Sort and rearrange the contrasts
[~,i] = sortrows(map,numel(s):-1:1);
H = H(i,:);

%% Compute the F-tests

% Initialize outputs
p  = nan(1,n);
F  = p;
df = p;

% Step through parameters
for i = 1:n
    [p(i),F(i),df(i)] = coefTest(model,H(i,:),h0);
end

% Reshape
if isscalar(lvls)
    lvls = [lvls,1];
end
p  = reshape(p,lvls);
F  = reshape(F,lvls);
df = reshape(df,lvls);
strs = unique(f);