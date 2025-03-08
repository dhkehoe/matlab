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

///////////////////////////////////////////////////////////////////////////
// Write user requested pin state to the DIO interface on the NI-DAQ
PsychError WaveformDIO(void)
{
    // Setup online help: 
    static char useString[] = "nidaq('WaveformDIO', device, rate, channel, wave);";
    static char synopsisString[] =
        "Write an arbitrary digital waveform to some subset of DIO channels\n"
        "on port 0 of the NI-DAQ device, with some sampling rate. This\n"
        "functionality is only supported on port 0 channels.\n\n"
        "Args:\n"
        " device - The device number as reported by NI MAX Device Manager.\n"
        "          If unsure, launch NI MAX application, click 'Devices and\n"
        "          Interfaces' and find your device number. E.g., dev1 is\n"
        "          specified with a 1. 'device' must be a scalar integer.\n"
        "   rate - A scalar double indicating the sampling rate of the waveform(s)\n"
        "          in units of Hertz (hz).\n"            
        "channel - Check the pin-out diagram. Pins are specified as port.channel;\n"
        "          e.g., for pin 0.3, 'channel' is specified with a 3.\n"
        "          'channel' can be a matrix with up to 3 dimensions, but the\n"
        "          number of elements must match the number of rows in 'wave'.\n"
        "          In linear order, each value of 'channel' corresponds to a row\n"
        "          in 'wave', where the waveform for that channel is defined.\n"
        "   wave - A matrix with the same number of rows as elements in 'channel'.\n"
        "          Each row specifies the digital waveform for the corresponding\n"
        "          channel. Waveforms are defined along the columns, where non-zero\n"
        "          values set pins high (+5V) and zero values set pins low (0V).\n"
        "          The delay between successive logical states defined across\n"
        "          columns is equal to 1/rate in seconds. The waveform must contain\n"
        "          at least 2 samples, therefore, 'wave' must contain at least 2\n"
        "          columns.\n";
    static char seeAlsoString[] = "WriteDIO";
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
    // get the number of writes, and get the input/output data dimensions
    uInt32 numLines, numSamps;
    char* lines = buildStrWaveformDO(&numLines, &numSamps);
        
    // Allocate enough memory for writing to NI-DAQmx, initialize to zero
    uInt8* data = calloc(numSamps, sizeof(uInt8));

    // Copy user wave data into write array
    double* chan = mxGetPr(PsychGetInArgMxPtr(3));
    double* wave = mxGetPr(PsychGetInArgMxPtr(4));
    for (size_t i = 0, t = 0; i < numSamps; i++) {
        for (size_t j = 0; j < numLines; j++, t++) {            
            data[i] += (uInt8)(wave[t] ? 1<<(int)chan[j] : 0);
        }
    }
    
    // Get the rate parameter
    double rate;
    PsychCopyInDoubleArg(2, TRUE, &rate);
    
    // Initialize task
    Open();

    // Create digital output line
    // int32 __CFUNC DAQmxCreateDOChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
    DAQmxErrChk(DAQmxCreateDOChan(taskHandle, lines, "", DAQmx_Val_ChanForAllLines));

    // Configure the sampling clock
    // int32 __CFUNC DAQmxCfgSampClkTiming(TaskHandle taskHandle, const char source[], float64 rate, int32 activeEdge, int32 sampleMode, uInt64 sampsPerChanToAcquire);
    DAQmxErrChk(DAQmxCfgSampClkTiming(taskHandle, "", rate, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, numSamps));
    
    // Force the output buffer size
    // int32 __CFUNC DAQmxCfgOutputBuffer(TaskHandle taskHandle, uInt32 numSampsPerChan);
    DAQmxErrChk(DAQmxCfgOutputBuffer(taskHandle, numSamps));

    // Write the digital samples
    // int32 __CFUNC DAQmxWriteDigitalU8(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, uInt8 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
    int32 written;
    DAQmxErrChk(DAQmxWriteDigitalU8(taskHandle, numSamps, 0, 10.0, DAQmx_Val_GroupByScanNumber, data, &written, NULL));
    
    // int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxWaitUntilTaskDone(TaskHandle taskHandle, float64 timeToWait)
    DAQmxErrChk(DAQmxWaitUntilTaskDone(taskHandle, 10.0));
    
    // Uninitialize NI-DAQ
    Close();

    // Free malloc calls
    free(lines);
    free(data);

    return(PsychError_none);
}



///////////////////////////////////////////////////////////////////////////
// Read the DIO pin state for some subset of pins, output result to user
PsychError ReadDIO(void)
{
    // Setup online help: 
    static char useString[] = "state = nidaq('ReadDIO', device, port, channel);";
    static char synopsisString[] =
        "Read the digital pin state for some subset of ports/channels on the\n"
        "NI-DAQ system.\n\n"
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
        "          is either high (1) or low (0).\n";
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
    // get the number of reads, and get the input/output data dimensions
    uInt32 arraySizeInBytes, dim[3];
    char* lines = buildStrDIO(&arraySizeInBytes, dim, FALSE);

    // Allocate enough memory for reading from NI-DAQmx
    uInt8* data = malloc(arraySizeInBytes * sizeof(uInt8));

    // Initialize task
    Open();

    // int32 __CFUNC DAQmxCreateDIChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
    DAQmxErrChk(DAQmxCreateDIChan(taskHandle, lines, "", DAQmx_Val_ChanForAllLines));

    // int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxReadDigitalLines(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, uInt8 readArray[], uInt32 arraySizeInBytes, int32 *sampsPerChanRead, int32 *numBytesPerSamp, bool32 *reserved);
	int32 read, bytesPerSamp;
    DAQmxErrChk(DAQmxReadDigitalLines(taskHandle, DEFAULT_SAMPS_PER_CHAN, DEFAULT_TIME_OUT, DAQmx_Val_GroupByChannel, data, arraySizeInBytes, &read, &bytesPerSamp, NULL));
    
    // Uninitialize NI-DAQ
    Close();

    // Give user output
    double* state = (double*)PsychMallocTemp(arraySizeInBytes*sizeof(double));
    for (int i = 0; i < (int)arraySizeInBytes; i++)
        state[i] = (double)(data[i] ? 1 : 0);
    PsychCopyOutDoubleMatArg(1, kPsychArgOptional, dim[0], dim[1], dim[2], state);

    // Free malloc calls
    free(lines);
    free(data);

    return(PsychError_none);
}


///////////////////////////////////////////////////////////////////////////
// Write user requested pin state to the DIO interface on the NI-DAQ
PsychError WriteDIO(void)
{
    // Setup online help: 
    static char useString[] = "nidaq('WriteDIO', device, port, channel, state);";
    static char synopsisString[] =
        "Write the digital pin state for some subset of ports/channels on the\n"
        "NI-DAQ system.\n\n"
        "Args:\n"
        " device - The device number as reported by NI MAX Device Manager.\n"
        "          If unsure, launch NI MAX application, click 'Devices and\n"
        "          Interfaces' and find your device number. E.g., dev1 is\n"
        "          specified with a 1. 'device' must be a scalar integer.\n"
        "   port - Check the pin-out diagram. Pins are specified as port.channel;\n"
        "          e.g., for pin 2.3, 'port' is specified with a 2. 'port'\n"
        "          can be a matrix with up to 3 dimensions. Multiple 'port'\n"
        "          values specifies multiple DIO write operations.\n"
        "channel - Check the pin-out diagram. Pins are specified as port.channel;\n"
        "          e.g., for pin 2.3, 'channel' is specified with a 3.\n"
        "          'channel' can be a matrix with up to 3 dimensions, but the\n"
        "          shape must match between 'port' and 'channel'. Multiple\n"
        "          'channel' values specifies multiple DIO write operations.\n"
        "  state - A matrix with the same shape as 'port' and 'channel' specifying\n"
        "          the digital state of each specified port.channel pin on\n"
        "          the DIO interface. Non-zero values set pins high (+5V),\n"
        "          while zero values set the pin low (0V). Note that reading\n"
        "          a pin on the DIO interface will reset that pin back to 0V\n"
        "          superceding any previously written values.";
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
    // get the number of writes, and get the input/output data dimensions
    uInt32 arraySizeInBytes, dim[3];
    char* lines = buildStrDIO(&arraySizeInBytes, dim, TRUE);

    // Allocate enough memory for writing to NI-DAQmx
    uInt8* data = malloc(arraySizeInBytes * sizeof(uInt8));

    // Copy user state data into write array
    double* state = mxGetPr(PsychGetInArgMxPtr(4));
    for (int i = 0; i < (int)arraySizeInBytes; i++)
        data[i] = (uInt8)(state[i] ? 0xFF : 0);

    // Initialize task
    Open();

    // int32 __CFUNC DAQmxCreateDOChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
    DAQmxErrChk(DAQmxCreateDOChan(taskHandle, lines, "", DAQmx_Val_ChanPerLine));

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxWriteDigitalU8(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const uInt8 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
	int32 written;
    DAQmxErrChk(DAQmxWriteDigitalU8(taskHandle, DEFAULT_SAMPS_PER_CHAN, DEFAULT_WRITE_AUTO_START, DEFAULT_TIME_OUT, DAQmx_Val_ChanPerLine, data, &written, NULL));

    // Uninitialize NI-DAQ
    Close();

    // Free malloc calls
    free(lines);
    free(data);

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Write a user-specified voltage to the NI-DAQ analog interface
PsychError WriteAO(void)
{
    // Setup online help: 
    static char useString[] = "nidaq('WriteAO', device, channel, volts);";
    static char synopsisString[] =
        "Write the analog pin voltage for some subset of channels on the\n"
        "NI-DAQ system.\n\n"
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
    uInt32 arraySizeInBytes;
    char* lines = buildStrAIO(&arraySizeInBytes, TRUE);

    // Allocate enough memory for writing to NI-DAQmx
    float64* data = malloc(arraySizeInBytes * sizeof(float64));

    // Copy user data into data to write array
    double* voltage = mxGetPr(PsychGetInArgMxPtr(3));
    for (int i = 0; i < (int)arraySizeInBytes; i++)
        data[i] = (float64)voltage[i];

    // Initialize task
    Open();

    // int32 __CFUNC DAQmxCreateAOVoltageChan(TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
	DAQmxErrChk(DAQmxCreateAOVoltageChan(taskHandle, lines, "", DEFAULT_AIO_MIN_VAL, DEFAULT_AIO_MAX_VAL, DAQmx_Val_Volts,""));
    // specify a list: Dev1/port0, Dev1/port1/line0:2 

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

	// int32 __CFUNC DAQmxWriteAnalogF64(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const float64 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
    int32 written;
    DAQmxErrChk(DAQmxWriteAnalogF64(taskHandle, DEFAULT_SAMPS_PER_CHAN, DEFAULT_WRITE_AUTO_START, DEFAULT_TIME_OUT, DAQmx_Val_GroupByChannel, data, &written, NULL));

    // Uninitialize NI-DAQ
    Close();

    // Free malloc calls
    free(lines);
    free(data);

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Read a user-specified voltage to the NI-DAQ analog interface
PsychError ReadAI(void)
{
    // Setup online help: 
    static char useString[] = "volts = nidaq('ReadAI', device, channel, config [,reads] );";
    static char synopsisString[] =
        "Read the analog pin voltage for some subset of channels on the\n"
        "NI-DAQ system.\n\n"
        "Args:\n"
        " device - The device number as reported by NI MAX Device Manager.\n"
        "          If unsure, launch NI MAX application, click 'Devices and\n"
        "          Interfaces' and find your device number. E.g., dev1 is\n"
        "          specified with a 1. 'device' must be a scalar integer.\n"
        "channel - Check the pin-out diagram. Pins are specified as 'AI channel';\n"
        "          e.g., for AI 3, 'channel' is specified with a 3.\n"
        "          'channel' can be a vector. Multiple 'channel' values\n"
        "          specifies multiple AI read operations.\n"
        " config - The analog input reference configuration. Constant across\n"
        "          all specified AI channels. Must be a scalar integer value\n"
        "          between 1-4 to indiate\n"
        "               1 - Referenced single-ended mode\n"
        "               2 - Non-referenced single-ended mode\n"
        "               3 - Differential mode\n"
        "               4 - Pseudo-differential mode\n"
        "          For more info, see link <a href=\"https://www.ni.com/docs/en-US/bundle/ni-daqmx/page/measfunds/connectaisigs.html\">ni.com/docs</a>\n"
        "  reads - The number of reads to take from each specified AI channel\n"
        "          at a sampling rate of 10 kHz. Default = 1.\n"
        "Outputs:\n"
        "  volts - A matrix where each row corresponds to an AI pin specified\n"
        "          by argument 'channel' and each column corresponds to a\n"
        "          the i = (1,...,n) reads specified by argument 'reads'.\n"
        "          The values indicate the analog voltage of each queried\n"
        "          channel pin on the AI interface. Voltages are output as\n"
        "          type double and are bound between +/-10 V.";
    static char seeAlsoString[] = "WriteAO, ReadDIO";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(4));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(3)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(1));	 // The maximum number of outputs

    // Check input data integrity, build the AO lines string,
    // get the number of writes, and get the input/ouptput data dimensions
    uInt32 numChan, dim[3], totalArraySize;
    char* lines = buildStrAIO(&numChan, FALSE);
    
    // Get the user requested terminal configuration
    int32 config;
    PsychCopyInIntegerArg(3, TRUE, &config);
    if (config < 1 || 4 < config)
        PsychErrorExitMsg(PsychError_user, "Argument 'config' out of range.");

    // Get the number of reads
    int32 numSampsPerChan;
    if (PsychCopyInIntegerArg(4, kPsychArgOptional, &numSampsPerChan)) {
        if (numSampsPerChan < 1)
            PsychErrorExitMsg(PsychError_user, "Argument 'reads' must be a positive integer.");
    }
    else
    {
        numSampsPerChan = 1;
    }
    totalArraySize = numChan * numSampsPerChan;

    // Allocate enough memory for reading NI-DAQmx
    float64* data = malloc(totalArraySize * sizeof(float64));
   
    // Initialize task
    Open();
    
    // int32 __CFUNC (TaskHandle taskHandle, const char source[], float64 rate, int32 activeEdge, int32 sampleMode, uInt64 sampsPerChanToAcquire)
    DAQmxErrChk(DAQmxCreateAIVoltageChan(taskHandle, lines, "", configs[config-1], DEFAULT_AIO_MIN_VAL, DEFAULT_AIO_MAX_VAL, DAQmx_Val_Volts, NULL));

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxReadAnalogF64(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, float64 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
    int32 read;
    DAQmxErrChk(DAQmxReadAnalogF64(taskHandle, numSampsPerChan, 0.001*totalArraySize, DAQmx_Val_GroupByScanNumber, data, totalArraySize, &read, NULL));

    // Uninitialize NI-DAQ
    Close();

    // Copy read data into voltag array and send back to user
    double* voltage = (double*)PsychMallocTemp(totalArraySize*sizeof(double));
    for (int i = 0; i < (int)totalArraySize; i++)
        if (i+1 <= read*numChan)
            voltage[i] = (double)(data[i]);
        else
            voltage[i] = NaN;
    PsychCopyOutDoubleMatArg(1, kPsychArgOptional, numChan, numSampsPerChan, 0, voltage);

    // Free malloc calls
    free(lines);
    free(data);

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Connect the DIO pin state for a pair of pins
PsychError ConnectDIO(void)
{
    // Setup online help: 
    static char useString[] = "nidaq('ConnectDIO', device, sourcePFI, destinationPFI);";
    static char synopsisString[] =
        "Connect the digital pin state for a pair of DIO pins on the NI-DAQ\n"
        "system for passthrough. That is, if you send a +5V TTL to the 'sourcePFI'\n"
        "pin, then the 'destinationPFI' pin will also go high to +5V.\n\n"
        "Args:\n"
        "        device - The device number as reported by NI MAX Device Manager. If\n"
        "                 unsure, launch NI MAX application, click 'Devices and\n"
        "                 Interfaces' and find your device number. E.g., dev1 is\n"
        "                 specified with a 1. 'device' must be a scalar.\n"
        "     sourcePFI - The PFI number for the source pin in the connected pair of\n"
        "                 pins. Check the pin-out diagram. Pins are specified as\n"
        "                 PFI / port.channel; e.g., for pin PFI 11 / P2.3, 'sourcePFI' is\n"
        "                 specified with an 11. 'sourcePFI' must be a scalar.\n"
        "destinationPFI - The PFI number for the destination pin in the connected pair\n"
        "                 of pins. Check the pin-out diagram. Pins are specified as\n"
        "                 PFI / port.channel; e.g., for pin PFI 0 / P1.0,\n"
        "                 'destinationPFI' is specified with a 0. 'destinationPFI' must\n"
        "                 be a scalar.\n";
    static char seeAlsoString[] = "DisconnectDIO";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(3));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(3)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs
    
    // Build the DIO configuration line strings
    char** lines = buildStrDIOConfig();

    // int32 __CFUNC DAQmxConnectTerms (const char sourceTerminal[], const char destinationTerminal[], int32 signalModifiers);
    // DAQmxErrChk(DAQmxConnectTerms("/Dev3/PFI0", "/Dev3/PFI8", DAQmx_Val_DoNotInvertPolarity));
    DAQmxErrChk(DAQmxConnectTerms(lines[0], lines[1], DAQmx_Val_DoNotInvertPolarity));
            
    // Free malloc calls
    for (int i = 0; lines[i]!=NULL; i++)
        free(lines[i]);
    free(lines);

    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Disconnect the DIO pin state for a pair of connected pins
PsychError DisconnectDIO(void)
{
    // Setup online help: 
    static char useString[] = "nidaq('DisconnectDIO', device, sourcePFI, destinationPFI);";
    static char synopsisString[] =
        "Disconnect the digital pin state for a pair of previously connected\n"
        "DIO pins on the NI-DAQ system for passthrough. That is, if you send\n"
        "+5V to the 'sourcePFI' pin, this will no longer affect the state of\n"
        "the 'destinationPFI' pin.\n\n"
        "Args:\n"
        "        device - The device number as reported by NI MAX Device Manager. If\n"
        "                 unsure, launch NI MAX application, click 'Devices and\n"
        "                 Interfaces' and find your device number. E.g., dev1 is\n"
        "                 specified with a 1. 'device' must be a scalar.\n"
        "     sourcePFI - The PFI number for the source pin in the connected pair of\n"
        "                 pins. Check the pin-out diagram. Pins are specified as\n"
        "                 PFI / port.channel; e.g., for pin PFI 11 / P2.3, 'sourcePFI' is\n"
        "                 specified with an 11. 'sourcePFI' must be a scalar.\n"
        "destinationPFI - The PFI number for the destination pin in the connected pair\n"
        "                 of pins. Check the pin-out diagram. Pins are specified as\n"
        "                 PFI / port.channel; e.g., for pin PFI 0 / P1.0,\n"
        "                 'destinationPFI' is specified with a 0. 'destinationPFI' must\n"
        "                 be a scalar.\n";
    static char seeAlsoString[] = "ConnectDIO";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(3));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(3)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs
    
    // Build the DIO configuration line strings
    char** lines = buildStrDIOConfig();

    // int32 __CFUNC DAQmxConnectTerms (const char sourceTerminal[], const char destinationTerminal[], int32 signalModifiers);
    DAQmxErrChk(DAQmxDisconnectTerms(lines[0], lines[1]));
            
    // Free malloc calls
    for (int i = 0; lines[i]!=NULL; i++)
        free(lines[i]);
    free(lines);
    
    return(PsychError_none);
}

///////////////////////////////////////////////////////////////////////////
// Disconnect the DIO pin state for a pair of connected pins
PsychError Reset(void)
{
    // Setup online help: 
    static char useString[] = "nidaq('Reset', device);";
    static char synopsisString[] =
        "Immediately aborts all tasks associated with the NI-DAQ device and\n"
        "returns the device to an initialized state.\n\n"
        "Args:\n"
        "        device - The device number as reported by NI MAX Device Manager. If\n"
        "                 unsure, launch NI MAX application, click 'Devices and\n"
        "                 Interfaces' and find your device number. E.g., dev1 is\n"
        "                 specified with a 1. 'device' must be a scalar.\n";
    static char seeAlsoString[] = "";

	PsychPushHelp(useString, synopsisString, seeAlsoString);

	if(PsychIsGiveHelp()) {
		PsychGiveHelp();
		return(PsychError_none);
	}

    // Check arguments
    PsychErrorExit(PsychCapNumInputArgs(1));     // The maximum number of inputs
	PsychErrorExit(PsychRequireNumInputArgs(1)); // The required number of inputs	
	PsychErrorExit(PsychCapNumOutputArgs(0));	 // The maximum number of outputs

    // Get device argument
    int dev;
    PsychCopyInIntegerArg(1, TRUE, &dev);
    
    // Create device string
    size_t strSize = snprintf(NULL, 0, "Dev%d", dev)+1;
    char* devStr = malloc(strSize);
    snprintf(devStr, strSize, "Dev%d", dev);
    
    // int32 __CFUNC DAQmxResetDevice (const char deviceName[]);
    DAQmxErrChk(DAQmxResetDevice(devStr));
    
    // Free the device string
    free(devStr);
    
    return(PsychError_none);
}