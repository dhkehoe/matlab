/**************************************************************************
* Read an imec .bin data file (SpikeGLX data file from NeuroPixels system)
* into the MATLAB environment. Uses convenient optional arguments to
* (1) specify subsets of channels to import and (2) specify the range of 
* data samples to import. Utilizes extensive error handling to ensure that
* that valid channels and sample ranges are specified. If the channel list
* or sample range are omitted, this will import the entire data file by
* default. Imports data into MATLAB in double-type format arranged into an
* N by M matrix with samples along the rows and channels along the columns.
*
* After brief testing, this function runs about twice as fast as using
* the analogous MATLAB wrappers for fopen() and fread(), which (1) offer no
* protection against reading outside the range of data, (2) do not allow
* specifying (channels x samples) subsets of the data for import, and (3)
* require reformatting the data in the MATLAB environment incurring
* additional memory strain.
*
***************************************************************************
* USAGE (MATLAB):
*   f = imecbin2mat(filename);
*   f = imecbin2mat(filename,channels,lowerbound,upperbound);
*   f = imecbin2mat(filename,[],[],[]); % Uses defaults
*
* INPUT:
*   filename - Character array specifying the file to read into the MATLAB
*              environment. This cannot be a string (i.e., text enclosed
*              with double quotations ""). Must be a character array (i.e.,
*              text enclosed with single quotations '');
*
* OPTIONAL INPUT:
*     channels - Vector of channel numbers to read into MATLAB. Channels
*                must be in the interval (1:385). Values outside of this
*                range (including NaN or Inf) will be ignored. Repeated
*                values will also be ignored. The number of specified
*                channels corresponds to the number of columns in the
*                output matrix. The list of channels sorted in ascending
*                order.
*                   (default) channels = 1:385
*   lowerbound - The first sample to read. Must be a scalar in the range
*                of samples contained within the current data file.
*                   (default) lowerbound = 1 (first sample)
*   upperbound - The last sample to read. Must be a scalar in the range
*                of samples contained within the current data file. Must be
*                greater than or equal to lowerbound.
*                   (default) upperbound = N (last sample)
*
*   Note: Default values for optional arguments are utilized whenever these
*         arguments are omitted or empty sets ([]) are passed.
*
*
* OUTPUT:
*   data - N by M matrix, where N is the number of samples and M is the 
*          the number of channels. All columns and rows are unique. Rows
*          (samples) are sorted in chronological order. Columns (channels)
*          are sorted in ascending order by channel number.
*
*
* EXCEPTIONS:
*   1) Missing 'filename' argument.
*   2) Unable to open file specified by 'filename'.
*   3) All specified channels are out of range (1:385).
*   4) A non-scalar value was passed as lower bound argument.
*   5) Lower bound outside the sample range for file specified by 'filename'.
*   6) A non-scalar value was passed as upper bound argument.
*   7) Upper bound outside the sample range for file specified by 'filename'.
*   8) Upper bound less than lower bound.
*   9) Unknown error when streaming file specified by 'filename'.
*   Note: NaN values will trigger the out-of-bounds behavior above in cases
*         3, 5, and 7.
*
*
* COMPILATION:
*   Compile with following instructions in the MATLAB Commmand Window:
*       >> mex imecbin2mat.c -output imecbin2mat
*
*   There are no dependencies besides the C99 standard library.
*
*   Current .mexw64 (targeting x64) compiled under
*       MSVC    19.40.33820
*
*
* AUTHOR:
*   Devin H. Kehoe
*   dhkehoe@gmail.com
*
* DATE:
*   April 17, 2025
*
* HISTORY:
*   author  date            task         
*   dhk     apr 17, 2025    written
**************************************************************************/

#include "mex.h"
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdarg.h>

#define  DEFAULT_ERROR_BUFFER_SIZE   2048

///////////////////////////////////////////////////////////////////////////
//                            SUBROUTINES                                //
///////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////
// Swap 2 values
void swap(double* a, double* b)
{
    double t = *a;
    *a = *b;
    *b = t;
}

///////////////////////////////////////////////////////////////////////////
// Comparator function for qsort()
int comp(const void* ia, const void* ib)
{
    double a = *(double*)ia;
    double b = *(double*)ib;
    return (a > b) - (a < b);
}

///////////////////////////////////////////////////////////////////////////
// Recreate MATLAB's unique() function
double* unique(const double x[], size_t* nptr) 
{
    // Initialize output
    double* y;

    // Convert 'n' to value
    size_t n = *nptr;

    // Exit early for empty arrays to avoid seg fault
    if (!n)
        return y;

    // Make a deep copy
    double* xs = (double*)malloc(n * sizeof(double)); 
    for (size_t i = 0; i<n; i++)
        xs[i] = x[i];

    // Sort the copy
    qsort(xs, n, sizeof(double), comp);

    // Count unique elements
    size_t m = 1; // First element is definitionally unique
    for (size_t i = 1; i<n; i++) 
        if (xs[i-1]<xs[i])
            m++;
    *nptr = m; // Update number of items

    // Copy unique elements into output array
    y = (double*)malloc(m * sizeof(double));
    y[0] = xs[0]; // First element is definitionally unique
    for (size_t i = 1, j = 1; i<n; i++) 
        if (xs[i-1]<xs[i])
            y[j++] = xs[i];   
            
    free(xs); // Release the copy
    return y;
}

///////////////////////////////////////////////////////////////////////////
// Format the user-specified list of channels such that
//      (1) There are no repeated channels
//      (2) All channels are within the interval (1,totalChannels)
//      (3) MATLAB 1-based indexing is converted to 0-based indexing
//      (4) MATLAB default type (double) is converted to integer type.
size_t* format(const double x[], size_t* nptr, size_t lb, size_t ub)
{
    // Consider only the unique elements of x
    double* u = unique(x, nptr);

    // Convert 'n' to value
    size_t n = *nptr;

    // Step through channels, checking whether each channel is in range
    for (size_t i = 0, j = 0; i<n; i++)
        if (u[i] < lb || ub < u[i] || isnan(u[i])) // Out of bounds or NaN
            swap(&u[i--], &u[ (n--) - 1 ]);        // Put offenders to the end of the array
            // Decrement 'n' to ignore the element at the end of the array
            // Decrement 'i' to evaluate the element that's been swapped

    // Update the count variable
    *nptr = n;

    // Sort the list to compensate for swapping
    qsort(u, n, sizeof(double), comp);

    // Create output array
    size_t* y = (size_t*)malloc(n * sizeof(size_t));
    for (size_t i = 0, j = 0; i<n; i++)
        y[i] = (size_t)u[i]-1; // Convert to integer-typed, 0-based indices

    free(u);
    return y;
}

///////////////////////////////////////////////////////////////////////////
// Throw MEX errors with formatting conventions of sprintf()
void formattedError(char const* fmt, ...)
{
    // Create error string
    char errorstring[DEFAULT_ERROR_BUFFER_SIZE];

    // Collate variadic arguments
    va_list args;
    va_start(args, fmt);

    // Format error string
    vsprintf(errorstring, fmt, args);

    // Release variadic arguments
    va_end(args);

    // Throw MEX error
    mexErrMsgTxt(errorstring);
}

///////////////////////////////////////////////////////////////////////////
//                                MEX                                    //
///////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    // Missing required argument
    if (nrhs<1)
        mexErrMsgTxt("Missing required argument 'filename'.");

    // Retrieve file name, attempt to open
    char *filename = mxArrayToString(prhs[0]);
    FILE *file = fopen(filename, "rb");
    mxFree(filename);   

    // Exit early if the file is unreadable
    if ( file == NULL) {
        fclose(file);
        formattedError("Cannot open file\n\n\t%s.",filename);
    }

    // Create constants that define critical size info
    size_t bytesPerSample = 2,   // Data is saved in int16 format
            totalChannels = 385, // 385 recording channels per imec.bin file
            nChannels;           // Number of channels to actually return
    fseek(file, 0L, SEEK_END);
    size_t totalSamples = ftell(file) / (totalChannels * bytesPerSample); // Total number of samples in file

    // Get the (optional) user-specified channel list:
    size_t* channels;
    if (nrhs<2 || mxGetPr(prhs[1]) == NULL) { // Omitted or empty

        // By default, use exhaustive list of channels
        nChannels = totalChannels;
        channels = (size_t*)malloc(nChannels * sizeof(size_t));
        for (size_t i = 0; i<nChannels; i++)
            channels[i] = i;

    }
    else { // Specified list of channels; must ensure correct format

        // Get number of channels
        nChannels = (size_t)mxGetNumberOfElements(prhs[1]);

        // Get formatted channel list, updating nChannels if necessary
        channels = format(mxGetPr(prhs[1]), &nChannels, 1,totalChannels);

        // Ensure there are still valid channels        
        if ( !nChannels ) {
            fclose(file);
            free(channels);
            mexErrMsgTxt("No valid channel numbers provided (1:385).");
        }

    }

    // Get the (optional) lower bound from user
    size_t lowerBound; 
    if (nrhs<3 || mxGetPr(prhs[2]) == NULL) // Omitted or empty
        lowerBound = 0; // Default to beginning of file
    else {
        if ( 1<mxGetNumberOfElements(prhs[2]) ) // An array was passed
            formattedError("Lower bound must be scalar.");
        lowerBound = (size_t)mxGetScalar(prhs[2]);
        if (lowerBound<1 || totalSamples<lowerBound) // Outside the current range of samples
            formattedError("Requested lower bound (%d) is outside the sample range of the data (1,%d).",lowerBound,totalSamples);
        lowerBound--; // Convert to zero-based
    }
    
    // Get the (optional) upper bound from user
    size_t upperBound; 
    if (nrhs<4 || mxGetPr(prhs[3]) == NULL) // Omitted or empty
        upperBound = totalSamples; // Default to end of file
    else {
        if ( 1<mxGetNumberOfElements(prhs[3]) ) // An array was passed
            formattedError("Upper bound must be scalar.");
        upperBound = (size_t)mxGetScalar(prhs[3]);
        if (upperBound<1 || totalSamples<upperBound) // Outside the current range of samples
            formattedError("Requested upper bound (%d) is outside the sample range of the data (1,%d).",upperBound,totalSamples);
    }

    // Compute the number of samples
    size_t nSamples = upperBound-lowerBound;
    if (!nSamples)
        formattedError("Requested upper bound (%d) is less than the requested lower bound (%d).",upperBound,lowerBound+1);

    // Allocate output array
    plhs[0] = mxCreateDoubleMatrix(nSamples, nChannels, mxREAL); // Allocate return data
    double* data = mxGetPr(plhs[0]); // Get pointer to return data

    // Prepare for reading file stream
    int16_t* line; // int16 pointer for conversion from char pointer
    char* buffer = (char*)malloc(totalChannels * bytesPerSample); // Allocate the buffer
    fseek(file, lowerBound * totalChannels * bytesPerSample, 0L); // Set file position

    // Stream line-by-line, sample-by-sample
    for(size_t i = 0; i<nSamples; i++) {

        // Read line from file
        fread(buffer, bytesPerSample, totalChannels, file);

        // Break for any errors
        if (ferror(file))
            break;

        // Resegment buffer memory into (signed) 16-bit words
        line = (int16_t*)buffer;

        // Deep copy the buffer data into output array
        for(size_t j = 0; j<nChannels; j++) {
            // Convert from [channel,samples] to [samples, channel]
           data[i+j*nSamples] = (double)line[channels[j]];
        }      
    }

    // Close stream and free memory
    fclose(file);
    free(buffer);
    free(channels);

    // Throw error
    if (ferror(file))
        mexErrMsgTxt("Unknown error ended read operation prematurely.");
}