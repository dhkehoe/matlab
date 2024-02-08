function timeStamps = getBioPacTimeStamps(data)
% Get all the DIO time stamps from a BioPac raw data file. Output a struct
% with field names corresponding to the event codes defined in
%   rigbox/specific_sapiens/setupDIO.m
%
% Each field contains a vector of the indices (rows) in the raw data stream
% where a markEvent occurred.
%
% INPUT
%   data - Matrix of a BioPac data stream. It is contained in the .mat file
%          saved by BioPac's  "AcqKnowledge" software. In MATLAB, if you
%          run
%               load('mybiopacdata.mat');
%          a matrix called 'data' should appear in the Workspace.
% 
% OUTPUT
%   timeStamps - A struct with field names corresponding to the event codes
%                defined in
%                   rigbox/specific_sapiens/setupDIO.m
%                Each field contains a vector of indices (rows in "data")
%                for that event.
%
%
%
%   DHK - Feb. 4, 2024

% Channels 5:12 on BioPac are digital IO.
chan = 5:12;

% Integer codes for events defined in rigbox/specific_sapiens/setupDIO.m
codes = struct(...
    'juice',        1,...       0000 0001
    'trialStart',   2,...       0000 0010
    'fixOn',        4,...       0000 0100
    'fixAcq',       8,...       0000 1000
    'fixOff',       12,...      0000 1100
    'targOn',       16,...      0001 0000
    'targChange',   32,...      0010 0000
    'targAcq',      64,...      0100 0000
    'trialStop',    128,...     1000 0000
    'distOn',       3 ...       0000 0011
    );

% Create another struct that we can use to save all the time stamps
timeStamps = codes;

% Convert integer codes to channel-wise binary
for i = fields(codes)'
    codes.(i{:}) = logical(bitand(codes.(i{:}), 2.^(0:7)));
end

% Get all rising edges with TTL tolerance of (> +3V). Channels are in raw 
% voltages, so convert from +5V TTL to logical.
risingEdges = [zeros(size(chan)); data(2:end,chan)-data(1:end-1,chan)] > 3;

% Isolate all time stamps
for i = fields(timeStamps)'
    timeStamps.(i{:}) = find(all(risingEdges == codes.(i{:}), 2));
end