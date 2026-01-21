function varargout = concatenateMAT(d,overwrite)

% Verify this is a valid file path
if ~isfolder(d)
    error('''%s'' is not a valid file path.',d);
end
if nargin<2 || isempty(overwrite)
    overwrite = 1;
end

% Get the session name
% Additional data hygiene checks here would be beneficial...
while d(end)==filesep
    d(end) = [];
end
[~,s] = fileparts(d);

% Is our work here already done?
if ~overwrite
    file = [d,filesep,s,'.mat'];
    if exist(file,'file') % File exists
        m = whos('-file',file); % Peek inside
        if isempty(m) % Issue warning for empty files. Proceed to preprocess
            warning('File ''%s'' was located but is empty. Proceeding to concatenate.',file);
        else
            % File is not empty, return contents
            varargout = cell( min(numel(m),nargout), 1);
            for i = 1:numel(varargout)
                load(file,m(i).name);
                varargout{i} = eval(m(i).name);
            end
            return;
        end
    end
end

%% Concatenate

f = dir(d); % Folder contents
f = {f([f(:).isdir]).name}; % Just the subdirectories
f(contains(f,'.')) = []; % Exclude the unix parent references

% Step through the subdirectories
for i = 1:numel(f)

    % Format the subdirectories to full paths
    f{i} = [d,filesep,f{i},filesep];

    % Get the contents
    ff = {dir(f{i}).name};
    ff(~contains(ff,'.mat')|contains(ff,'task')) = []; % Just the .mat trial files

    % Update subdirectory list to include exhaustive list of full file
    % paths to each .mat file
    f{i} = [repmat(f{i},numel(ff),1), char(ff')];
end

% Concatenate all the file names into one structure
clear ff;
f = vertcat(f{:});

% Get the variable name
v = whos('-file',f(1,:)).name;

% Preallocate the struct
load(f(1,:),v);
s = repmat(eval(v),size(f,1),1);

% Fill the struct
for i = 2:size(f,1)
    load(f(i,:),v);
    s(i) = eval(v);
end

% Return the struct
if nargout
    varargout{1} = s;
end