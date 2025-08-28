/**************************************************************************
* Memory and computationally efficient kernel density estimation (KDE)
* function for MATLAB. Properly implemented (i.e., matrix-based) MATLAB
* solutions will run faster on small datasets, but they have an O(n^2) time
* complexity, whereas this .mex function has an O(n) time complexity making
* it a much better option for large datasets.
*
* USAGE:
*   kde(x,d,bw);
*
* INPUT:
*    x (double[]): The x-domain values of the data to be regressed.
*    d (double[]): The exact x-domain to fit the regression function.
*   bw (double): The kernel bandwidth.
*
* OUTPUT:
*   yhat (double[]): The fitted KDE function. Equal length to 'd'.
*   ehat (double[]): The fitted KDE function error. Equal length to
*                    'd'.
*
* EXCEPTIONS:
*   1) Fewer than 3 arguments were passed.
*   2) Empty array passed as an argument.
*
* COMPILATION:
*   Compile with following instructions in the MATLAB Commmand Window:
*       mex kdee.c -output kdee
*
* AUTHOR:
*   Devin H. Kehoe
*   dhkehoe@gmail.com
* DATE:
*   August 6, 2023
*
* HISTORY:
*   author  date            task         
*   dhk     aug 6, 2023     written
**************************************************************************/

#include "mex.h"
#include <math.h>
#include <stdlib.h>

#define pi      3.14159265358979323846264338327950288419716939937510
#define numBW   3

/**************************************************************************
*                                FUNCTIONS                                *
**************************************************************************/
int comp(const void* ia, const void* ib)
{
    double a = *(double*)ia;
    double b = *(double*)ib;
    return (a > b) - (a < b);
}

/**************************************************************************
*                                   MEX                                   *
**************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    ////////////////////////////////
    // SET UP

    // Check number of inputs
    if (nrhs<3)
        mexErrMsgIdAndTxt("kreg:inputError","Three inputs required: kreg(x, domain, bw)");

    // Inputs
    double*  x = mxGetPr(prhs[0]); // arg 0 --> x
    double* mu = mxGetPr(prhs[1]); // arg 2 --> domain

        // Ensure arrays are filled
    if (x == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'x'");
    if (mu == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'd'");
    if (mxGetPr(plhs[2]) == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'bw'");

    // Size variables
    size_t m = mxGetNumberOfElements(prhs[0]); // number of x data
    size_t n = mxGetNumberOfElements(prhs[1]); // number of domain points

    // Constants
    double bw = mxGetScalar(prhs[2]); // arg 3 --> bandwidth
    double sigma = 2 * pow(bw, 2);
    double norm = sqrt(sigma * pi);

    // Outputs
    plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);   // allocate return 0
    plhs[1] = mxCreateDoubleMatrix(1, n, mxREAL);   // allocate return 1
    double* yhat = mxGetPr(plhs[0]);                // return 0 --> fitted y
    double* ehat = mxGetPr(plhs[1]);                // return 1 --> SE
    bool err = nlhs==2; // compute regression error?

    // Sort inputs
    double* xs = malloc(m * sizeof(size_t)); // sorted x
    for (size_t i = 0; i<m; i++)
        xs[i] = x[i]; // deep copy         
    qsort(xs, m, sizeof(double), comp);
    

    /////////////////////////////////
    // ROUTINE
    
    size_t lbIdx, ubIdx = 0;
    if (err) // start at beginning
    {
        // regression error is wildly underestimated if we
        // do not compute error across the entire dataset
        lbIdx = 0; 
        ubIdx = m;
    }

    double xh, eh, lbVal, ubVal;
    for (size_t i = 0; i<n; i++) // step through domain
    {

        // STEP 1: find lower/upper bounds for computational easing by
        // limiting computation to within +/- a few BWs
        if (!err) 
        {
            ubVal = mu[i]+bw*numBW;
            lbVal = mu[i]-bw*numBW;

            while ( (ubIdx < m) && (xs[ubIdx] < ubVal) ) // step through data
                ubIdx++;
            lbIdx = ubIdx < m ? ubIdx : ubIdx-1;
            while ( (lbIdx > 0) && (xs[lbIdx] > lbVal) ) // step through data
                lbIdx--;
        }
        

        // STEP 2: build kernels and weight outcome variable by kernels
        xh = 0, eh = 0; // reset counting variables
        for (size_t j=lbIdx; j<ubIdx; j++) // step through data
            xh += exp( -pow( xs[j]-mu[i],2) / sigma ); // kernel weight this 'x' data
        xh = xh / norm / m;
        yhat[i] = xh > 0 ? xh : 0;

        // STEP 3: compute regression error
        if (err)
        {
            for (size_t j=lbIdx; j<ubIdx; j++) // step back through data
                eh = eh + pow(xs[j]-yhat[i],2);  // build e hat
            ehat[i] = xh > 0 ? sqrt(eh/m) : 0;
        }

    }

    // deallocate sorted arrays before exiting
    free(xs);

} // mexFunction

