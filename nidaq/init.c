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
    PsychErrorExit(PsychRegister("WaveformDIO",     &WaveformDIO));
    PsychErrorExit(PsychRegister("ReadDIO",         &ReadDIO));
    PsychErrorExit(PsychRegister("WriteDIO",        &WriteDIO));
    PsychErrorExit(PsychRegister("ReadAI",          &ReadAI));
    PsychErrorExit(PsychRegister("WriteAO",         &WriteAO));
    PsychErrorExit(PsychRegister("ConnectDIO",      &ConnectDIO));
    PsychErrorExit(PsychRegister("DisconnectDIO",   &DisconnectDIO));
    PsychErrorExit(PsychRegister("Reset",           &Reset));
        
    // Initialize the generic device handle
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

    // Read/write
    synopsis[i++] = "\n% Read and write NI-DAQ pin states:";
	synopsis[i++] = "state = nidaq('ReadDIO', device, port, channel)";
    synopsis[i++] = "volts = nidaq('ReadAI', device, channel, config [,reads]);";
    synopsis[i++] = "nidaq('WriteDIO', device, port, channel, state)";
    synopsis[i++] = "nidaq('WriteAO', device, channel, volts)";
    synopsis[i++] = "nidaq('WaveformDIO', device, rate, channel, wave)";

    // Connect/disconnect
    synopsis[i++] = "\n% Configuration settings for NI-DAQ:";
    synopsis[i++] = "nidaq('ConnectDIO', device, sourcePFI, destinationPFI)";
    synopsis[i++] = "nidaq('DisconnectDIO', device, sourcePFI, destinationPFI)";
    
    // Device reset
    synopsis[i++] = "\n% Device settings for NI-DAQ:";
    synopsis[i++] = "nidaq('Reset', device)";
    
    // Extra help
    synopsis[i++] = "\n\n% For general advice, try:";
    synopsis[i++] = "help nidaq";
    synopsis[i++] = "\n% For a more detailed explanation of any nidaq function, just add a question mark \"?\".";
    synopsis[i++] = "% E.g., for an explanation of 'ReadDIO', try either of these equivalent forms:";
    synopsis[i++] = "nidaq('ReadDIO?')";
    synopsis[i++] = "nidaq ReadDIO?";

	// Place Holder
	synopsis[i++] = "\n\n% NI-DAQ-mx Toolbox for PsychToolbox";
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