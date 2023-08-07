/**************************************************************************
* Memory and computationally efficient kernel regression function for
* MATLAB. Properly implemented (i.e., matrix-based) MATLAB solutions will
* run faster on small datasets, but they have an O(n^2) time complexity,
* whereas this .mex function has an O(n) time complexity making it a much
* better option for large datasets.
*
* USAGE:
*   kreg(x,y,d,bw);
*
* INPUT:
*    x (double[]): The x-domain values of the data to be regressed.
*    y (double[]): The y-domain values of the data to be regressed.
*    d (double[]): The exact x-domain to fit the regression function.
*   bw (double): The kernel bandwidth.
*
* OUTPUT:
*   yhat (double[]): The fitted regression function. Equal length to 'd'.
*   ehat (double[]): The fitted regression function error. Equal length to
*                    'd'.
*
* EXCEPTIONS:
*   1) Fewer than 4 arguments were passed.
*   2) Empty array passed as an argument.
*   3) Mismatched number of elements in 'x' and 'y'.
*
* COMPILATION:
*   Compile with following instructions in the MATLAB Commmand Window:
*       mex krege.c -output krege
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
*
* DO TO:
*   1) Variable domain input:
*           case(d = []): d = to linspace(min(x),max(x),100)
*           case(numel(d)==1): d = to linspace(min(x),max(x),d)
*   2) Variable sigma inputs:
*           case(bw = []): Silvermans's rule
*           case(numel(bw)>1): LOOCV select sigma
**************************************************************************/

#include "mex.h"
#include <math.h>
#include <stdlib.h>

#define uInt64  long long unsigned int
#define pi      3.14159265358979323846264338327950288419716939937510
#define numBW   3

/**************************************************************************
*                                  TYPES                                  *
**************************************************************************/
typedef struct iarray
{
    // type double indexed-array
    uInt64 index;
    double value;
} iarray;

/**************************************************************************
*                                FUNCTIONS                                *
**************************************************************************/
// define comparison function qsort
int comp(const void* ia, const void* ib)
{
    double a = ((iarray*)ia)->value;
    double b = ((iarray*)ib)->value;
    return (a > b) - (a < b);
}

// custom implementationed of qsort where the sorted list of indices is returned also
double* qsortIndex(const double arr[], uInt64 idx[], uInt64 n)
{
    // allocate output copy of sorted data array
    double* out = malloc(n * sizeof(double));

    // allocate indexed-array instance, then deep copy the input data array
    iarray* ia = malloc(n * sizeof(iarray));
    for (uInt64 i = 0; i<n; i++)
    {
        ia[i].index = i;
        ia[i].value = arr[i];
    }

    // qsort the indexed-array
    qsort(ia, n, sizeof(iarray), comp);

    // reassign values in the input data array and fill the output indices array
    for (uInt64 i = 0; i<n; i++)
    {
        idx[i] = ia[i].index;
        out[i] = ia[i].value;
    }

    free(ia);
    return out;
}

// replicate linspace
double* linspace(double min, double max, int n)
{
    double* x = malloc(n * sizeof(double));
    double step = (max - min) / (double)(n - 1);
    for (int i = 0; i < n; i++)
        x[i] = min + ((double)i * step);
    return x;
}

/**************************************************************************
*                                   MEX                                   *
**************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    ////////////////////////////////
    // SET UP

    // Check number of inputs
    if (nrhs<4)
        mexErrMsgIdAndTxt("kreg:inputError","Four inputs required: krege(x,y,d,bw)");

    // Get 'x' and 'y' nputs
    double* x = mxGetPr(prhs[0]); // arg 0 --> x
    double* y = mxGetPr(prhs[1]); // arg 1 --> y
    double* mu = mxGetPr(prhs[2]); // arg 2 --> domain

    // Ensure arrays are filled
    if (x == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'x'");
    if (y == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'y'");
    if (mu == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'd'");
    if (mxGetPr(prhs[3]) == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'bw'");
    
    // Size variables
    size_t m = mxGetNumberOfElements(prhs[0]); // number of (x,y) data
    if(mxGetNumberOfElements(prhs[1]) != m) // check for parity
        mexErrMsgIdAndTxt("kreg:inputError","Dimension mismatch between arguments 'x' and 'y'");
    size_t n = mxGetNumberOfElements(prhs[2]); // number of domain points

    // Sort 'x' and 'y' inputs
    uInt64* idx = malloc(m * sizeof(uInt64));   // indices of x in sorted x 
    double* xs = qsortIndex(x, idx, m);         // sorted x
    double* ys = malloc(m * sizeof(double));    // sorted y
    for (uInt64 i = 0; i<m; i++)
        ys[i] = y[idx[i]]; // deep copy
    free(idx);

    // Constants
    double bw = mxGetScalar(prhs[3]); // arg 3 --> bandwidth
    double sigma = 2 * pow(bw, 2);

    // Outputs
    plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);   // allocate return 0
    plhs[1] = mxCreateDoubleMatrix(1, n, mxREAL);   // allocate return 1
    double* yhat = mxGetPr(plhs[0]);                // return 0 --> fitted y
    double* ehat = mxGetPr(plhs[1]);                // return 1 --> SE
    bool err = nlhs==2; // compute regression error?

    
    /////////////////////////////////
    // ROUTINE

    uInt64 lbIdx, ubIdx = 0;
    if (err) // start at beginning
    {
        // regression error is wildly underestimated if we
        // do not compute error across the entire dataset
        lbIdx = 0; 
        ubIdx = m;
    }

    
    double f, xh, yh, eh, lbVal, ubVal;
    for (uInt64 i = 0; i<n; i++) // step through domain
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
        xh = 0, yh = 0, eh = 0; // reset counting variables
        for (uInt64 j=lbIdx; j<ubIdx; j++) // step through data
        {
            f = exp( -pow( xs[j]-mu[i],2) / sigma ); // kernel weight this 'x' data
            xh += f; // build x hat
            yh += f * ys[j]; // build y hat
        }

        // avoid divide by zero errors
        yhat[i] = xh > 0 ? yh / xh : 0;


        // STEP 3: compute regression error
        if (err)
        {
            for (uInt64 j=lbIdx; j<ubIdx; j++) // step back through data
                eh += pow(ys[j]-yhat[i],2);  // build e hat

            // avoid divide by zero errors
            ehat[i] = xh > 0 ? sqrt(eh) / xh: 0;
        }

    }

    // deallocate sorted arrays before exiting
    free(xs);
    free(ys);

} // mexFunction

