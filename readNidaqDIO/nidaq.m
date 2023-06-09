% Function to query the Digital IO state of a specific pin on a NIDAQ board.
% 
% Usage:
%     nidaq(deviceNumber, portNumber, channelNumber)
% 
% Input:
%      deviceNumber - The device number reported by NI MAX Device Manager. If
%                     unsure, launch NI MAX application, click 'Devices and
%                     Interfaces', and find your device number. E.g., dev1 is
%                     specified with a 1.
%        portNumber - Check the pin-out diagram. Pins are specified as
%                     portNumber.channelNumber; e.g., for pin 2.3, portNumber
%                     is specified with a 2.
%     channelNumber - Check the pin-out diagram. Pins are specified as
%                     portNumber.channelNumber; e.g., for pin 2.3, 
%                     channelNumber is specified with a 3.
% 
% Returns:
%     1 for high, 0 for low.
% 
% Exceptions:
%     For any driver errors, throws an exception in the MATLAB environment 
%     with a detailed error report.