/**************************************************************************
* Memory and computationally efficient Gaussian kernel regression function
* for smoothing a time series. That is, the 'x' values are presumed to be
* (1) ordered and (2) equally-spaced, and thus are utilized as the
* regression function domain. Note that the data is not checked for invalid
* cases that will distort the results.
*
*
* USAGE (MATLAB):
*   yhat = kregt(x,y,bw);
*
* INPUT:
*    double x[]: The x-coordinate values of the data to be regressed.
*    double y[]: The y-coordinate values of the data to be regressed.
*    double  bw: The kernel bandwidth. Values of [], bw<0, Nan, or Inf will
*                raise an exception. 'bw' must be in the same units as 'x'.
*
*        NOTES: (1) 'x' and 'y' must contain the same number of elements.
*               (2) 'x' and 'y' are not checked for invalid cases (NaN, Inf),
*                   which, if present, will distort results.
*
* OUTPUT:
*   double yhat[]: The fitted regression function. Equal length to 'x'.
*
* EXCEPTIONS:
*   1) Greater than 1 value was returned.
*   2) Less than or greater than 3 arguments were passed.
*   3) Empty array passed as an argument for 'x' or 'y'.
*   4) Mismatched number of elements in 'x' and 'y'.
*
*
*
* COMPILATION:
*   Compile with following instructions in the MATLAB Commmand Window:
*       MSVC:
*           mex krege.c -output krege COMPFLAGS="$COMPFLAGS /openmp"
*       GCC:
*           mex krege.c -output krege CFLAGS="$CFLAGS -fopenmp"
*       Clang:
*           mex krege.c -output krege CFLAGS="$CFLAGS -fopenmp=libomp"
*
* DEPENDENCIES:
*   OpenMP v2.0 or later (https://www.openmp.org/resources/openmp-compilers-tools/)
*
* AUTHOR:
*   Devin H. Kehoe
*   dhkehoe@gmail.com
*
* DATE:
*   December 2, 2025
*
* HISTORY:
*   author  date            task         
*   dhk     aug  6, 2023    -written (see krege.c)
*   dhk     nov 29, 2025    -adopted OpenMP for parallelization (x5 speed-up)
*   dhk     dec  1, 2025    -assuming ordered time series data, extra computational
*                            acceleration is possible (additional x2 speed-up)
*
*
**************************************************************************/
#pragma once
#include <omp.h>
#include <math.h>
#include <stdlib.h>
#include "mex.h"

#define NUM_BW      3   // Smoothing range in units of bandwidth
#define int64       long long int // OpenMP compiled under MSVC is only supported for the C89 standard :D

/**************************************************************************
*                                   MEX                                   *
**************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //////////////////////////////////////////////////////////////////////
    //                          BASIC DATA HYGENE
    ///////////////////////////////////////////////////////////////////////

    // Check number of outputs
    if (nlhs>1)
        mexErrMsgIdAndTxt("kreg:inputError","Cannot return more than 3 outputs.");
    // Get 'x' and 'y' inputs
    if (nrhs != 3)
        mexErrMsgIdAndTxt("kreg:inputError","Exactly three inputs required: kregt(x,y,bw)");
    // else:
    double* x  = mxGetPr(prhs[0]); // arg 0 --> x data
    double* y  = mxGetPr(prhs[1]); // arg 1 --> y data

    // Ensure data arrays are filled
    if (x == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'x'");
    if (y == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'y'");

    // Get size variable for data
    int64 N = mxGetNumberOfElements(prhs[0]); // Number of (x,y) data
    if(mxGetNumberOfElements(prhs[1]) != N) // Check for parity
        mexErrMsgIdAndTxt("kreg:inputError","Dimension mismatch between arguments 'x' and 'y'");


    ///////////////////////////////////////////////////////////////////////
    //                      SET DEFAULT BANDWIDTH?
    ///////////////////////////////////////////////////////////////////////

    double bw = mxGetScalar(prhs[2]), // Bandwidth in units of seconds
           dt = x[1]-x[0]; // Sampling interval

    // Ensure validity of bw
    if (bw<=0 || isnan(bw) || isinf(bw)) // Will catch bw<=0, bw==[], bw==NaN, bw==Inf
        mexErrMsgIdAndTxt("kreg:inputError","Argument 'bw' must be positive, infinite scalar.");

    // Convert bandwidth to number of bins
    int64 nbin = (int64)round(bw/dt*NUM_BW);
    

    ///////////////////////////////////////////////////////////////////////
    //                          INITIALIZE OUTPUTS
    // Function always returns something
    plhs[0] = mxCreateDoubleMatrix(1, N, mxREAL);
    double *yhat = mxGetPr(plhs[0]);

    ///////////////////////////////////////////////////////////////////////
    //                          REGRESSION ROUTINE
    ///////////////////////////////////////////////////////////////////////

    //////////////////
    // STEP 1: For computational easing, find the lower/upper bounds of the data
    //         for computing each kernel. (Limit computation to within +/- NUM_BW)
    //         This step is poorly suited for parallelization.
    int64* lbIdx = malloc(N * sizeof(int64));
    int64* ubIdx = malloc(N * sizeof(int64)); // Indices of 'xs' and 'ys' that correspond to mu +/- NUM_BW * bw

    /////////////////////
    // STEP 2: build kernels and weight outcome variable by kernels.

    int64 M = nbin * 2 + 1; // Total span of each kernel
    double*  f = malloc(M * sizeof(double));        // K(X_i-x_j)        --> kernel function centered on X_i, weighting datum x_j
    double* xh = malloc((nbin+1) * sizeof(double)); // sum( K(X_i-x_j )  --> kernel function summed across j
    
    double   yh, // y_j * K(X_i-x_j)     --> regression datum y_j, weighted by kernel (i,j)
           diff, // Compute squared error (powers of 2) without using pow()
          sigma = 2 * bw * bw; // Gaussian denominator



    // Open parallel section
    int64 i,j; // Iterators    

    // Utilize the maximum number of threads available
    omp_set_num_threads(omp_get_max_threads());

    // Assign variable ownership:
    #pragma omp parallel reduction(+:yh) shared(yhat,ubIdx,lbIdx) private(i,j,diff)
    {
        // Compute kernel values
        #pragma omp for schedule(static) nowait
        for (i = 0; i<M; i++) {
            diff = (i-nbin)*dt;
            f[i] = exp( -(diff*diff) / sigma );
        }

        // Compute indices
        #pragma omp for schedule(static)
        for (i = 0; i<N; i++) {
            lbIdx[i] = i-nbin;
            ubIdx[i] = i+nbin;
        }

        // Need to finish filling 'f' and 'Idx' arrays before continuing
        #pragma omp barrier

        // Single thread section
        // --> impossible to parallelize due to dependencies between i and i+1
        #pragma omp single
        {
            // Compute kernel sums
            for (xh[0] = 0, i = 0; i<nbin+1; i++)
                xh[0] += f[i];
            for (i = 1, j = nbin+1; i<nbin+1; i++)
                xh[i] = (xh[i-1] + f[j++]);

            // Correct out-of-bounds indices (only occurs at the end of each array)           
            i = 0;            
            while(i<N && lbIdx[i]<0)
                lbIdx[i++] = 0;

            i = N-1;
            while(0<i && N<ubIdx[i])
                ubIdx[i--] = N;
        }

        // Need to finish correcting Idx arrays and computing xh[] before proceeding
        #pragma omp barrier

        // Compute regression
        #pragma omp for schedule(static)
        for (i = 0; i<N; i++) // Step through domain
        {
            // Reset summation variables
            for (yh = 0, j = lbIdx[i]; j<ubIdx[i]; j++) // Step through data
                yh += f[ j-i+nbin ] * y[j]; // For the i-th kernel, weight the j-th 'y' data

            // Avoid race condition on array update
            #pragma omp critical
            yhat[i] = yh / xh[ ubIdx[i]-lbIdx[i]-nbin-(ubIdx[i]==N) ];
        }

    } // #pragma omp parallel region

    // Release dynamically allocated arrays
    free(lbIdx);
    free(ubIdx);
    free(xh);
    free(f);

} // mexFunction

