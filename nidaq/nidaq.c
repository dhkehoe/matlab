/*

Sub-function definitions for NI-DAQ-mx Toolbox.

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


/**************************************************************************
*                                                                         *
*                         nidaq SUB-FUNCTIONS                             *
*                                                                         *
* These functions are registered to the PTB API and are thus callable via *
* the nidaq.mex access point.                                             *
*                                                                         *
/*************************************************************************/
// Open connection to NI-DAQ
PsychError Initialize(void)
{
    // Setup online help: 
    static char useString[] = "[status =] nidaq('Open');";
    static char synopsisString[] =
        "Open connection to NI-DAQmx and report whether connection was successfully\n"
        "established. This function must be called before any other nidaq calls.\n"
		"Outputs:\n"
        " status - An integer scalar specifying whether device is initialized (1),\n"
        "          or uninitialized (0).";
    static char seeAlsoString[] = "Close, IsOpen";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Initialize NI-DAQ
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
// Close connection to NI-DAQ
PsychError Uninitialize(void)
{
    // Setup online help: 
    static char useString[] = "[status =] nidaq('Close');";
    static char synopsisString[] =
        "Close connection to NI-DAQ and report whether connection was closed.\n"
        "This function disables all other nidaq calls.\n"
        "Outputs:\n"
        " status - An integer scalar specifying whether device is initialized (1),\n"
        "          or uninitialized (0).";;
    static char seeAlsoString[] = "Open, IsOpen";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()){
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(0));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(0)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Uninitialize  NI-DAQ
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
// Check connection status of NI-DAQ
PsychError IsInitialized(void)
{
    // Setup online help: 
    static char useString[] = "status = nidaq('IsOpen');";
    static char synopsisString[] =
        "Check connection status of  NI-DAQ.\n"
        "Outputs:\n"
        " status - An integer scalar specifying whether device is initialized (1),\n"
        "          or uninitialized (0).";
    static char seeAlsoString[] = "Open, Close";

	PsychPushHelp(useString, synopsisString, seeAlsoString);
	
    if(PsychIsGiveHelp()){
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
// Read the DIO pin state for some subset of pins, output result to user
PsychError ReadDIO(void)
{
    // Setup online help: 
    static char useString[] = "[state, success] = nidaq('ReadDIO', device, port, channel);";
    static char synopsisString[] =
        "Read the digital pin state for some subset of ports/channels on an\n"
        "initialized NI-DAQ system.\n"
        "Args:\n"
        " device - The device number as reported by NI MAX Device Manager.\n"
        "          If unsure, launch NI MAX application, click 'Devices and\n"
        "          Interfaces' and find your device number. E.g., dev1 is\n"
        "          specified with a 1. 'device' must be a scalar integer.\n"
        "   port - Check the pin-out diagram. Pins are specified as port.channel;\n"
        "          e.g., for pin 2.3, 'port' is specified with a 2. 'port'\n"
        "          can be a matrix with up to 3 dimensions. Multiple 'port'\n"
        "          values specifies multiple DIO read operations.\n"
        "channel - Check the pin-out diagram. Pins are specified as port.channel;\n"
        "          e.g., for pin 2.3, 'channel' is specified with a 3.\n"
        "          'channel' can be a matrix with up to 3 dimensions, but the\n"
        "          shape must match between 'port' and 'channel'. Multiple\n"
        "          'channel' values specifies multiple DIO read operations.\n"
        "Outputs:\n"
        "  state - A matrix with the same shape as 'port' and 'channel' specifying\n"
        "          whether each queried port.channel pin on the DIO interface\n"
        "          is either high (1) or low (0).\n"
        "success - An integer scalar indicating whether all read operations\n"
        "          were successfully (1) or unsuccessfully (0) completed.\n";
    static char seeAlsoString[] = "WriteDIO, ReadAI";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(3));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(3)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs
    
    // Check input data integrity, build the DIO lines string,
    // get the number of reads, and get the input/ouptput data dimensions
    uInt32 arraySizeInBytes, dim[3];
    char* lines = buildStrDIO(&arraySizeInBytes, dim, FALSE);

    // Allocate enough memory for reading from NI-DAQmx
    uInt8* data = malloc(arraySizeInBytes * sizeof(uInt8)); 

    // int32 __CFUNC DAQmxCreateDIChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
    DAQmxErrChk(DAQmxCreateDIChan(taskHandle, lines, "", DAQmx_Val_ChanForAllLines));

    // int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxReadDigitalLines(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, uInt8 readArray[], uInt32 arraySizeInBytes, int32 *sampsPerChanRead, int32 *numBytesPerSamp, bool32 *reserved);
	int32 read, bytesPerSamp;
    DAQmxErrChk(DAQmxReadDigitalLines(taskHandle, DEFAULT_SAMPS_PER_CHAN, DEFAULT_TIME_OUT, DAQmx_Val_GroupByChannel, data, arraySizeInBytes, &read, &bytesPerSamp, NULL));

    // Give user output
    double* state = (double *)PsychMallocTemp(arraySizeInBytes*sizeof(double));
    for (int i = 0; i < (int)arraySizeInBytes; i++)
        state[i] = (double)(data[i] ? 1 : 0);
    PsychCopyOutDoubleMatArg(1, kPsychArgOptional, dim[0], dim[1], dim[2], state);

    // Free malloc calls
    free(lines);
    free(data);

    // Return success indicator
    PsychCopyOutDoubleArg(2, FALSE, read==arraySizeInBytes);

    return(PsychError_none);
}


///////////////////////////////////////////////////////////////////////////
// Write user requested pin state to the DIO interface on the NI-DAQ
PsychError WriteDIO(void)
{
    // Setup online help: 
    static char useString[] = "[success=] nidaq('WriteDIO', device, port, channel, state);";
    static char synopsisString[] =
        "Write the digital pin state for some subset of ports/channels on an\n"
        "initialized NI-DAQ system.\n"
        "Args:\n"
        " device - The device number as reported by NI MAX Device Manager.\n"
        "          If unsure, launch NI MAX application, click 'Devices and\n"
        "          Interfaces' and find your device number. E.g., dev1 is\n"
        "          specified with a 1. 'device' must be a scalar integer.\n"
        "   port - Check the pin-out diagram. Pins are specified as port.channel;\n"
        "          e.g., for pin 2.3, 'port' is specified with a 2. 'port'\n"
        "          can be a matrix with up to 3 dimensions. Multiple 'port'\n"
        "          values specifies multiple DIO read operations.\n"
        "channel - Check the pin-out diagram. Pins are specified as port.channel;\n"
        "          e.g., for pin 2.3, 'channel' is specified with a 3.\n"
        "          'channel' can be a matrix with up to 3 dimensions, but the\n"
        "          shape must match between 'port' and 'channel'. Multiple\n"
        "          'channel' values specifies multiple DIO read operations.\n"
        "  state - A matrix with the same shape as 'port' and 'channel' specifying\n"
        "          the digital state of each specified port.channel pin on\n"
        "          the DIO interface. Non-zero values set pins high (+5V),\n"
        "          while zero values set the pin low (0V). Note that reading\n"
        "          a pin on the DIO interface will reset that pin back to 0V\n"
        "          superceding any previously written values."
        "Outputs:\n"
        "success - An integer scalar indicating whether all read operations\n"
        "          were successfully (1) or unsuccessfully (0) completed.\n";
    static char seeAlsoString[] = "ReadDIO, WriteAO";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(4));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(4)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs

    // Check input data integrity, build the DIO lines string,
    // get the number of writes, and get the input/ouptput data dimensions
    uInt32 arraySizeInBytes, dim[3];
    char* lines = buildStrDIO(&arraySizeInBytes, dim, TRUE);

    // Allocate enough memory for writing to NI-DAQmx
    uInt8* data = malloc(arraySizeInBytes * sizeof(uInt8));

    // Copy user state data into write array
    double* state = mxGetPr(PsychGetInArgMxPtr(4));
    for (int i = 0; i < (int)arraySizeInBytes; i++)
        data[i] = (uInt8)(state[i] ? 0xFF : 0);

    // int32 __CFUNC DAQmxCreateDOChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
    DAQmxErrChk(DAQmxCreateDOChan(taskHandle, lines, "", DAQmx_Val_ChanPerLine));

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxWriteDigitalU8(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const uInt8 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
	int32 written;
    DAQmxErrChk(DAQmxWriteDigitalU8(taskHandle, DEFAULT_SAMPS_PER_CHAN, DEFAULT_WRITE_AUTO_START, DEFAULT_TIME_OUT, DAQmx_Val_ChanPerLine, data, &written, NULL));

    // Free malloc calls
    free(lines);
    free(data);

    // Return success indicator
    PsychCopyOutDoubleArg(1, FALSE, written==arraySizeInBytes);

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Write a user-specified voltage to the NI-DAQ analog interface
PsychError WriteAO(void)
{
    // Setup online help: 
    static char useString[] = "[success=] nidaq('WriteAO', device, channel, volts);";
    static char synopsisString[] =
        "Write the analog pin voltage for some subset of channels on an\n"
        "initialized NI-DAQ system.\n"
        "Args:\n"
        " device - The device number as reported by NI MAX Device Manager.\n"
        "          If unsure, launch NI MAX application, click 'Devices and\n"
        "          Interfaces' and find your device number. E.g., dev1 is\n"
        "          specified with a 1. 'device' must be a scalar integer.\n"
        "channel - Check the pin-out diagram. Pins are specified as 'AO channel';\n"
        "          e.g., for AO 3, 'channel' is specified with a 3.\n"
        "          'channel' can be a matrix with up to 3 dimensions, but the\n"
        "          shape must match between 'channel' and 'voltage'. Multiple\n"
        "          'channel' values specifies multiple AO write operations.\n"
        "  volts - A matrix with the same shape as 'channel' specifying\n"
        "          the analog voltage of each specified channel pin on\n"
        "          the AO interface. Voltages are input as type double\n"
        "          and are bound between +/-10 V."
        "Outputs:\n"
        "success - An integer scalar indicating whether all write operations\n"
        "          were successfully (1) or unsuccessfully (0) completed.\n";
    static char seeAlsoString[] = "ReadAI, WriteDIO";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(3));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(3)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs
    
    // Check input data integrity, build the AO lines string,
    // get the number of writes, and get the input/ouptput data dimensions
    uInt32 arraySizeInBytes, dim[3];
    char* lines = buildStrAIO(&arraySizeInBytes, dim, TRUE);

    // Allocate enough memory for writing to NI-DAQmx
    float64* data = malloc(arraySizeInBytes * sizeof(float64));

    // Copy user data into data to write array
    double* voltage = mxGetPr(PsychGetInArgMxPtr(4));
    for (int i = 0; i < (int)arraySizeInBytes; i++)
        data[i] = (float64)voltage[i];

    // int32 __CFUNC DAQmxCreateAOVoltageChan(TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
	DAQmxErrChk(DAQmxCreateAOVoltageChan(taskHandle, lines, "", DEFAULT_AIO_MIN_VAL, DEFAULT_AIO_MAX_VAL, DAQmx_Val_Volts,""));
    // specify a list: Dev1/port0, Dev1/port1/line0:2 

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

	// int32 __CFUNC DAQmxWriteAnalogF64(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const float64 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
    int32 written;
    DAQmxErrChk(DAQmxWriteAnalogF64(taskHandle, DEFAULT_SAMPS_PER_CHAN, DEFAULT_WRITE_AUTO_START, DEFAULT_TIME_OUT, DAQmx_Val_GroupByChannel, data, &written, NULL));

    // Free malloc calls
    free(lines);
    free(data);

    // Return success indicator
    PsychCopyOutDoubleArg(1, FALSE, written==arraySizeInBytes);

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Read a user-specified voltage to the NI-DAQ analog interface
PsychError ReadAI(void)
{
    // Setup online help: 
    static char useString[] = "[voltage, success] = nidaq('ReadAI', device, channel, config);";
    static char synopsisString[] =
        "Read the analog pin voltage for some subset of channels on an\n"
        "initialized NI-DAQ system.\n"
        "Args:\n"
        " device - The device number as reported by NI MAX Device Manager.\n"
        "          If unsure, launch NI MAX application, click 'Devices and\n"
        "          Interfaces' and find your device number. E.g., dev1 is\n"
        "          specified with a 1. 'device' must be a scalar integer.\n"
        "channel - Check the pin-out diagram. Pins are specified as 'AI channel';\n"
        "          e.g., for AI 3, 'channel' is specified with a 3.\n"
        "          'channel' can be a matrix with up to 3 dimensions. Multiple\n"
        "          'channel' values specifies multiple AI read operations.\n"
        " config - The analog input reference configuration. Constant across\n"
        "          all specified AI channels. Must be a scalar integer value\n"
        "          between 1-4 to indiate\n"
        "               1 - Referenced single-ended mode\n"
        "               2 - Non-referenced single-ended mode\n"
        "               3 - Differential mode\n"
        "               4 - Pseudo-differential mode\n"
        "          For more info, see link <a href=\"https://www.ni.com/docs/en-US/bundle/ni-daqmx/page/measfunds/connectaisigs.html\">ni.com/docs</a>\n"
        "Outputs:\n"
        "voltage - A matrix with the same shape as 'channel' specifying\n"
        "          the analog voltage of each queried channel pin on\n"
        "          the AI interface. Voltages are output as type double\n"
        "          and are bound between +/-10 V."
        "success - An integer scalar indicating whether all read operations\n"
        "          were successfully (1) or unsuccessfully (0) completed.\n";
    static char seeAlsoString[] = "WriteAO, ReadDIO";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(3));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(3)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Check input data integrity, build the AO lines string,
    // get the number of writes, and get the input/ouptput data dimensions
    uInt32 arraySizeInBytes, dim[3];
    char* lines = buildStrAIO(&arraySizeInBytes, dim, FALSE);

    // Allocate enough memory for reading NI-DAQmx
    float64* data = malloc(arraySizeInBytes * sizeof(float64));

    // Get the user requested terminal configuration
    int32 config;
    PsychCopyInIntegerArg(3, TRUE, &config);
    if (config <1 || 4 < config)
    {
        PsychErrorExitMsg(PsychError_user, "Argument 'config' out of range.");
    }

    // int32 __CFUNC DAQmxCreateAIVoltageChan(TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
    DAQmxErrChk(DAQmxCreateAIVoltageChan(taskHandle, lines, "", configs[config-1], DEFAULT_AIO_MIN_VAL, DEFAULT_AIO_MAX_VAL, DAQmx_Val_Volts, NULL));

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxReadAnalogF64(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, float64 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
    int32 read;
    DAQmxErrChk(DAQmxReadAnalogF64(taskHandle, DEFAULT_SAMPS_PER_CHAN, DEFAULT_TIME_OUT, DAQmx_Val_GroupByChannel, data, arraySizeInBytes, &read, NULL));
    
    // Copy read data into voltag array and send back to user
    double* voltage = (double *)PsychMallocTemp(arraySizeInBytes*sizeof(double));
    for (int i = 0; i < (int)arraySizeInBytes; i++)
        voltage[i] = (double)(data[i]);
    PsychCopyOutDoubleMatArg(1, kPsychArgOptional, dim[0], dim[1], dim[2], voltage);

    // Free malloc calls
    free(lines);
    free(data);

    // Return success indicator
    PsychCopyOutDoubleArg(2, FALSE, read==arraySizeInBytes);

    return(PsychError_none);
}