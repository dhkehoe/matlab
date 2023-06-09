/*
Function to query the Digital IO state of a specific pin on a NIDAQ board.

Usage:
    nidaq(deviceNumber, portNumber, channelNumber)

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

Returns:
    1 for high, 0 for low.

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
    mex nidaq.c nidaqmx.lib -L'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\lib64\msvc' -I'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\include'



    Author: Devin H. Kehoe, devin.heinz.kehoe@umontreal.ca
      Date: March 7th, 2023
*/

#include "mex.h"
#include "NIDAQmx.h"
#include <stdio.h>

#define READ_ARRAY_SIZE_IN_BYTES    (uInt32)1
#define DEFAULT_STR_BUFFER_SIZE     2048
#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Ensure data hygene
    if (nrhs<3)
        mexErrMsgIdAndTxt("nidaq:inputError","Three integer inputs required: nidaq(device, port, channel)");

    // Convert from wacky mex types into c types
    int dev =   (int)(mxGetScalar(prhs[0])),    chan = (int)(mxGetScalar(prhs[1])),     line = (int)(mxGetScalar(prhs[2]));

    // Convert integer inputs into a string formatted for NIDAQmx.lib Digital IO functions
    size_t strSize = snprintf(NULL, 0, "Dev%d/port%d/line%d", dev, chan, line);
    char* lines = malloc(strSize);
    sprintf(lines, "Dev%d/port%d/line%d", dev, chan, line);


    /********************
    *   NIDAQmx.lib     *
    *********************/
    TaskHandle  taskHandle;
    char        errBuff[DEFAULT_STR_BUFFER_SIZE] = {'\0'};
    uInt8       data[READ_ARRAY_SIZE_IN_BYTES];
    int32       read, bytesPerSamp, error = 0;

    // int32 __CFUNC DAQmxCreateTask(const char taskName[], TaskHandle *taskHandle);
    DAQmxErrChk(DAQmxCreateTask("", &taskHandle));

    // int32 __CFUNC DAQmxCreateDIChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
    DAQmxErrChk(DAQmxCreateDIChan(taskHandle, lines, "", DAQmx_Val_ChanForAllLines));

    // int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

    // int32 __CFUNC DAQmxReadDigitalLines(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, uInt8 readArray[], uInt32 arraySizeInBytes, int32 *sampsPerChanRead, int32 *numBytesPerSamp, bool32 *reserved);
	DAQmxErrChk(DAQmxReadDigitalLines(taskHandle, 1, 10.0, DAQmx_Val_GroupByChannel, data, READ_ARRAY_SIZE_IN_BYTES, &read, &bytesPerSamp, NULL));


    /*********************
    *   Exit routine     *
    **********************/
    Error: // Skip to here if there's an error in any of the NIDAQmx functions

    // Close hardware query
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
        sprintf(matlabErrStr, "NIDAQ device failure.\n\nDigital IO query: %s\n\n%s\n", lines, errBuff);
        strcpy(errBuff,matlabErrStr);
    }

    // No error
    else {

        // Return the NIDAQ data to the MATLAB environment
        plhs[0] = mxCreateDoubleMatrix(1, READ_ARRAY_SIZE_IN_BYTES, mxDOUBLE_CLASS); // initialize output
        for (int i = 0; i<READ_ARRAY_SIZE_IN_BYTES; i++)
            mxGetPr(plhs[0])[i] = (double)data[i]; // copy in data
        //printf("Data acquired, 0x%X\n",data[0]);
    }

    free(lines); // Release malloc string

    // Throw the error if necessary
    if( DAQmxFailed(error) )
        mexErrMsgIdAndTxt("nidaq:deviceFailure", errBuff);
}