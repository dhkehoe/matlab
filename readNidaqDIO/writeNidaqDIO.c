/*
Function to set the Digital IO state of a specific pin on a NIDAQ board.

Usage:
    readNidaqDIO(deviceNumber, portNumber, channelNumber, state)

Input:
     deviceNumber - The device number reported by NI MAX Device Manager. If
                    unsure, launch NI MAX application, click 'Devices and
                    Interfaces', and find your device number. E.g., dev1 is
                    specified with a 1.
       portNumber - Check the pin-out diagram. Pins are specified as
                    portNumber.channelNumber; e.g., for pin 2.3, portNumber
                    is specified with a 2.
    channelNumber - Check the pin-out diagram. Pins are specified as
                    portNumber.channelNumber; e.g., for pin 2.3, 
                    channelNumber is specified with a 3.
            state - A value to set the pin state high or low. A value >= 1
                    will set the pin high (+5V TTL). A value < 1 will set
                    the pin low (0 V TTL).

Exceptions:
    For any driver errors, throws an exception in the MATLAB environment 
    with a detailed error report.



COMPILATION INSTRUCTIONS:

Must compile under MSVC. To verify, type
    mex -setup
in the MATLAB Command Window. You must see
    MEX configured to use 'Microsoft Visual C++ 20xx (C)' for C language compilation.
where 20xx can be 2015-2022.

Must also have NI-DAQmx driver installed. See
    https://www.ni.com/en-ca/support/downloads/drivers/download.ni-daq-mx.html

To compile nidaq.mexw64, execute these exact compilation instructions in
the MATLAB Command Window:
    mex writeNidaqDIO.c nidaqmx.lib -L'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\lib64\msvc' -I'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\include'



    Author: Devin H. Kehoe, devin.heinz.kehoe@umontreal.ca
      Date: July 17th, 2023
*/

#include <stdio.h>
#include <NIDAQmx.h>
#include "mex.h"

#define DEFAULT_STR_BUFFER_SIZE     2048

#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Ensure data hygene
    if (nrhs<4)
        mexErrMsgIdAndTxt("nidaq:inputError","Four integer inputs required: nidaq(device, port, channel, state)");

    // Convert from wacky mex types into c types
    int dev = (int)(mxGetScalar(prhs[0])),
       chan = (int)(mxGetScalar(prhs[1])),
       line = (int)(mxGetScalar(prhs[2]));
    uInt32 data = ((uInt32)(mxGetScalar(prhs[3]))) * 0xffffffff;
    
    // Convert integer inputs into a string formatted for NIDAQmx.lib Digital IO functions
    size_t strSize = snprintf(NULL, 0, "Dev%d/port%d/line%d", dev, chan, line);
    char* lines = malloc(strSize);
    sprintf(lines, "Dev%d/port%d/line%d", dev, chan, line);
    

    /********************
    *   NIDAQmx.lib     *
    *********************/
    
    TaskHandle	taskHandle;
	char        errBuff[DEFAULT_STR_BUFFER_SIZE]={'\0'};
	int32		written, error;
    
    // int32 __CFUNC DAQmxCreateTask(const char taskName[], TaskHandle *taskHandle);
	DAQmxErrChk(DAQmxCreateTask("", &taskHandle));
    
    // int32 __CFUNC DAQmxCreateDOChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
    DAQmxErrChk(DAQmxCreateDOChan(taskHandle, lines, "", DAQmx_Val_ChanPerLine));

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxWriteDigitalU32(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const uInt32 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
	DAQmxErrChk(DAQmxWriteDigitalU32(taskHandle, 1, 1, 10.0, DAQmx_Val_ChanPerLine, &data, &written, NULL));

    
    /*********************
    *   Exit routine     *
    **********************/
    Error: // Skip to here if there's an error in any of the NIDAQmx functions
    
    // Close hardware
    if( taskHandle!=0 ) {
        // int32 __CFUNC DAQmxStopTask(TaskHandle taskHandle);
        DAQmxStopTask(taskHandle);

        // int32 __CFUNC DAQmxClearTask(TaskHandle taskHandle);
        DAQmxClearTask(taskHandle);
    }
    
    // Something has failed...
    if( DAQmxFailed(error) ) {

        // int32 __CFUNC DAQmxGetExtendedErrorInfo(char errorString[], uInt32 bufferSize);
        DAQmxGetExtendedErrorInfo(errBuff, DEFAULT_STR_BUFFER_SIZE); // Retrive error report from NIDAQmx.lib

        // Format a detailed MATLAB error
        char matlabErrStr[DEFAULT_STR_BUFFER_SIZE];
        sprintf(matlabErrStr, "NIDAQ device failure.\n\nDigital IO write: %s\n\n%s\n", lines, errBuff);
        strcpy(errBuff,matlabErrStr);
    }

    free(lines); // Release malloc string
    
    // Throw the error if necessary
    if( DAQmxFailed(error) )
        mexErrMsgIdAndTxt("nidaq:deviceFailure", errBuff);
}
