% .mex to (quickly) set the Analog Output voltage of a specific pin on the NIDAQ board.
% 
% Usage:
%     readNidaqAO(deviceNumber, channelNumber, voltage)
% 
% Input:
%      deviceNumber - The device number reported by NI MAX Device Manager. If
%                     unsure, launch NI MAX application, click 'Devices and
%                     Interfaces', and find your device number. E.g., dev1 is
%                     specified with a 1.
%     channelNumber - Check the pin-out diagram. Pins are specified by
%                     channelNumber; e.g., for AO channel 1, see AO 1.
%           voltage - A voltage to set the pin state specified as a floating
%                     point. Must be in the range of (-5.0, 5.0).
% 
% Exceptions:
%     For any driver errors, throws an exception in the MATLAB environment 
%     with a detailed error report.