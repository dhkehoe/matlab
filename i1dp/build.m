% Run this function to compile the i1dp API into a .mex file.
function build(verbose)
if nargin < 1, verbose = 0; end
clc;

% Define directories for build
BUILDDIR = 'i1dp';
SOURCEDIR = 'C:\Users\dhk\Documents\i1dp\';
TARGETDIR = [SOURCEDIR,BUILDDIR];
WINAPIDIR = 'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.20348.0\um\x64\';
XRITEDIR = 'C:\Users\dhk\Documents\i1d3SDK_1.4.0\';
PSYCHDIR = 'C:\Users\dhk\Documents\SourcePTB\PsychSourceGL\Source\';


%% Create target and navigate into target directory

% 

% 
% cd(TARGETDIR);

% % In case the .mex already exists, be sure to kill any running processes
% if exist('i1dp','file')
%     i1dp('Uninitialize'); % Frees any allocated memory
%     clear i1dp; % In theory, clear .mex from Matlab cache. This gives OS permission to overwrite existing .mex file, but Matlab stubbornly doesn't delete the cache.
% end

% Create a copy of i1 DP device runtime library in target directory to
% ensure that the .mex build is standalone
% copyfile([XRITEDIR,'Libs\x64\','i1d3SDK64.dll'],TARGETDIR);

%% Initialize build instructions
s = 'mex -O -output i1dp';
if verbose
    s = [s,' -v'];
end


%% Add custom assets
% Source files
s = [s,' ',SOURCEDIR,'i1dp.c'];
s = [s,' ',SOURCEDIR,'init.c'];
s = [s,' ',SOURCEDIR,'util.c'];
% s = [s,' ',SOURCEDIR,'RegisterProject.c'];

% Includes
s = [s,' ','-I''',SOURCEDIR,''''];

%% Add Windows API assets
% Source files
s = [s,' ''',WINAPIDIR,'WinMM.Lib''']; % Extra (') characters need because of space

% Includes
s = [s,' ','-L''',WINAPIDIR,''''];


%% Add X-Rite assets
% Source files
s = [s,' ',XRITEDIR,'Libs\x64\','i1d3SDK64.lib'];

% Libraries
s = [s,' ','-L''',XRITEDIR,'Libs\x64'''];

% Includes
s = [s,' ','-I''',XRITEDIR,'Include'''];


%% Add PsychToolbox assets
% Source files
s = [s,' ',PSYCHDIR,'Common\Base\MiniBox.c'];
s = [s,' ',PSYCHDIR,'Common\Base\MODULEVersion.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychAuthors.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychCellGlue.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychError.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychHelp.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychInit.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychMemory.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychRegisterProject.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychScriptingGlue.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychScriptingGlueMatlab.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychStructGlue.c'];
s = [s,' ',PSYCHDIR,'Common\Base\PsychVersioning.c'];

s = [s,' ',PSYCHDIR,'Windows\Base\PsychTimeGlue.c'];

% Includes
s = [s,' ','-I''',PSYCHDIR,'Common\Base'''];
s = [s,' ','-I''',PSYCHDIR,'Common\Screen'''];
s = [s,' ','-I''',PSYCHDIR,'Windows\Base'''];


%% Compile
eval(s);

%% Move .mex and dependencies to build folder
if ~exist(TARGETDIR,'dir')
    mkdir(TARGETDIR);
end

% cd(SOURCEDIR); % Navigate back to source directory

copyfile([XRITEDIR,'Libs\x64\','i1d3SDK64.dll'],TARGETDIR);
% movefile('i1d3SDK64.dll',BUILDDIR);

movefile('i1dp.mexw64',BUILDDIR,'f');