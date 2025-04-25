% Read an imec .bin data file (SpikeGLX data file from NeuroPixels system)
% into the MATLAB environment. Uses convenient optional arguments to
% (1) specify subsets of channels to import and (2) specify the range of 
% data samples to import. Utilizes extensive error handling to ensure that
% that valid channels and sample ranges are specified. If the channel list
% or sample range are omitted, this will import the entire data file by
% default. Imports data into MATLAB in double-type format arranged into an
% N by M matrix with samples along the rows and channels along the columns.
%
% After brief testing, this function runs about twice as fast as using
% the analogous MATLAB wrappers for fopen() and fread(), which (1) offer no
% protection against reading outside the range of data, (2) do not allow
% specifying (channels x samples) subsets of the data for import, and (3)
% require reformatting the data in the MATLAB environment incurring
% additional memory strain.
%
%
% USAGE (MATLAB):
%   f = imecbin2mat(filename);
%   f = imecbin2mat(filename,channels,lowerbound,upperbound);
%   f = imecbin2mat(filename,[],[],[]); % Uses defaults
%
% INPUT:
%   filename - Character array specifying the file to read into the MATLAB
%              environment. This cannot be a string (i.e., text enclosed
%              with double quotations ""). Must be a character array (i.e.,
%              text enclosed with single quotations '');
%
% OPTIONAL INPUT:
%     channels - Vector of channel numbers to read into MATLAB. Channels
%                must be in the interval (1:385). Values outside of this
%                range (including NaN or Inf) will be ignored. Repeated
%                values will also be ignored. The number of specified
%                channels corresponds to the number of columns in the
%                output matrix. The list of channels sorted in ascending
%                order.
%                   (default) channels = 1:385
%   lowerbound - The first sample to read. Must be a scalar in the range
%                of samples contained within the current data file.
%                   (default) lowerbound = 1 (first sample)
%   upperbound - The last sample to read. Must be a scalar in the range
%                of samples contained within the current data file. Must be
%                greater than or equal to lowerbound.
%                   (default) upperbound = N (last sample)
%
%   Note: Default values for optional arguments are utilized whenever these
%         arguments are omitted or empty sets ([]) are passed.
%
%
% OUTPUT:
%   data - N by M matrix, where N is the number of samples and M is the 
%          the number of channels. All columns and rows are unique. Rows
%          (samples) are sorted in chronological order. Columns (channels)
%          are sorted in ascending order by channel number.
%
%
% EXCEPTIONS:
%   1) Missing 'filename' argument.
%   2) Unable to open file specified by 'filename'.
%   3) All specified channels are out of range (1:385).
%   4) A non-scalar value was passed as lower bound argument.
%   5) Lower bound outside the sample range for file specified by 'filename'.
%   6) A non-scalar value was passed as upper bound argument.
%   7) Upper bound outside the sample range for file specified by 'filename'.
%   8) Upper bound less than lower bound.
%   9) Unknown error when streaming file specified by 'filename'.
%   Note: NaN values will trigger the out-of-bounds behavior above in cases
%         3, 5, and 7.

% COMPILATION:
%   Compile with following instructions in the MATLAB Commmand Window:
%       >> mex imecbin2mat.c -output imecbin2mat
%
%   There are no dependencies besides the C99 standard library.
%
%   Current .mexw64 (targeting x64) compiled under
%       MSVC    19.40.33820
%
%
% AUTHOR:
%   Devin H. Kehoe
%   dhkehoe@gmail.com
%
% DATE:
%   April 17, 2025
%
% HISTORY:
%   author  date            task         
%   dhk     apr 17, 2025    written