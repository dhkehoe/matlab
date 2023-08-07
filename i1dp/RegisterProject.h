/* 

Contains all headers for toolbox. Must define "RegisterProject" by PsychToolbox API convention. 
  
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

#include "i1d3SDK.h" // X-Rite SDK
#include "mex.h" // Matlab MEX API
#include "Psych.h" // PTB API


/**************************************************************************
*                          GLOBAL SCOPE VARIABLES                         *
/*************************************************************************/

#define DEFAULT_REFRESH 120
#define DEFAULT_MEAS_MODE i1d3MeasModeAIO
#define KEEP_LED_ON_INDEFINITELY (unsigned char) 255

i1d3Handle devHndl; // Handle to i1 device

bool connected; // Is the i1 connection established?
bool isAIO; // Does it support the AIO measurement mode?


/**************************************************************************
*                               FUNCTIONS                                 *
/*************************************************************************/

// Initialization routines
PsychError MODULEVersion(void);
PsychError PsychModuleInit(void);
PsychError PsychDisplaySynopsis(void);

// Utilities
void Open(void);
void Close(void);
void InitializeSynopsis(void);
void StatusChecker(i1d3Status_t statusIn);
void UpdateConnectionStatus(void);
void PrintConnectionStatus(void);
int IsBackLightStable(void);



//////////////////////////////////////////////////////////////////////////
// i1dp target sub-commands

// Connection
PsychError Initialize(void);
PsychError Uninitialize(void);
PsychError IsConnected(void);

// Info
PsychError GetDeviceInfo(void);

// Get/set
PsychError SetMeasurementMode(void);
PsychError GetMeasurementMode(void);
PsychError SetLuminanceUnits(void);
PsychError GetLuminanceUnits(void);
PsychError SetMeasurementTime(void);
PsychError GetMeasurementTime(void);
PsychError SetBacklightFreq(void);
PsychError GetBacklightFreq(void);
PsychError SetBacklightSyncMode(void);
PsychError GetBacklightSyncMode(void);

// Measurements
PsychError MeasureYxy(void);
PsychError MeasureXYZ(void);
PsychError MeasureRGB(void);
PsychError StableBacklight(void);
PsychError DiffuserPosition(void);


#endif