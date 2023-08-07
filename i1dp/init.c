/*

Initialization and startup/shutdown routines used by the i1dp Toolbox.

	PROJECTS: i1dp Toolbox
  
	AUTHORS:
		dhkehoe@gmail.com				dhk
  
	PLATFORMS:
        64-bit Windows
    
	HISTORY:
		2023	  dhk		created alpha version

	TARGET LOCATION:

		i1dp.mexw64 resides in:
			/i1dp
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
	PsychErrorExitMsg(PsychRegister(NULL, &PsychDisplaySynopsis), "Failed to register the Eyelink synopsis function.");        
	
	// Register the module name:
	PsychErrorExitMsg(PsychRegister("i1dp", NULL), "Failed to register i1dp Module name.");

    // Report module version:
	PsychErrorExit(PsychRegister("Version", &MODULEVersion));

    // Register synopsis and named subfunctions
	InitializeSynopsis(); // Scripting glue won't require this if the function takes no arguments.
    
    // Register authorship
    PsychAddAuthor("Devin", "Heinze", "Kehoe", "dhk", "dhkehoe@gmail.com", "https://ebitzlab.com/");
    PsychSetModuleAuthorByInitials("dhk");

	// Register sub-commands
    PsychErrorExit(PsychRegister("Initialize",           &Initialize));
    PsychErrorExit(PsychRegister("Uninitialize",         &Uninitialize));
    PsychErrorExit(PsychRegister("IsConnected",          &IsConnected));

    PsychErrorExit(PsychRegister("GetDeviceInfo",        &GetDeviceInfo));

    PsychErrorExit(PsychRegister("SetLuminanceUnits",    &SetLuminanceUnits));
    PsychErrorExit(PsychRegister("GetLuminanceUnits",    &GetLuminanceUnits));
    PsychErrorExit(PsychRegister("SetMeasurementMode",   &SetMeasurementMode));
    PsychErrorExit(PsychRegister("GetMeasurementMode",   &GetMeasurementMode));
    PsychErrorExit(PsychRegister("SetMeasurementTime",   &SetMeasurementTime));
    PsychErrorExit(PsychRegister("GetMeasurementTime",   &GetMeasurementTime));
    PsychErrorExit(PsychRegister("SetBacklightFreq",     &SetBacklightFreq));
    PsychErrorExit(PsychRegister("GetBacklightFreq",     &GetBacklightFreq));
    PsychErrorExit(PsychRegister("SetBacklightSyncMode", &SetBacklightSyncMode));
    PsychErrorExit(PsychRegister("GetBacklightSyncMode", &GetBacklightSyncMode));

    PsychErrorExit(PsychRegister("MeasureYxy",           &MeasureYxy));
    PsychErrorExit(PsychRegister("MeasureXYZ",           &MeasureXYZ));
    PsychErrorExit(PsychRegister("MeasureRGB",           &MeasureRGB));
    PsychErrorExit(PsychRegister("StableBacklight",      &StableBacklight));
    PsychErrorExit(PsychRegister("DiffuserPosition",     &DiffuserPosition));


    // Initialize the device handle
    devHndl = NULL;

	return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Build the synopsis string
void InitializeSynopsis()
{
	int i=0;
	const char **synopsis = synopsisSYNOPSIS;

	synopsis[i++] = "\n% This is the main function of the i1dp Toolbox.";
	synopsis[i++] = "\nUsage:";
    
	// Initialization
	synopsis[i++] = "\n% Initialize, shutdown, and check status of i1Display Pro connection:";
	synopsis[i++] = "[connected =] i1dp('Initialize')";
	synopsis[i++] = "[connected =] i1dp('Uninitialize')";
	synopsis[i++] = "connected = i1dp('IsConnected')";

    // Info
    synopsis[i++] = "\n% Get hardware and software info:";
	synopsis[i++] = "info = Eyelink('GetDeviceInfo')";

    // Get/set
    synopsis[i++] = "\n% Get and set device parameters:";
	synopsis[i++] = "i1dp('SetLuminanceUnits', units)";
    synopsis[i++] = "units = i1dp('GetLuminanceUnits')";
    synopsis[i++] = "i1dp('SetMeasurementMode', mode)";
    synopsis[i++] = "mode = i1dp('GetMeasurementMode')";
    synopsis[i++] = "i1dp('SetMeasurementTime', time)";
    synopsis[i++] = "time = i1dp('GetMeasurementTime')";
    synopsis[i++] = "i1dp('SetBacklightFreq', freq)";
    synopsis[i++] = "freq = i1dp('GetBacklightFreq')";
    synopsis[i++] = "i1dp('SetBacklightSyncMode', mode)";
    synopsis[i++] = "mode = i1dp('GetBacklightSyncMode')";

    // Measurements
    synopsis[i++] = "\n% Take measurements with the device:";
    synopsis[i++] = "[Y, x, y] = i1dp('MeasureYxy')";
    synopsis[i++] = "[X, Y, Z] = i1dp('MeasureXYZ')";
    synopsis[i++] = "[R, G, B] = i1dp('MeasureRGB')";
    synopsis[i++] = "stable = i1dp('StableBacklight')";
    synopsis[i++] = "position = i1dp('DiffuserPosition')";    

    // Extra help
    synopsis[i++] = "\n% For general advice, try:";
    synopsis[i++] = "help i1dp";
    synopsis[i++] = "\n% For a more detailed explanation of any i1dp function, just add a question mark \"?\".";
    synopsis[i++] = "% E.g., for an explanation of 'Initialize', try either of these equivalent forms:";
    synopsis[i++] = "i1dp('Initialize?')";
    synopsis[i++] = "i1dp Initialize?";

	// Place Holder
	synopsis[i++] = "\n\n% i1 DisplayPro Toolbox for PsychToolbox";
	synopsis[i++] = "% This Toolbox was developed by:\n";
	synopsis[i++] = "\tDevin H. Kehoe";
	
	synopsis[i++] = NULL;  //this tells PsychDisplayScreenSynopsis where to stop

	if (i > MAX_SYNOPSIS_STRINGS) {
		PrintfExit("%s: increase dimension of synopsis[] from %ld to at least %ld and recompile.", __FILE__, (long) MAX_SYNOPSIS_STRINGS, (long) i);
	}
}

///////////////////////////////////////////////////////////////////////////
// Print the i1dp synopsis
PsychError PsychDisplaySynopsis(void)
{
	for (int i = 0; synopsisSYNOPSIS[i] != NULL; i++) {
		printf("%s\n", synopsisSYNOPSIS[i]);
	}
	return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Open the USB connection to the i1 Display Pro. Get device handle. Set defaults.
void Open()
{
    if (devHndl == NULL)
    {
        unsigned int vid = 0, pid = 0;
        unsigned char productkey [] = {0xD4,0x9F,0xD4,0xA4,0x59,0x7E,0x35,0xCF,0}; // Unlock the i1
        StatusChecker(i1d3OverrideDeviceDefaults(vid, pid, productkey));
        StatusChecker(i1d3Initialize());
        StatusChecker(i1d3GetDeviceHandle(i1d3GetNumberOfDevices()-1,&devHndl));
        StatusChecker(i1d3DeviceOpen(devHndl));
        StatusChecker(i1d3SetLEDControl(devHndl, i1d3LED_PULSE, 0., 0., KEEP_LED_ON_INDEFINITELY)); // Turn on LED
        // Determine whether to use AIO measurement mode (recommended, but only supported by recent firmware)
        isAIO = i1d3SupportsAIOMode(devHndl)==i1d3Success;
        if (isAIO)
        {
            i1d3SetMeasurementMode(devHndl, DEFAULT_MEAS_MODE); // Set default measurement mode on supported firmware
            if (IsBackLightStable()) // Backlight sync mode only supported in AIO mode
            {
                StatusChecker(i1d3SetBacklightFreq(devHndl, DEFAULT_REFRESH)); // Set default backlight sync
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////
// Close the USB connection to the i1 Display Pro. Release memory.
void Close(void)
{
    if (devHndl != NULL)
    {
        StatusChecker(i1d3DeviceClose(devHndl));
        StatusChecker(i1d3Destroy());
        devHndl = NULL;
    }
}