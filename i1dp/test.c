#include <stdio.h>
#include <windows.h>
#include "i1d3SDK.h"

// gcc test.c "C:\Users\dhk\Documents\i1d3SDK_1.4.0\Libs\x64\i1d3SDK64.lib" -otest -I"C:\Users\dhk\Documents\i1d3SDK_1.4.0\Include"

int main(void)
{
    i1d3Status_t status;

    // i1d3Status_t i1d3OverrideDeviceDefaults(unsigned int vid,unsigned int pid,unsigned char* productkey)
    unsigned int vid = 0;
    unsigned int pid = 0;
    unsigned char productkey [] = {0xD4,0x9F,0xD4,0xA4,0x59,0x7E,0x35,0xCF,0}; //{0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0}; //"XRCE-I1D3+OEM";
    status = i1d3OverrideDeviceDefaults(vid, pid, productkey);
    printf("\nOverrideDeviceDefaults status = %d\n",(int)status);


    // i1d3Status_t i1d3Initialize()
    status = i1d3Initialize();
    printf("\nInitialize status = %d\n",(int)status);


    // unsigned int i1d3GetNumberOfDevices()
    printf("\nGetNumberOfDevices = %d\n",i1d3GetNumberOfDevices());


    // i1d3Status_t i1d3GetDeviceHandle(unsigned int whichDevice, i1d3Handle *devHndl)
    i1d3Handle devHndl;
    status = i1d3GetDeviceHandle(i1d3GetNumberOfDevices()-1,&devHndl);
    printf("\nGetDeviceHandle status = %d\n",(int)status);


    // i1d3Status_t i1d3DeviceOpen(i1d3Handle devHndl)
    status = i1d3DeviceOpen(devHndl);
    printf("\nDeviceOpen status = %d\n",(int)status);


    // i1d3Status_t i1d3GetDeviceInfo ( i1d3Handle devHndl, i1d3DEVICE_INFO *infostruct )
    i1d3DEVICE_INFO infostruct;
    status = i1d3GetDeviceInfo(devHndl, &infostruct);
    printf("\nGetDeviceInfo status = %d\n", (int)status);
    printf("Product name:       %s\n", infostruct.strProductName);
    printf("Product type:       %d\n", infostruct.usProductType);
    printf("Firmware version:   %s\n", infostruct.strFirmwareVersion);
    printf("Firmware date:      %s\n", infostruct.strFirmwareDate);
    printf("Is Locked?:         %d\n", infostruct.ucIsLocked);
    // typedef struct
    // {
    // 	char			strProductName[32];
    // 	unsigned short	usProductType;
    // 	char			strFirmwareVersion[32];
    // 	char			strFirmwareDate[32];
    // 	unsigned char	ucIsLocked;
    // } i1d3DEVICE_INFO;


    // char* i1d3GetToolkitVersion(char *ver)
    char *ver;
    i1d3GetToolkitVersion(ver);
    printf("\nVersion: %s\n",ver);


    // i1d3Status_t i1d3GetSerialNumber ( i1d3Handle devHndl, char *sn )
    char *sn;
    status = i1d3GetSerialNumber(devHndl, sn);
    printf("\nGetSerialNumber status = %d\n",(int)status);
    printf("Serial number: %s\n",sn);


    // i1d3Status_t i1d3MeasureYxy(i1d3Handle devHndl, i1d3Yxy_t *dYxy)
    i1d3Yxy_t dYxy;
    status = i1d3MeasureYxy(devHndl, &dYxy);
    printf("\nMeasureYxy status = %d\n",(int)status);
    printf("Yxy: %.3f,%.3f,%.3f\n",dYxy.Y,dYxy.x,dYxy.y);


    // i1d3Status_t i1d3GetMeasurementMode(i1d3Handle devHndl, i1d3MeasMode_t *measMode);
    status = i1d3SetMeasurementMode(devHndl, 8);
    printf("\nSetMeasurementMode status = %d\n",(int)status);


    // i1d3Status_t i1d3GetMeasurementMode(i1d3Handle devHndl, i1d3MeasMode_t *measMode);
    i1d3MeasMode_t measMode;
    status = i1d3GetMeasurementMode(devHndl, &measMode);
    printf("\nGetMeasurementMode status = %d\n",(int)status);
    printf("MeasurementMode: %d\n",(int)measMode);


    // i1d3Status_t i1d3SetIntegrationTime(i1d3Handle devHndl, double dSeconds)
    status = i1d3SetIntegrationTime(devHndl, .1);
    printf("\nSetIntegrationTime status = %d\n",(int)status);


    // i1d3Status_t i1d3SetTargetLCDTime(i1d3Handle devHndl, double dSeconds);
    status = i1d3SetTargetLCDTime(devHndl, -.1);
    printf("\nSetTargetLCDTime status = %d\n",(int)status);


    // i1d3Status_t i1d3Status_t i1d3MeasureBacklightFrequency(i1d3Handle devHndl, unsigned short *freqHz);
    unsigned short freqHz;
    status = i1d3MeasureBacklightFrequency(devHndl, &freqHz);
    printf("\nMeasureBacklightFrequency status = %d\n",(int)status);
    printf("MeasurementBacklightFrequency: %d\n",(int)freqHz);


    // i1d3Status_t i1d3SetLEDControl(i1d3Handle devHndl, i1d3LED_Control LEDconfig, double dOffTime, double dOnTime, unsigned char ucCount);
    status = i1d3SetLEDControl(devHndl, i1d3LED_PULSE, 0., 0., (unsigned char)255);
    printf("\nSetLEDControl status = %d\n",(int)status);
    Sleep(10000);

    // i1d3Status_t i1d3GetLEDControlSettings(i1d3Handle devHndl, i1d3LED_Control *LEDconfig, double *dOffTime, double *dOnTime, unsigned char *ucCount);
    i1d3LED_Control LEDconfig;
    double dOffTime, dOnTime;
    unsigned char ucCount;
    status = i1d3GetLEDControlSettings(devHndl, &LEDconfig, &dOffTime, &dOnTime, &ucCount);
    printf("\nGetLEDControlSettings status = %d\n",(int)status);
    printf("GetLEDControlSettings:\nLED config: %d, offTime = %.2f, onTime = %.2f, ucCount = %d\n",(int)LEDconfig,dOffTime,dOnTime,ucCount);




    ////////////////////////////////////////////////////////////////////////////
    // i1d3Status_t i1d3DeviceClose(i1d3Handle devHndl)
    status =  i1d3DeviceClose(devHndl);
    printf("\nDeviceClose status = %d\n",(int)status);


    // i1d3Status_t i1d3Destroy()
    status = i1d3Destroy();
    printf("\nDestroy status = %d\n",(int)status);

    return(0);
}
