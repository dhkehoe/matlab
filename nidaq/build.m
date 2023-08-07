% Run this function to compile the nidaq toolbox project into a .mexw64 file.
function build(verbose)
if nargin < 1, verbose = 0; end
clc;

% Define directories for build
BUILDDIR = 'C:\Users\dhk\Documents\nidaq\';
SOURCEDIR = 'C:\Users\dhk\Documents\nidaq\';
TARGETDIR = 'C:\Users\dhk\Documents\nidaq\';
WINAPIDIR = 'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.20348.0\um\x64\';
NIDAQDIR = 'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\';
PSYCHDIR = 'C:\Users\dhk\Documents\SourcePTB\PsychSourceGL\Source\';


%% Initialize build instructions
s = 'mex -O -output nidaq';
if verbose
    s = [s,' -v'];
end


%% Add custom assets
% Source files
s = [s,' ',SOURCEDIR,'nidaq.c'];
s = [s,' ',SOURCEDIR,'init.c'];
s = [s,' ',SOURCEDIR,'util.c'];

% Includes
s = [s,' ','-I''',SOURCEDIR,''''];

%% Add Windows API assets
% Source files
s = [s,' ''',WINAPIDIR,'WinMM.Lib''']; % Extra (') characters needed because of space

% Includes
s = [s,' ','-L''',WINAPIDIR,''''];


%% Add NI-DAQmx assets
% Source files
s = [s,' ''',NIDAQDIR,'lib64\msvc\','NIDAQmx.lib'''];

% Includes
s = [s,' ','-I''',NIDAQDIR,'include'''];

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