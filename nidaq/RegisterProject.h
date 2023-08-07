/* 

Contains all headers for toolbox. Must define "RegisterProject" by PsychToolbox API convention. 
  
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

/**************************************************************************
                              HEADERS/MACROS
/*************************************************************************/

#ifndef PSYCH_IS_INCLUDED_RegisterProject
#define PSYCH_IS_INCLUDED_RegisterProject

// Silly workaround for importing <timeapi.h> from Windows API:
#ifdef RMT_PLATFORM_WINDOWS
typedef long NTSTATUS;
#include <Windows.h>
#include <timeapi.h>
#pragma comment(lib, "Winmm.lib")
#pragma comment(lib, "ws2_32.lib")
#endif


#include <stdio.h>

#include <NIDAQmx.h>    // NI-DAQmx SDK
#include <mex.h>        // Matlab MEX API
#include "Psych.h"      // PTB API


/**************************************************************************
*                          GLOBAL SCOPE VARIABLES                         *
/*************************************************************************/

#define DEFAULT_TIME_OUT            0.0 // Read/write immediately
#define DEFAULT_SAMPS_PER_CHAN      1
#define DEFAULT_WRITE_AUTO_START    1

#define DEFAULT_DIO_STR_FMT         "dev%d/port%d/line%d, "     // strlen(DEFAULT_DIO_STR_FMT) == 18
  
#define DEFAULT_AIO_MIN_VAL          -10.0
#define DEFAULT_AIO_MAX_VAL          10.0

#define DEFAULT_STR_BUFFER_SIZE     2048

TaskHandle  taskHandle; // Handle to NI-DAQmx

bool connected; // Is the NI-DAQ connection established?

static int32 configs[4] = { DAQmx_Val_RSE, DAQmx_Val_NRSE, DAQmx_Val_Diff, DAQmx_Val_PseudoDiff }; // { Referenced single-ended mode, Non-referenced single-ended mode, Differential mode, Pseudodifferential mode }

/**************************************************************************
*                               FUNCTIONS                                 *
/*************************************************************************/

// Utilities
void DAQmxErrChk(int32);
void Open(void);
void Close(void);
void StatusChecker(void);
void PrintConnectionStatus(void);
void InitializeSynopsis(void);
char* buildStrDIO(uInt32*, uInt32*, bool);
char* buildStrAIO(uInt32*, uInt32*, bool);

// Initialization routines
PsychError MODULEVersion(void);
PsychError PsychModuleInit(void);
PsychError PsychDisplaySynopsis(void);

//////////////////////////////////////////////////////////////////////////
// nidaq target sub-commands

// Connection
PsychError Initialize(void);
PsychError Uninitialize(void);
PsychError IsInitialized(void);

// Read/write
PsychError ReadDIO(void);
PsychError WriteDIO(void);
PsychError WriteAO(void);
PsychError ReadAI(void);

#endif