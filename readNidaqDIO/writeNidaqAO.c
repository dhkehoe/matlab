/*
Function to set the Analog Output voltage of a specific pin on a NIDAQ board.

Usage:
    readNidaqAO(deviceNumber, channelNumber, voltage)

Input:
     deviceNumber - The device number reported by NI MAX Device Manager. If
                    unsure, launch NI MAX application, click 'Devices and
                    Interfaces', and find your device number. E.g., dev1 is
                    specified with a 1.
    channelNumber - Check the pin-out diagram. Pins are specified by
                    channelNumber; e.g., for AO channel 1, see AO 1.
          voltage - A voltage to set the pin state specified as a floating
                    point. Must be in the range of (-5.0, 5.0).

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
    mex writeNidaqAO.c nidaqmx.lib -L'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\lib64\msvc' -I'C:\Program Files (x86)\National Instruments\Shared\ExternalCompilerSupport\C\include'



    Author: Devin H. Kehoe, devin.heinz.kehoe@umontreal.ca
      Date: July 20th, 2023
*/

#include "mex.h"
#include "NIDAQmx.h"
#include <stdio.h>

#define DEFAULT_STR_BUFFER_SIZE     2048

#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    // Ensure data hygene
    if (nrhs<3)
        mexErrMsgIdAndTxt("nidaq:inputError","Three inputs required: nidaq(device, channel, voltage)");
    
    // Convert from wacky mex types into c types
    int dev = (int)(mxGetScalar(prhs[0])),
       line = (int)(mxGetScalar(prhs[1]));
    float64 data[1] = { (double)mxGetScalar(prhs[2]) };

    // Convert integer inputs into a string formatted for NIDAQmx.lib Digital IO functions
    size_t strSize = snprintf(NULL, 0, "Dev%d/ao%d", dev, line);
    char* lines = malloc(strSize);
    sprintf(lines, "Dev%d/ao%d", dev, line);


    /********************
    *   NIDAQmx.lib     *
    *********************/
	TaskHandle	taskHandle;
	char		errBuff[DEFAULT_STR_BUFFER_SIZE]={'\0'};
	int			error;

	// int32 __CFUNC DAQmxCreateTask(const char taskName[], TaskHandle *taskHandle);
	DAQmxErrChk(DAQmxCreateTask("",&taskHandle));

    // int32 __CFUNC DAQmxCreateAOVoltageChan(TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
	DAQmxErrChk(DAQmxCreateAOVoltageChan(taskHandle,"Dev2/ao0","",-10.0,10.0,DAQmx_Val_Volts,""));
    // specify a list: Dev1/port0, Dev1/port1/line0:2 

	// int32 __CFUNC DAQmxStartTask(TaskHandle taskHandle);
	DAQmxErrChk(DAQmxStartTask(taskHandle));

	// int32 __CFUNC DAQmxWriteAnalogF64(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const float64 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
    DAQmxErrChk (DAQmxWriteAnalogF64(taskHandle,1,1,10.0,DAQmx_Val_GroupByChannel,data,NULL,NULL));

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