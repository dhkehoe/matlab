/*

Sub-function definitions for i1dp Toolbox.

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


/**************************************************************************
*                                                                         *
*                          i1dp SUB-FUNCTIONS                             *
*                                                                         *
* These functions are registered to the PTB API and are thus callable via *
* the i1dp.mex access point.                                              *
*                                                                         *
/*************************************************************************/
// Open connection to i1 DisplayPro
PsychError Initialize(void)
{
    // Setup online help: 
    static char useString[] = "[status =] i1dp('Initialize');";
    static char synopsisString[] =
        "Open connection to i1 Display Pro and report whether connection was successfully established."
        "This function must be called before any other i1dp calls."
		"Initialization must be paired with a call to i1d3('Destroy').\n\n"
        "Returns (int): 1 if connected, 0 otherwise.";
    static char seeAlsoString[] = "Uninitialize, IsConnected";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Initialize i1
    Open();

    // Give connection status report
    PrintConnectionStatus();

    // Return connection status
    if (PsychGetNumNamedOutputArgs())
    {
        PsychCopyOutDoubleArg(1, FALSE, connected);
    }

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Close connection to i1 DisplayPro
PsychError Uninitialize(void)
{
    // Setup online help: 
    static char useString[] = "[status =] i1dp('Uninitialize');";
    static char synopsisString[] =
        "Close connection to i1 Display Pro and report whether connection was closed."
        "This function disables all other i1dp calls.\n\n"
        "Returns (int): 1 if connected, 0 otherwise.";
    static char seeAlsoString[] = "Initialize, IsConnected";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()){
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Uninitialize i1
    Close();

    // Give connection status report
    PrintConnectionStatus();

    // Return connection status
    if (PsychGetNumNamedOutputArgs())
    {
        PsychCopyOutDoubleArg(1, FALSE, connected);
    }

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Check connection status of i1 DisplayPro
PsychError IsConnected(void)
{
    // Setup online help: 
    static char useString[] = "status = i1dp('IsConnected');";
    static char synopsisString[] =
        "Check connection status of i1 Display Pro.\n\n"
        "Returns (int): 1 if connected, 0 otherwise.";
    static char seeAlsoString[] = "Initialize, Uninitialize";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Return connection status
    PsychCopyOutDoubleArg(1, FALSE, connected);

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Get info on the i1 DisplayPro hardware/software
PsychError GetDeviceInfo(void)
{
    // Setup online help: 
    static char useString[] = "info = i1dp('GetInfo');";
    static char synopsisString[] =
        "Get hardware/software information for the <strong>initialized</strong> i1 Display Pro.\n\n"
        "Returns a (struct) with these fields:\n"
        "    .ProductName (string): X-Rite product name of hardware device.\n"
        "   .SerialNumber (string): Hardware device serial number.\n"
        ".FirmwareVersion (string): Firmware version number.\n"
        "   .FirmwareDate (string): Firmware build date.\n"
        ".SoftwareVersion (string): Software version number.\n";
    static char seeAlsoString[] = "Initialize, Uninitialize";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Retrieve info
    i1d3DEVICE_INFO infostruct;
    StatusChecker(i1d3GetDeviceInfo(devHndl, &infostruct));

    char *serialNum = malloc(30);
    StatusChecker(i1d3GetSerialNumber(devHndl, serialNum));

    char *version = malloc(30);
    i1d3GetToolkitVersion(version);   


    // Create return struct
    int i = 0;
    const char **fieldNames;
	fieldNames[i++] = "ProductName";
    fieldNames[i++] = "SerialNumber";
    fieldNames[i++] = "FirmwareVersion";
    fieldNames[i++] = "FirmwareDate";
    fieldNames[i++] = "SoftwareVersion";
    PsychGenericScriptType **pStruct;
    PsychAllocOutStructArray(1, false, 1, i, fieldNames, pStruct);

    // Fill return struct
    PsychSetStructArrayStringElement("ProductName",     0, infostruct.strProductName, *pStruct);
    PsychSetStructArrayStringElement("SerialNumber",    0, serialNum, *pStruct);
    PsychSetStructArrayStringElement("FirmwareVersion", 0, infostruct.strFirmwareVersion, *pStruct);
    PsychSetStructArrayStringElement("FirmwareDate",    0, infostruct.strFirmwareDate, *pStruct);
    PsychSetStructArrayStringElement("SoftwareVersion", 0, version, *pStruct);

    // Deallocate the strings
    free(serialNum); free(version);
    

    return(PsychError_none);
}





///////////////////////////////////////////////////////////////////////////
// Set luminance units reported by the i1 DisplayPro
PsychError SetLuminanceUnits(void)
{
    // Setup online help: 
    static char useString[] = "i1dp('SetLuminanceUnits', units);";
    static char synopsisString[] =
        "Set the luminance units reported by the <strong>initialized</strong> i1 Display Pro.\n\n"
        "units (int): 1 for foot-lamberts, 2 for candelas per meter squared (default).\n";
    static char seeAlsoString[] = "GetLuminanceUnits";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(1));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(1)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs

    // Retrieve argument
    int units;
    PsychCopyInIntegerArg(1, TRUE, &units);

    // Set luminance units and validate range
    switch (units)
    {
        case 1:
            StatusChecker(i1d3SetLuminanceUnits(devHndl, i1d3LumUnitsFootLts));
            break;
        case 2:
            StatusChecker(i1d3SetLuminanceUnits(devHndl, i1d3LumUnitsNits));
            break;
        default:
            PsychErrorExitMsg(PsychError_user, "\nInvalid parameter: 'units' must be either 1 or 2.");
            break;
    }


    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Get luminance units reported by the i1 DisplayPro
PsychError GetLuminanceUnits(void)
{
    // Setup online help: 
    static char useString[] = "i1dp('GetLuminanceUnits', units);";
    static char synopsisString[] =
        "Get the luminance units reported by the <strong>initialized</strong> i1 Display Pro.\n\n"
        "units (int): 1 for foot-lamberts, 2 for candelas per meter squared.\n";
    static char seeAlsoString[] = "SetLuminanceUnits";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Get luminance units
    i1d3LumUnits_t lumUnits;
    StatusChecker(i1d3GetLuminanceUnits(devHndl, &lumUnits));

    // Return luminance units
    switch (lumUnits)
    {
        case i1d3LumUnitsFootLts:
            PsychCopyOutDoubleArg(1, FALSE, 1); // foot-lamberts = 1
            break;
        case i1d3LumUnitsNits:
            PsychCopyOutDoubleArg(1, FALSE, 2); // candelas per meter squared = 2
            break;
        default:
            PsychErrorExitMsg(PsychError_internal, "\nUnspecified luminance unit.");
            break;
    }

    
    return(PsychError_none);
}





///////////////////////////////////////////////////////////////////////////
// Set measurement mode of the i1 DisplayPro
PsychError SetMeasurementMode(void)
{
    // Setup online help: 
    static char useString[] = "i1dp('SetMeasurementMode', mode);";
    static char synopsisString[] =
        "Set the measurement mode used by the <strong>initialized</strong> i1 Display Pro."
        "Each measurement mode is optimized for calibrating a particular type of screen.\n\n"
        "mode (int): 1 for CRT , 2 for LCD , 3 for all-in-one (AIO) mode (default).\n"
        "Note that AIO mode is only supported on firmware versions >=2.14."
        "If your firmware doesn't support AIO mode, then the default is CRT mode."
        "X-Rite recommends using AIO mode as it affords faster and more accurate calibrations over other modes.";
    static char seeAlsoString[] = "GetMeasurementMode";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(1));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(1)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs

    // Retrieve measurement mode argument
    int mode;
    PsychCopyInIntegerArg(1, TRUE, &mode);

    // Set measurement mode and validate input
    switch (mode)
    {
        case 1: // CRT mode
            StatusChecker(i1d3SetMeasurementMode(devHndl, i1d3MeasModeCRT));
            break;
        case 2: // LCD mode
            StatusChecker(i1d3SetMeasurementMode(devHndl, i1d3MeasModeLCD));
            break;
        case 3: // AIO mode
            if (!isAIO)
            {
                PsychErrorExitMsg(PsychError_user, "\nInvalid parameter: AIO 'mode' not supported on your firmware.");
            }
            StatusChecker(i1d3SetMeasurementMode(devHndl, i1d3MeasModeAIO));
            break;
        default:
            PsychErrorExitMsg(PsychError_user, "\nInvalid parameter: 'mode' must be either between 1 and 3.");
    }
        
  
    return(PsychError_none);
}


///////////////////////////////////////////////////////////////////////////
// Get measurement mode of the i1 DisplayPro
PsychError GetMeasurementMode(void)
{
    // Setup online help: 
    static char useString[] = "i1dp('GetMeasurementMode', mode);";
    static char synopsisString[] =
        "Get the measurement mode used by the <strong>initialized</strong> i1 Display Pro."
        "Each measurement mode is optimized for calibrating a particular type of screen.\n\n"
        "mode (int): 1 for CRT , 2 for LCD , 3 for all-in-one (AIO) mode.\n";
    static char seeAlsoString[] = "SetMeasurementMode";
	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Get measurement mode
    i1d3LumUnits_t mode;
    StatusChecker(i1d3GetMeasurementMode(devHndl, &mode));

    // Return measurement mode
    switch (mode)
    {
        case i1d3MeasModeCRT: // CRT mode
            PsychCopyOutDoubleArg(1, FALSE, 1);
            break;
        case i1d3MeasModeLCD: // LCD mode
            PsychCopyOutDoubleArg(1, FALSE, 2);
            break;
        case i1d3MeasModeAIO: // AIO mode
            PsychCopyOutDoubleArg(1, FALSE, 3);
    }
    
    
    return(PsychError_none);
}





///////////////////////////////////////////////////////////////////////////
// Set the measurement time of the i1 DisplayPro
PsychError SetMeasurementTime(void)
{
    // Setup online help: 
    static char useString[] = "i1dp('SetMeasurementTime', time);";
    static char synopsisString[] =
        "Set the measurement time used by the <strong>initialized</strong> i1 Display Pro.\n\n"
        "time (double): measurement time in seconds (default = .2 s). Value must be >0.\n";
    static char seeAlsoString[] = "GetMeasurementTime";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(1));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(1)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs

    // Retrieve measurement time argument
    double time;
    PsychCopyInDoubleArg(1, TRUE, &time);

    // Validate input
    if (time <= 0)
    {
         PsychErrorExitMsg(PsychError_user, "\nInvalid parameter: 'time' must be >0.");
    }

    // Set measurement time
    StatusChecker(i1d3SetIntegrationTime(devHndl, time)); // CRT mode
    StatusChecker(i1d3SetTargetLCDTime(devHndl, time)); // LCD mode
   

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Get the measurement time of the i1 DisplayPro
PsychError GetMeasurementTime(void)
{
    // Setup online help: 
    static char useString[] = "time = i1dp('GetMeasurementTime');";
    static char synopsisString[] =
        "Get the measurement time used by the <strong>initialized</strong> i1 Display Pro.\n\n"
        "time (double): measurement time in seconds.\n";
    static char seeAlsoString[] = "SetMeasurementTime";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Retrieve measurement time
    double timeCRT, timeLCD;
    StatusChecker(i1d3GetIntegrationTime(devHndl, &timeCRT)); // CRT mode
    StatusChecker(i1d3GetTargetLCDTime(devHndl, &timeLCD)); // LCD mode
        // Validate input
    if (timeCRT != timeLCD)
    {
         PsychErrorExitMsg(PsychError_internal, "\nMeasurement time mismatch between measurement modes.");
    }

    // Return value
    PsychCopyOutDoubleArg(1, FALSE, timeCRT);


    return(PsychError_none);
}



///////////////////////////////////////////////////////////////////////////
// Set the backlight frequency of the monitor
PsychError SetBacklightFreq(void)
{
    // Setup online help: 
    static char useString[] = "i1dp('SetBacklightFreq', freq);";
    static char synopsisString[] =
        "If using Backlight Sync mode, set the refresh frequency of the monitor being calibrated by the <strong>initialized</strong> i1 Display Pro."
        "This mode allows for synchronizing calibration measurements with the monitor's refresh cycle."
        "Note that this feature is only supported in AIO measurement mode.\n\n"
        "freq (int): refresh frequency in Hz (default = 120 Hz), where 0 < freq <= 32767.\n";
    static char seeAlsoString[] = "GetBacklightFreq, SetBacklightSyncMode, SetMeasurementMode";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(1));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(1)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs

    // Retrieve backlight frequency argument
    int freq;
    PsychCopyInIntegerArg(1, TRUE, &freq);

    // Validate input
    if (freq < 0 || MAX_BACKLIGHT_FREQ < freq)
    {
         PsychErrorExitMsg(PsychError_user, "\nInvalid parameter: 'freq' must be between 0 and 32767.");
    }

    // Set backlight frequency 
    StatusChecker(i1d3SetBacklightFreq(devHndl, (unsigned short)freq)); // AIO mode

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Get the backlight frequency of the monitor
PsychError GetBacklightFreq(void)
{
    // Setup online help: 
    static char useString[] = "freq = i1dp('GetBacklightFreq');";
    static char synopsisString[] =
        "If using Backlight Sync mode, get the monitor refresh frequency used to "
        "synchronize calibration measurements with the monitor refresh cycle. "
        "Must be used with an <strong>initialized</strong> i1 Display Pro."
        "Note that this feature is only supported in AIO measurement mode.\n\n"
        "freq (int): refresh frequency in Hz.\n";
    static char seeAlsoString[] = "SetBacklightFreq, SetBacklightSyncMode, SetMeasurementMode";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Retrieve backlight frequency time
    unsigned short freq;
    StatusChecker(i1d3GetBacklightFreq(devHndl, &freq));

    // Return value
    PsychCopyOutDoubleArg(1, FALSE, freq);


    return(PsychError_none);
}



///////////////////////////////////////////////////////////////////////////
// Set the backlight frequency mode of i1
PsychError SetBacklightSyncMode(void)
{
    // Setup online help: 
    static char useString[] = "i1dp('SetBacklightSyncMode', mode);";
    static char synopsisString[] =
        "Set Backlight Sync mode for the <strong>initialized</strong> i1 Display Pro."
        "This mode allows for synchronizing calibration measurements with the monitor's refresh cycle and is recommended."
        "Note that this feature is only supported in AIO measurement mode.\n\n"
        "mode (int): 1 to use Backlight Sync mode (default), 0 otherwise.\n";
    static char seeAlsoString[] = "GetBacklightSyncMode, SetMeasurementMode, SetBacklightFreq";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(1));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(1)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs

    // Retrieve backlight sync mode argument
    int mode;
    PsychCopyInIntegerArg(1, TRUE, &mode);

    // Validate input
    if (mode < 0 || 1 < mode)
    {
         PsychErrorExitMsg(PsychError_user, "\nInvalid parameter: 'mode' must be between either 0 or 1.");
    }

    // Set measurement time
    StatusChecker(i1d3SetBacklightFreqSync(devHndl, (unsigned char)mode)); // AIO mode only



    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Get the backlight frequency mode of i1
PsychError GetBacklightSyncMode(void)
{
    // Setup online help: 
    static char useString[] = "mode = i1dp('GetBacklightSyncMode');";
    static char synopsisString[] = "Get Backlight Sync mode for the <strong>initialized</strong> i1 Display Pro."
        "This mode allows for synchronizing calibration measurements with the monitor's refresh cycle and is recommended."
        "Note that this feature is only supported in AIO measurement mode.\n\n"
        "mode (int): 1 to use Backlight Sync mode (default), 0 otherwise.\n";
    static char seeAlsoString[] = "SetBacklightSyncMode, SetMeasurementMode, SetBacklightFreq";
	
    PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Retrieve backlight sync mode
    unsigned char mode;
    StatusChecker(i1d3GetBacklightFreqSync(devHndl, &mode));

    // Return value
    PsychCopyOutDoubleArg(1, FALSE, mode);


    return(PsychError_none);
}





///////////////////////////////////////////////////////////////////////////
// Take a Yxy chromaticity measurement with the i1
PsychError MeasureYxy(void)
{
    // Setup online help: 
    static char useString[] = "[Y, x, y] = i1dp('MeasureYxy');";
    static char synopsisString[] = "Take an Yxy color space chromaticity "
        "measurement with the <strong>initialized</strong> i1 Display Pro.\n\n"
        "3 return arguments:\n"
        "\tY (double): Y coordinate value.\n"
        "\tx (double): x coordinate value.\n"
        "\ty (double): y coordinate value.\n";
    static char seeAlsoString[] = "SetLuminanceUnits, SetMeasurementMode, SetMeasurementTime, SetBacklightSyncMode";
	
    PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(3));	 // The maximum number of outputs

    // Perform measurement
    i1d3Yxy_t meas;
    StatusChecker(i1d3MeasureYxy(devHndl, &meas));

    // Return values
    PsychCopyOutDoubleArg(1, FALSE, meas.Y);
    PsychCopyOutDoubleArg(2, FALSE, meas.x);
    PsychCopyOutDoubleArg(3, FALSE, meas.y);


    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Take a XYZ chromaticity measurement with the i1
PsychError MeasureXYZ(void)
{
    // Setup online help: 
    static char useString[] = "[X, Y, Z] = i1dp('MeasureXYZ');";
    static char synopsisString[] = "Take an XYZ color space chromaticity "
        "measurement with the <strong>initialized</strong> i1 Display Pro.\n\n"
        "3 return arguments:\n"
        "\tX (double): X coordinate value.\n"
        "\tY (double): Y coordinate value.\n"
        "\tZ (double): Z coordinate value.\n";
    static char seeAlsoString[] = "MeasureYxy, MeasureRGB";
	
    PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(3));	 // The maximum number of outputs

    // Perform measurement
    i1d3XYZ_t meas;
    StatusChecker(i1d3MeasureXYZ(devHndl, &meas));

    // Return values
    PsychCopyOutDoubleArg(1, FALSE, meas.X);
    PsychCopyOutDoubleArg(2, FALSE, meas.Y);
    PsychCopyOutDoubleArg(3, FALSE, meas.Z);


    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Take a RGB chromaticity measurement with the i1
PsychError MeasureRGB(void)
{
    // Setup online help: 
    static char useString[] = "[R, G, B] = i1dp('MeasureRGB');";
    static char synopsisString[] = "Take an RGB color space chromaticity "
        "measurement with the <strong>initialized</strong> i1 Display Pro.\n\n"
        "3 return arguments:\n"
        "\tR (double): R coordinate value.\n"
        "\tG (double): G coordinate value.\n"
        "\tB (double): B coordinate value.\n";
    static char seeAlsoString[] = "MeasureYxy, MeasureXYZ";
	
    PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(3));	 // The maximum number of outputs

    // Perform measurement
    i1d3RGB_t meas;
    StatusChecker(i1d3MeasureRGB(devHndl, &meas));

    // Return values
    PsychCopyOutDoubleArg(1, FALSE, meas.R);
    PsychCopyOutDoubleArg(2, FALSE, meas.G);
    PsychCopyOutDoubleArg(3, FALSE, meas.B);


    return(PsychError_none);
}


///////////////////////////////////////////////////////////////////////////
// Get the stability of light source measured by i1
PsychError StableBacklight(void)
{
    // Setup online help: 
    static char useString[] = "stable = i1dp('StableBacklight');";
    static char synopsisString[] = "Assess whether the <strong>initialized</strong> i1 Display Pro can accurately measure the frequency of the light source.\n\n"
        "stable (int): 1 for a stable frequency, 0 for an unstable frequency.\n";
    static char seeAlsoString[] = "Measure, SetBacklightSyncMode, SetBacklightFreq";
	
    PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Retrieve backlight stability and return
    PsychCopyOutDoubleArg(1, FALSE, IsBackLightStable());


    return(PsychError_none);
}


///////////////////////////////////////////////////////////////////////////
// Get the diffuser position of i1
PsychError DiffuserPosition(void)
{
    // Setup online help: 
    static char useString[] = "position = i1dp('DiffuserPosition');";
    static char synopsisString[] = "Get the position of the diffuser on the <strong>initialized</strong> i1 Display Pro.\n\n"
        "position (int): 1 diffuser is covering lense, 0 diffuser is not covering the lense.\n";
    static char seeAlsoString[] = "Measure";
	
    PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Retrieve backlight sync mode
    unsigned char pos;
    StatusChecker(i1d3ReadDiffuserPosition(devHndl, &pos));

    // Return value
    PsychCopyOutDoubleArg(1, FALSE, (int)pos);


    return(PsychError_none);
}