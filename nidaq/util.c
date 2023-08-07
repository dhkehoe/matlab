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
        
        // Give error message
        printf("NIDAQmx driver failed with the following error message:\n\n%s\n\n",errBuff);

        // Exit
        PsychErrorExit(PsychError_user);
    }
}


///////////////////////////////////////////////////////////////////////////
// Print connection status of i1 DisplayPro to console
void PrintConnectionStatus(void)
{
    if (connected)
    { 
        printf("NI-DAQ connection: open\n");
    }
    else
    {
        printf("NI-DAQ connection: closed\n");
    }
}

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
               write?"'port', 'channel', and 'status'":"'port' and 'channel'",
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

char* buildStrAIO(uInt32* num, uInt32* dim, bool write)
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
    dim[0] = m;
    dim[1] = n;
    dim[2] = p;

    // Initialize, write, and return character array
    size_t strSize = snprintf(NULL, 0, "dev%d/a%s%d, ",0,write?"o":"i",0)+1;
    char* lines = malloc(strSize * numLines);
    for (int i = 0, j = 0; i<numLines; i++)
        j += snprintf(&lines[j], strSize, "dev%d/a%s%d, ", dev,write?"o":"i", (int)chan[i]);

    return(lines);
}