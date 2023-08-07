/*

Initialization and startup/shutdown routines used by the nidaq Toolbox.

	PROJECTS: nidaq Toolbox
  
	AUTHORS:
		dhkehoe@gmail.com				dhk
  
	PLATFORMS:
        64-bit Windows
    
	HISTORY:
		2023	  dhk		created alpha version

	TARGET LOCATION:

		nidaq.mexw64 resides in:
			/nidaq
*/

#include "RegisterProject.h" // Port custom project into PTB API

#define MAX_SYNOPSIS_STRINGS 500  
static const char *synopsisSYNOPSIS[MAX_SYNOPSIS_STRINGS]; // Synopsis string

/**************************************************************************
*                              INIT FUNCTIONS                             *                                                                    *
/*************************************************************************/

///////////////////////////////////////////////////////////////////////////
// Entry point for the Toolbox
PsychError PsychModuleInit(void)
{	
	// Register the project exit function:
	PsychErrorExit(PsychRegisterExit(&Close)); 
	
	// Register the project function which is called when the module
	// is invoked with no arguments:
	PsychErrorExitMsg(PsychRegister(NULL, &PsychDisplaySynopsis), "Failed to register the nidaq synopsis function.");        
	
	// Register the module name:
	PsychErrorExitMsg(PsychRegister("nidaq", NULL), "Failed to register nidaq Module name.");

    // Report module version:
	PsychErrorExit(PsychRegister("Version", &MODULEVersion));

    // Register synopsis and named subfunctions
	InitializeSynopsis(); // Scripting glue won't require this if the function takes no arguments.
    
    // Register authorship
    PsychAddAuthor("Devin", "Heinze", "Kehoe", "dhk", "dhkehoe@gmail.com", "https://ebitzlab.com/");
    PsychSetModuleAuthorByInitials("dhk");

	// Register sub-commands
    PsychErrorExit(PsychRegister("Open",            &Initialize));
    PsychErrorExit(PsychRegister("Close",           &Uninitialize));
    PsychErrorExit(PsychRegister("IsOpen",          &IsInitialized));

    PsychErrorExit(PsychRegister("ReadDIO",         &ReadDIO));
    PsychErrorExit(PsychRegister("WriteDIO",        &WriteDIO));
    PsychErrorExit(PsychRegister("ReadAI",          &ReadAI));
    PsychErrorExit(PsychRegister("WriteAO",         &WriteAO));

    // Initialize the device handle
    taskHandle = NULL;

	return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Build the synopsis string
void InitializeSynopsis()
{
	int i=0;
	const char **synopsis = synopsisSYNOPSIS;

	synopsis[i++] = "\n% This is the main function of the nidaq Toolbox.";
	synopsis[i++] = "\nUsage:";
    
	// Initialization
	synopsis[i++] = "\n% Initialize, shutdown, and check status of connection to NI-DAQ:";
	synopsis[i++] = "[connected =] nidaq('Open')";
	synopsis[i++] = "[connected =] nidaq('Close')";
	synopsis[i++] = "connected = nidaq('IsOpen')";

    // Read/write
    synopsis[i++] = "\n% Read and write NI-DAQ pin states:";
	synopsis[i++] = "[state, success] = nidaq('ReadDIO',)";
    synopsis[i++] = "[volts, success] = nidaq('ReadAI',)";
    synopsis[i++] = "[success =] nidaq('WriteDIO',)";
    synopsis[i++] = "[success =] nidaq('WriteAO',)";

    // Extra help
    synopsis[i++] = "\n% For general advice, try:";
    synopsis[i++] = "help nidaq";
    synopsis[i++] = "\n% For a more detailed explanation of any nidaq function, just add a question mark \"?\".";
    synopsis[i++] = "% E.g., for an explanation of 'Initialize', try either of these equivalent forms:";
    synopsis[i++] = "nidaq('Initialize?')";
    synopsis[i++] = "nidaq Initialize?";

	// Place Holder
	synopsis[i++] = "\n\n% NI-DAQmx Toolbox for PsychToolbox";
	synopsis[i++] = "% This Toolbox was developed by:\n";
	synopsis[i++] = "\tDevin H. Kehoe";
	
	synopsis[i++] = NULL;  //this tells PsychDisplayScreenSynopsis where to stop

	if (i > MAX_SYNOPSIS_STRINGS) {
		PrintfExit("%s: increase dimension of synopsis[] from %ld to at least %ld and recompile.", __FILE__, (long) MAX_SYNOPSIS_STRINGS, (long) i);
	}
}

///////////////////////////////////////////////////////////////////////////
// Print the NI-DAQ synopsis
PsychError PsychDisplaySynopsis(void)
{
	for (int i = 0; synopsisSYNOPSIS[i] != NULL; i++) {
		printf("%s\n", synopsisSYNOPSIS[i]);
	}
	return(PsychError_none);
}


///////////////////////////////////////////////////////////////////////////
// Open the connection to the NI-DAQ. Get device handle. Set defaults.
void Open(void)
{
    if( taskHandle==NULL ) {
        // int32 __CFUNC DAQmxCreateTask(const char taskName[], TaskHandle *taskHandle);
        DAQmxErrChk(DAQmxCreateTask("", &taskHandle));

        // Update connected global scope variable
        connected = (bool)taskHandle;
    }
}

///////////////////////////////////////////////////////////////////////////
// Close the connection to the NI-DAQ. Release memory.
void Close(void)
{
    if( taskHandle!=NULL ) {
        // int32 __CFUNC DAQmxStopTask(TaskHandle taskHandle);
        DAQmxStopTask(taskHandle);

        // int32 __CFUNC DAQmxClearTask(TaskHandle taskHandle);
        DAQmxClearTask(taskHandle);

        // Update connected global scope variables
        taskHandle = NULL;
        connected = (bool)taskHandle;
    }
}