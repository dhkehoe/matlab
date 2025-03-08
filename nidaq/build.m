% Run this function to compile the nidaq toolbox project into a .mexw64
% file. Only supported for Windows OS and requires the following
% dependencies/settings:
%   1) Windows API (see https://learn.microsoft.com/en-us/windows/win32/)
%   2) NI-DAQ-mx API (see https://www.ni.com/en/support/downloads/drivers/download.ni-daq-mx.html)
%   3) PsychToolbox Source (see http://psychtoolbox.org/docs/UseTheSource)
%   4) Microsoft Visual C++ Compiler (see https://visualstudio.microsoft.com/vs/features/cplusplus/)
%   5) MATLAB MEX engine configured to use MSVC (2015 or later) for C language compilation

function build(verbose)

if nargin < 1, verbose = 0; end
clc;

%% Define all necessary paths
% Get host name and PTB directory
AP;
cd([gitDir,'/nidaq']);

% Ensure integrity of dependencies/settings
if ~exist('PTBDir','var')
    error('No registered PsychToolbox Source directory for machine with host name ''%s'' registered in AP.m',compName);
end
if ~exist('win32Dir','var')
    error('No registered Windows API Source directory for machine with host name ''%s'' registered in AP.m',compName);
end
if ~ispc
    error('nidaq toolbox can only be built on Windows Systems')
end

% Define directories for build
SOURCEDIR = [gitDir,splitChar,'nidaq',splitChar];
TARGETDIR = [gitDir,splitChar,'nidaq'];
WINAPIDIR = win32Dir;
PSYCHDIR  = PTBDir;
NIDAQDIR  = 'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\'; % platform independent


%% Initialize build instructions
s = 'mex -O -output nidaq';
if verbose
    s = [s,' -v'];
end


%% Add custom assets
% Source files
s = [s,' ''',SOURCEDIR,'nidaq.c'''];
s = [s,' ''',SOURCEDIR,'init.c'''];
s = [s,' ''',SOURCEDIR,'util.c'''];

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
s = [s,' ''',PSYCHDIR,'Common\Base\MiniBox.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\MODULEVersion.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychAuthors.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychCellGlue.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychError.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychHelp.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychInit.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychMemory.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychRegisterProject.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychScriptingGlue.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychScriptingGlueMatlab.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychStructGlue.c'''];
s = [s,' ''',PSYCHDIR,'Common\Base\PsychVersioning.c'''];

s = [s,' ''',PSYCHDIR,'Windows\Base\PsychTimeGlue.c'''];

% Includes
s = [s,' ','-I''',PSYCHDIR,'Common\Base'''];
s = [s,' ','-I''',PSYCHDIR,'Common\Screen'''];
s = [s,' ','-I''',PSYCHDIR,'Windows\Base'''];

%% Set targeted build directory
s = [s, ' -outdir', ' ''',TARGETDIR,''''];

%% Compile
eval(s);