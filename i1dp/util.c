/*

These functions offer general utilities used by the i1dp sub-functions.

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

#include "RegisterProject.h" // Port custom project into PTB API


/**************************************************************************
*                              UTIL FUNCTIONS                             *                                                                    *
/*************************************************************************/

///////////////////////////////////////////////////////////////////////////
// Give specific (potential) error feedback for SDK command status.
void StatusChecker(i1d3Status_t status)
{
    if (status!=i1d3Success) // Give specific error report and exit .mex
    {
        printf("\ni1 Display Pro critical failure! Error type  %d\n",(int)status);

        switch (status)
        {
            // Initialization errors
            case i1d3Err:
                PsychErrorExitMsg(PsychError_user, "Nonspecific error.\n");
                break;
            case i1d3ErrInvalidDevicePtr:
                PsychErrorExitMsg(PsychError_user, "Ensure that you have initialized the device with i1dp('Initialize')!\n");
                break;
            case i1d3ErrNoDeviceFound:
                PsychErrorExitMsg(PsychError_user, "No i1 Display Pro detected! Check USB connection.\n");
                break;

            // Errors passed through from calibrator class
            case i1d3ErrFunctionNotAvailable:
                PsychErrorExitMsg(PsychError_user, "The requested Function is not supported by this device.\n");
                break;
            case i1d3ErrLockedCalibrator:
                PsychErrorExitMsg(PsychError_user, "The device is password-locked.\n");
                break;
            case i1d3ErrCalibratorAlreadyOpen:
                PsychErrorExitMsg(PsychError_user, "The device is currently initialized.\n");
                break;
            case i1d3ErrCalibratorNotOpen:
                PsychErrorExitMsg(PsychError_user, "No device is currently initialized.\n");
                break;
            case i1d3ErrTransactionError:
                PsychErrorExitMsg(PsychError_user, "The USB communications are out of sync.\n");
                break;
            case i1d3ErrWrongDiffuserPosition:
                PsychErrorExitMsg(PsychError_user, "The diffuser arm is in the wrong position for measurement.\n");
                break;
            case i1d3ErrIncorrectChecksum:
                PsychErrorExitMsg(PsychError_user, "The calculated checksum is incorrect.\n");
                break;
            case i1d3ErrInvalidParameter:
                PsychErrorExitMsg(PsychError_user, "An invalid parameter was passed into the routine.\n");
                break;
            case i1d3ErrCalibratorError:
                PsychErrorExitMsg(PsychError_user, "The device returned an error.\n");
                break;
            case i1d3ErrObsoleteFirmware:
                PsychErrorExitMsg(PsychError_user, "The firmware is obsolete.\n");
                break;
            case i1d3ErrCouldNotEnterBLMode:
                PsychErrorExitMsg(PsychError_user, "Error entering bootloader mode.\n");
                break;
            case i1d3ErrUSBTimeout:
                PsychErrorExitMsg(PsychError_user, "USB timed out waiting for response from device.\n");
                break;
            case i1d3ErrUSBCommError:
                PsychErrorExitMsg(PsychError_user, "USB communication error.\n");
                break;
            case i1d3ErrEEPROMWriteProtected:
                PsychErrorExitMsg(PsychError_user, "EEPROM-write protection error.\n");
                break;

            // Errors passed through from matrix generator class
            case i1d3ErrMGBadFile:
                PsychErrorExitMsg(PsychError_user, "Couldn't open MG file.\n");
                break;
            case i1d3ErrMGTooFewColors:
                PsychErrorExitMsg(PsychError_user, "MG file must specify at least 3 colors.\n");
                break;
            case i1d3ErrMGBadWavelengthIncrement:
                PsychErrorExitMsg(PsychError_user, "MG file must specify 1nm wavelength increment.\n");
                break;
            case i1d3ErrMGBadWavelengthEnd:
                PsychErrorExitMsg(PsychError_user, "MG file must specify wavelength <= 730nm.\n");
                break;
            case i1d3ErrMGBadWavelengthStart:
                PsychErrorExitMsg(PsychError_user, "MG file must specify wavelength >= 380nm.\n");
                break;
            case i1d3ErrNoCMFFile:
                PsychErrorExitMsg(PsychError_user, "Couldn't open CMF data file.\n");
                break;
            case i1d3ErrCMFFormatError:
                PsychErrorExitMsg(PsychError_user, "Couldn't parse CMF data file.\n");
                break;

            // Errors passed through from EDR Support class
            case i1d3ErrEDRFileNotOpen:
                PsychErrorExitMsg(PsychError_user, "Must open EDR file before making other requests.\n");
                break;
            case i1d3ErrEDRFileAlreadyOpen:
                PsychErrorExitMsg(PsychError_user, "EDR file was already opened. Close it to open another file.\n");
                break;
            case i1d3ErrEDRFileNotFound:
                PsychErrorExitMsg(PsychError_user, "EDR file was not found.\n");
                break;
            case i1d3ErrEDRSizeError:
                PsychErrorExitMsg(PsychError_user, "EDR file is too short.\n");
                break;
            case i1d3ErrEDRHeaderError:
                PsychErrorExitMsg(PsychError_user, "EDR header didn't have correct signature or file is too short.\n");
                break;
            case i1d3ErrEDRDataError:
                PsychErrorExitMsg(PsychError_user, "EDR file data didn't load properly.\n");
                break;
            case i1d3ErrEDRDataSignatureError:
                PsychErrorExitMsg(PsychError_user, "EDR file signature mismatch - corrupted file?.\n");
                break;
            case i1d3ErrEDRSpectralDataSignatureError:
                PsychErrorExitMsg(PsychError_user, "EDR file signature mismatch for spectral data - corrupted file?.\n");
                break;
            case i1d3ErrEDRIndexTooHigh:
                PsychErrorExitMsg(PsychError_user, "EDR file has requested more color data than is available.\n");
                break;
            case i1d3ErrEDRNoYxyData:
                PsychErrorExitMsg(PsychError_user, "EDR file can't request tri-stimulus.\n");
                break;
            case i1d3ErrEDRNoSpectralData:
                PsychErrorExitMsg(PsychError_user, "EDR file can't request spectral data from file without spectral data.\n");
                break;
            case i1d3ErrEDRNoWavelengthData:
                PsychErrorExitMsg(PsychError_user, "No spectral data in EDR file.\n");
                break;
            case i1d3ErrEDRFixedWavelengths:
                PsychErrorExitMsg(PsychError_user, "Evenly-spaced wavelengths specified in EDR file.\n");
                break;
            case i1d3ErrEDRWavelengthTable:
                PsychErrorExitMsg(PsychError_user, "Wavelengths specified in EDR file are from table.\n");
                break;
            case i1d3ErrEDRParameterError:
                PsychErrorExitMsg(PsychError_user, "NULL pointer during invocation of EDR file.\n");
                break;

            // Errors returned from i1Display3 devices
            case i1d3ErrHW_Locked:
                PsychErrorExitMsg(PsychError_user, "i1Display3 is Locked.\n");
                break;
            case i1d3ErrHW_I2CLowClock:
                PsychErrorExitMsg(PsychError_user, "EEPROM access error: clock is low.\n");
                break;
            case i1d3ErrHW_NACKReceived:
                PsychErrorExitMsg(PsychError_user, "EEPROM access error: NACK received.\n");
                break;
            case i1d3ErrHW_EEAddressInvalid:
                PsychErrorExitMsg(PsychError_user, "Invalid EEPROM address.\n");
                break;
            case i1d3ErrHW_InvalidCommand:
                PsychErrorExitMsg(PsychError_user, "Invalid command to i1Display3.\n");
                break;
            case i1d3ErrHW_WrongDiffuserPosition:
                PsychErrorExitMsg(PsychError_user, "Diffuser is in wrong positon for measurement.\n");
                break;

            // Errors returned from i1Display3 Rev. B devices / i1d3DC devices
            case i1d3ErrHW_InvalidParameter:
                PsychErrorExitMsg(PsychError_user, "Invalid parameter passed to device.\n");
                break;
            case i1d3ErrHW_PeriodeTimeOut:
                PsychErrorExitMsg(PsychError_user, "Period measurement timed out.\n");
                break;
            case i1d3ErrHW_InvalidMeasurement:
                PsychErrorExitMsg(PsychError_user, "No valid measurement data for get Yxy function.\n");
                break;
            case i1d3ErrHW_MatrixChecksum:
                PsychErrorExitMsg(PsychError_user, "Matrix is missing or corrupt.\n");
                break;
            case i1d3ErrHW_MatrixAmbient:
                PsychErrorExitMsg(PsychError_user, "Ambient matrix is missing or corrupt.\n");
                break;
        }
    }
}

///////////////////////////////////////////////////////////////////////////
// Update connection status of i1 DisplayPro to console
void UpdateConnectionStatus(void)
{
    connected = devHndl != NULL;
}

///////////////////////////////////////////////////////////////////////////
// Print connection status of i1 DisplayPro to console
void PrintConnectionStatus(void)
{
    UpdateConnectionStatus();
    if (connected)
    { 
        printf("i1 DisplayPro connection: open\n");
    }
    else
    {
        printf("i1 DisplayPro connection: closed\n");
    }
}

///////////////////////////////////////////////////////////////////////////
// Check whether there is a periodicity to the light source
int IsBackLightStable(void)
{
    unsigned short unstable;
    StatusChecker(i1d3MeasureBacklightFrequency(devHndl, &unstable));
    return ((int)(!unstable));
}