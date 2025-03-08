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

// Import C libraries
#include <stdlib.h>
#include <stdio.h>

#include <NIDAQmx.h>    // NI-DAQmx SDK
#include <mex.h>        // Matlab MEX API
#include "Psych.h"      // PTB API
#include <math.h>       // Use this for NaN values

/**************************************************************************
*                          GLOBAL SCOPE VARIABLES                         *
/*************************************************************************/

#define DEFAULT_TIME_OUT            0.0     // Read/write immediately
#define DEFAULT_SAMPS_PER_CHAN      1       // Used for DIO and AO
#define DEFAULT_AI_SAMP_READS       10000   // Used for AI
#define DEFAULT_WRITE_AUTO_START    1

#define DEFAULT_DIO_STR_FMT         "dev%d/port%d/line%d, "     // strlen(DEFAULT_DIO_STR_FMT) == 18
#define DEFAULT_CONFIG_STR_FMT      "/Dev%d/PFI%d"

#define DEFAULT_AIO_MIN_VAL         -10.0
#define DEFAULT_AIO_MAX_VAL         10.0

#define DEFAULT_STR_BUFFER_SIZE     2048

TaskHandle taskHandle;   // Handle to generic NI-DAQmx tasks (no buffering required)

static int32 configs[4] = { DAQmx_Val_RSE, DAQmx_Val_NRSE, DAQmx_Val_Diff, DAQmx_Val_PseudoDiff }; // { Referenced single-ended mode, Non-referenced single-ended mode, Differential mode, Pseudodifferential mode }

static double NaN = 0.0/0.0;

/**************************************************************************
*                               FUNCTIONS                                 *
/*************************************************************************/

// Utilities
void DAQmxErrChk(int32);
void Open(void);
void Close(void);
char* buildStrDIO(uInt32*, uInt32*, bool);
char* buildStrAIO(uInt32*, bool);
char** buildStrDIOConfig(void);
char* buildStrWaveformDO(uInt32*, uInt32*);

// Initialization routines
void InitializeSynopsis(void);
PsychError MODULEVersion(void);
PsychError PsychModuleInit(void);
PsychError PsychDisplaySynopsis(void);

//////////////////////////////////////////////////////////////////////////
// nidaq target sub-commands

// Read/write
PsychError WaveformDIO(void);
PsychError ReadDIO(void);
PsychError WriteDIO(void);
PsychError WriteAO(void);
PsychError ReadAI(void);

// Connect/disconnect
PsychError ConnectDIO(void);
PsychError DisconnectDIO(void);

// Device reset
PsychError Reset(void);

#endif