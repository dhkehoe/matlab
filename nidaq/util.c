/*

These functions offer general utilities used by the nidaq sub-functions.

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
*                              UTIL FUNCTIONS                             *                                                                    *
/*************************************************************************/

///////////////////////////////////////////////////////////////////////////
// Give specific (potential) error feedback for SDK command status.
void DAQmxErrChk(int32 functionCall)
{ 
    if( DAQmxFailed(functionCall) )
    {
        // int32 __CFUNC DAQmxGetExtendedErrorInfo(char errorString[], uInt32 bufferSize);
        char errBuff[DEFAULT_STR_BUFFER_SIZE] = {'\0'};
        DAQmxGetExtendedErrorInfo(errBuff, DEFAULT_STR_BUFFER_SIZE); // Retrive error report from NIDAQmx.lib
        
        // Give error (negative functionCall) or warning (positive functionCall) message
        printf("NIDAQmx driver failed with the following error message:\n\n%s\n\n",errBuff);

        // Exit
        if (functionCall < 0) {
            Close();
            PsychErrorExit(PsychError_user);
        }
    }
}

///////////////////////////////////////////////////////////////////////////
// Open the connection to the NI-DAQ. Get device handle. Set defaults.
void Open(void)
{
    // int32 __CFUNC DAQmxCreateTask(const char taskName[], TaskHandle *taskHandle);
    DAQmxErrChk(DAQmxCreateTask("", &taskHandle));
}

///////////////////////////////////////////////////////////////////////////
// Close the connection to the NI-DAQ. Release memory.
void Close(void)
{
    // int32 __CFUNC DAQmxStopTask(TaskHandle taskHandle);
    DAQmxStopTask(taskHandle);

    // int32 __CFUNC DAQmxClearTask(TaskHandle taskHandle);
    DAQmxClearTask(taskHandle);
}

///////////////////////////////////////////////////////////////////////////
// Build necessary data structures for DIO operations
char* buildStrDIO(uInt32* num, uInt32* dim, bool write)
{
    ///////////////////////////////////////////////
    // Ensure data hygene
    size_t m, n, p, numLines;

    // Get port number matrix dimensions
    m = PsychGetArgM(2), n = PsychGetArgN(2), p = PsychGetArgP(2);

    // Check for consistency between port and channel number matrix dimensions
    m = PsychGetArgM(3)==m ? m : 0, n = PsychGetArgN(3)==n ? n : 0, p = PsychGetArgP(3)==p ? p : 0;

    // If writing DIO, check for consistency between port, channel, and status data matrix dimensions
    if (write)
        m = PsychGetArgM(4)==m ? m : 0, n = PsychGetArgN(4)==n ? n : 0, p = PsychGetArgP(4)==p ? p : 0;

    // Check
    numLines = m * n * p;
    if (!numLines)
    {
        // Give detailed error feedback
        printf("Dimension mismatch between arguments %s:\n\tdimension 1...%s\n\tdimension 2...%s\n\tdimension 3...%s\n\n",
               write?"'port', 'channel', and 'state'":"'port' and 'channel'",
               m?"ok":"ERROR", n?"ok":"ERROR", p?"ok":"ERROR");

        // Exit
        PsychErrorExit(PsychError_user);
    }

    ///////////////////////////////////////////////
    // Retrieve device argument
    int dev;
    PsychCopyInIntegerArg(1, TRUE, &dev);

    // Retrieve port argument
    double* port = mxGetPr(PsychGetInArgMxPtr(2));

    // Retrieve channel argument
    double* chan = mxGetPr(PsychGetInArgMxPtr(3));

    // Return number of lines and output dimensions
    *num = numLines;
    dim[0] = m;
    dim[1] = n;
    dim[2] = p;

    // Initialize, write, and return character array
    size_t strSize = snprintf(NULL, 0, DEFAULT_DIO_STR_FMT,0,0,0)+1;
    char* lines = malloc(strSize * numLines);
    for (int i = 0, j = 0; i<numLines; i++)
        j += snprintf(&lines[j], strSize, DEFAULT_DIO_STR_FMT, dev, (int)port[i], (int)chan[i]);

    return(lines);
}

///////////////////////////////////////////////////////////////////////////
// Build necessary data structures for AIO operations
char* buildStrAIO(uInt32* num, bool write)
{
    ///////////////////////////////////////////////
    // Ensure data hygene
    size_t m, n, p, numLines;

    // Get channel number matrix dimensions
    m = PsychGetArgM(2), n = PsychGetArgN(2), p = PsychGetArgP(2);

    // If writing AO, check for consistency between channel and voltage data matrix dimensions
    if (write)
        m = PsychGetArgM(3)==m ? m : 0, n = PsychGetArgN(3)==n ? n : 0, p = PsychGetArgP(3)==p ? p : 0;

    // Check
    numLines = m * n * p;
    if (write && !numLines)
    {
        // Give detailed error feedback
        printf("Dimension mismatch between arguments 'channel' and 'volts':\n\tdimension 1...%s\n\tdimension 2...%s\n\tdimension 3...%s\n\n",
               m?"ok":"ERROR", n?"ok":"ERROR", p?"ok":"ERROR");

        // Exit
        PsychErrorExit(PsychError_user);
    }

    // Retrieve device argument
    int dev;
    PsychCopyInIntegerArg(1, TRUE, &dev);

    // Retrieve port argument
    double* chan = mxGetPr(PsychGetInArgMxPtr(2));

    // Return number of lines and output dimensions
    *num = numLines;
    
    // Get string length for a 1-digital analog pin
    size_t strSize = snprintf(NULL, 0, "dev%d/a%s%d, ",0,write?"o":"i",0)+1;

    // Increment the buffer size for any analog pins with 2-digits
    size_t totalSz = strSize * numLines;
    for (int i = 0, j = 0; i<numLines; i++)
        if (chan[i]>10)
            totalSz++;

    // Initialize, write, and return character array
    char* lines = malloc(totalSz);
    for (int i = 0, j = 0; i<numLines; i++)
        j += snprintf(&lines[j], strSize+(size_t)(chan[i]>10), "dev%d/a%s%d, ", dev,write?"o":"i", (int)chan[i]);

    return(lines);
}

///////////////////////////////////////////////////////////////////////////
// Build necessary data structures for DIO configuration settings
char** buildStrDIOConfig(void)
{
    /* Returns an array of strings dynamically allocated on the heap. As 
    such, the array contains n+1 elements where the final element is a NULL
    pointer. This allows the callee to deallocate the strings by looping
    over them until a NULL pointer is found:

    char** ptr = buildStrDIOConfig(void);
    for (int i = 0; ptr[i]!=NULL; i++) // Unknown length problem solved
        free(ptr[i]); // Deallocate each string
    free(ptr); // The outer array needs to be deallocated also
    */

    // Get DIO configuration function arguments
    int dev, sourcePin, destinPin, i = 0, rows = 2;
    PsychCopyInIntegerArg(1, TRUE, &dev);       // device
    PsychCopyInIntegerArg(2, TRUE, &sourcePin); // source port
    PsychCopyInIntegerArg(3, TRUE, &destinPin); // source channel
    
    // Allocate strings
    size_t strSize = snprintf(NULL, 0, DEFAULT_CONFIG_STR_FMT,0,0)+1;
    char** lines = (char**) malloc(sizeof(char*) * (rows+1));
    for (; i<rows; i++)
        lines[i] = (char*) malloc(sizeof(char) * strSize);
    lines[i] = NULL; // For callee to deallocate

    // Fill/format strings
    sprintf(lines[0], DEFAULT_CONFIG_STR_FMT, dev, sourcePin);
    sprintf(lines[1], DEFAULT_CONFIG_STR_FMT, dev, destinPin);

    return(lines);
}


///////////////////////////////////////////////////////////////////////////
// Build necessary data structures for DO waveform operations
char* buildStrWaveformDO(uInt32* numL, uInt32* numS) // Number of lines, number of samples
{
    ///////////////////////////////////////////////
    // Ensure data hygene
    size_t m, n, p, numLines, numSamps;

    // Get channel number matrix dimensions
    m = PsychGetArgM(3), n = PsychGetArgN(3), p = PsychGetArgP(3);
    
    // Set the number of lines
    numLines = m * n * p;
    
    // Check for consistency between number of channels and rows of waveform matrix
    m = PsychGetArgM(4), n = PsychGetArgN(4);
    if ( m != numLines )
    {
        // Give detailed error feedback
        printf("Dimension mismatch between arguments 'channel' and 'wave':\n\tnumber of elements in 'channel' (%d) must equal the number of rows in matrix 'waveform' (%d).\n\n",
               numLines,m);

        // Exit
        PsychErrorExit(PsychError_user);
    }
    if ( n<2 )
    {
        // Give detailed error feedback
        printf("Bad dimension for argument 'wave':\n\tnumber of columns in matrix 'waveform' (%d) must be at least 2.\n\n",
               n);

        // Exit
        PsychErrorExit(PsychError_user);
    }
    
    // Return number of lines and number of samples
    *numL = numLines;
    *numS = n;
    
    ///////////////////////////////////////////////
    // Retrieve device argument/set port number
    int dev, port = 0;
    PsychCopyInIntegerArg(1, TRUE, &dev);

    // Retrieve channel argument
    double* chan = mxGetPr(PsychGetInArgMxPtr(3));

    // Initialize, write, and return character array
    size_t strSize = snprintf(NULL, 0, DEFAULT_DIO_STR_FMT,0,0,0)+1;
    char* lines = malloc(strSize * numLines);
    for (int i = 0, j = 0; i<numLines; i++)
        j += snprintf(&lines[j], strSize, DEFAULT_DIO_STR_FMT, dev, port, (int)chan[i]);    
    return(lines);
}