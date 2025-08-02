/**************************************************************************
* Memory and computationally efficient kernel regression function for
* MATLAB. Properly implemented (i.e., matrix-based) MATLAB solutions will
* run faster on small datasets, but they have an O(n * m) time complexity,
* whereas this .mex function has an O(n) time complexity making it a much
* better option for large datasets.
*
* USAGE (MATLAB):
*   f = krege(x,y,d);
*   f = krege(x,y,d,bw);
*   [f,e] = krege(x,y,d,bw);
*
* INPUT:
*    double x[]: The x-domain values of the data to be regressed.
*    double y[]: The y-domain values of the data to be regressed.
*    double d[]: The exact x-domain to fit the regression function.
*
* OPTIONAL INPUT:
*    double bw: The kernel bandwidth.
*
* OUTPUT:
*   double yhat[]: The fitted regression function. Equal length to 'd'.
*   double ehat[]: The fitted regression function error. Equal length to 'd'.
*
* EXCEPTIONS:
*   1) Fewer than 3 arguments were passed.
*   2) Empty array passed as an argument for 'x', 'y', or 'd'.
*   3) Mismatched number of elements in 'x' and 'y'.
*
* COMPILATION:
*   Compile with following instructions in the MATLAB Commmand Window:
*       mex krege.c -output krege
*
* AUTHOR:
*   Devin H. Kehoe
*   dhkehoe@gmail.com
*
* DATE:
*   August 6, 2023
*
* HISTORY:
*   author  date            task         
*   dhk     aug  6, 2023    written
*   dhk     oct 29, 2023    ignore nan/inf values;  'bw' arg is optional
*
* DO TO:
*   1) Variable domain input:
*           case(d = []): d = linspace(min(x),max(x),100)
*           case(numel(d)==1): d = linspace(min(x),max(x),d)
**************************************************************************/

#include "mex.h"
#include <math.h>
#include <stdlib.h>

#define DEFAULT_LS  100 // Default number of points for linspace
#define NUM_BW      3   // Smoothing range in units of bandwidth

/**************************************************************************
*                                  TYPES                                  *
**************************************************************************/
// type double indexed-array
typedef struct iarray
{   
    size_t index;
    double value;
} iarray;

/**************************************************************************
*                                FUNCTIONS                                *
**************************************************************************/
// Define comparison function for qsort operating on indexed-arrays
int comp(const void* ia, const void* ib)
{
    double a = ((iarray*)ia)->value;
    double b = ((iarray*)ib)->value;
    return (a > b) - (a < b);
}

// Custom implementation of qsort where just the sorted list of indices is returned
size_t* qsortIndex(const double arr[], size_t n)
{
    // allocate indexed-array instance, then deep copy the input data array
    iarray* ia = malloc(n * sizeof(iarray));
    for (size_t i = 0; i<n; i++)
    {
        ia[i].index = i;
        ia[i].value = arr[i];
    }

    // qsort the indexed-array
    qsort(ia, n, sizeof(iarray), comp);

    // deep copy the sorted indices array
    size_t* idx = malloc(n * sizeof(size_t)); 
    for (size_t i = 0; i<n; i++)
        idx[i] = ia[i].index;

    // release indexed-array
    free(ia);

    return idx;
}

// Replicate MATLAB linspace()
double* linspace(double min, double max, int n)
{
    double* x = malloc(n * sizeof(double));
    double step = (max - min) / (double)(n - 1);
    for (int i = 0; i < n; i++)
        x[i] = min + ((double)i * step);
    return x;
}

// Compute min/max of an array
double getmin(const double x[], size_t n)
{
    double m = x[0];
    for (size_t i = 0; i<n; i++)
    {
        if (x[i] < m)
            m = x[i];
    }
    return m;
}
double getmax(const double x[], size_t n)
{
    double m = x[0];
    for (size_t i = 0; i<n; i++)
    {
        if (m < x[i])
            m = x[i];
    }
    return m;
}

// Round to n_th decimal place
double roundn(double x, int n)
{
    double f = pow(10,n);
    return round(x * f) / f;
}

// Compute interquartile range using the exact method
double iqr(const double x[], size_t n)
{
    double *f = calloc(DEFAULT_LS, sizeof(double)); // empirical CDF
    double *d = linspace(getmin(x, n), getmax(x, n), DEFAULT_LS); // function domain
    double r, lb = nan(""), ub, interval = (d[1]-d[0])/2; // round(f[i]), lower/upper bound of IQR, interval between domain points

    for(size_t i = 0; i<DEFAULT_LS; i++) // step through domain
    {
        for(size_t j = 0; j<n; j++) // step through data
            f[i] += d[i] - interval < x[j] && x[j] <= d[i] + interval; // count instances in this bin
        
        f[i] /= n-1; // convert to proportion

        // convert to cumulative sum
        if (i>0)
            f[i] += f[i-1];

        r = roundn(f[i],2); // round this value to 2 decimal places to ensure the quartile check can find exact matches

        // check for IQR values
        if ( isnan(lb) ) // Lower bound not found
        {
            if(r >= .25)
                lb = r == .25 ? d[i] : (.25-f[i-1])/(f[i]-f[i-1]) * (d[i]-d[i-1]);
        }
        else // Lower bound found; search for upper bound
        {
            if (r >= .75)
            {
                ub = r == .75 ? d[i] : (.75-f[i-1])/(f[i]-f[i-1]) * (d[i]-d[i-1]);
                break; // no use continuing
            }
        }
    } 
  
    //printf("lb = %f, ub = %f, iqr = %f\n",lb,ub,ub-lb);
    free(d);
    free(f);
    return ub-lb;
}

// Compute standard deviation
double std(const double x[], size_t n)
{
    double ssx = 0, sxs = 0; // sum of (squared x), (sum of x) squared
    for(size_t i =0; i<n; i++)
    {
        ssx += pow(x[i],2);
        sxs += x[i];
    }
    return sqrt( (ssx - pow(sxs,2)/n)/(n-1) );   
}

/**************************************************************************
*                                   MEX                                   *
**************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //////////////////////////////////////////////////////////////////////
    // DATA HYGENE

    // Get all inputs
    if (nrhs<3)
        mexErrMsgIdAndTxt("kreg:inputError","Minimum three inputs required: krege(x,y,d)");
    // else:
    double* x  = mxGetPr(prhs[0]); // arg 0 --> x
    double* y  = mxGetPr(prhs[1]); // arg 1 --> y
    double* mu = mxGetPr(prhs[2]); // arg 2 --> domain

    double bw;
    if (nrhs<4)
        bw = nan("");
    else
        bw = mxGetScalar(prhs[3]); // arg 3 --> bandwidth

    // Ensure data arrays are filled
    if (x == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'x'");
    if (y == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'y'");
    if (mu == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'd'");

    // Get size variables
    size_t m = mxGetNumberOfElements(prhs[0]); // number of (x,y) data
    if(mxGetNumberOfElements(prhs[1]) != m) // check for parity
        mexErrMsgIdAndTxt("kreg:inputError","Dimension mismatch between arguments 'x' and 'y'");
    size_t n = mxGetNumberOfElements(prhs[2]); // number of domain points

    ///////////////////////////////////////////////////////////////////////
    // SORT 'X' AND 'Y' AND REMOVE NANS/INFS

    // Get sorted indices of 'x'
    size_t* idx = qsortIndex(x, m);

    // Create sorted copies of 'x' and 'y', skipping over any 'nan' values
    double* xs = malloc(m * sizeof(double));    // sorted x
    double* ys = malloc(m * sizeof(double));    // sorted y
    size_t i = 0, ex = 0; // index, number of excluded indices
    while (i<m) {
        if( isnan(x[idx[i+ex]]) || isinf(x[idx[i+ex]]) || isnan(y[idx[i+ex]]) || isinf(y[idx[i+ex]]) ) // bogus values found
        {
            ex++; // Increment exclusions
            m--;  // Decrement number of valid data cases. Now we do not need to
                  // realloc(), since all subsequent steps through 'xs' or 'ys'
                  // use for(;i<m;i++) and since 'xs' and 'yx' only contain valid
                  // cases for indices { 0, ..., m }
        }
        else // neither x_i nor y_i contain nan
        {
            xs[i] = x[idx[i+ex]]; // deep copy
            ys[i] = y[idx[i+ex]]; // deep copy
            i++;
        }
    }
    free(idx);

    // Verify that not all the data has been excluded
    if(!i) {
        free(xs);
        free(ys);
        mexErrMsgIdAndTxt("kreg:inputError","Insufficient valid data in 'x' and/or 'y'.");
    };

    ///////////////////////////////////////////////////////////////////////
    // SET DEFAULT BANDWIDTH?

    // Ensure validity of bw; set a default for invalid cases using Silverman's rule
    if (bw == 0 || isnan(bw) || isinf(bw)) // Will catch bw==0, bw==[], bw==NaN, bw==Inf
    {
        double s = std(xs,m);
        double i = iqr(xs,m)/1.34;
        bw = .9 * (s < i ? s : i)  * 1.0/pow(m, 1.0/5);
    }

    
    ///////////////////////////////////////////////////////////////////////
    // INITIALIZE OUTPUTS
    plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);   // allocate return 0
    plhs[1] = mxCreateDoubleMatrix(1, n, mxREAL);   // allocate return 1
    double* yhat = mxGetPr(plhs[0]);                // return 0 --> fitted y
    double* ehat = mxGetPr(plhs[1]);                // return 1 --> SE of fit   

    
    ///////////////////////////////////////////////////////////////////////
    // REGRESSION ROUTINE

    size_t lbIdx, ubIdx = 0;  // indices of 'xs' and 'ys' that correspond to mu +/- NUM_BW * bw
    double sigma = 2 * pow(bw, 2), // bandwidth converted to Gaussian sigma
    f,  // K(X_i-x_j)           --> kernel function (i,j): centered on X_i, weighting datum x_j
    xh, // sum( K(X_i-x_j )     --> " summed across j
    yh, // y_j * K(X_i-x_j)     --> regression datum y_j, weighted by kernel (i,j)
    eh, // (yhat[i]-y_j).^2     --> SE between fitted regression (yhat_i) and datum y_j
    lbVal, ubVal; // lower/upper bound value of 'xs' and 'ys' for i_th kernel
    bool err = nlhs==2; // compute regression error? (Requires a second pass through the data, so avoid if possible)

    for (size_t i = 0; i<n; i++) // step through domain
    {

        // STEP 1: find lower/upper bounds for computational easing by
        // limiting computation to within +/- "NUM_BW"
        ubVal = mu[i]+bw*NUM_BW;
        lbVal = mu[i]-bw*NUM_BW;

        while ( (ubIdx < m) && (xs[ubIdx] < ubVal) ) // step through data
            ubIdx++;
        lbIdx = ubIdx < m ? ubIdx : ubIdx-1;
        while ( (lbIdx > 0) && (xs[lbIdx] > lbVal) ) // step through data
            lbIdx--;

        
        // STEP 2: build kernels and weight outcome variable by kernels
        xh = 0, yh = 0, eh = 0; // reset sumation variables
        for (size_t j=lbIdx; j<ubIdx; j++) // step through data
        {
            f = exp( -pow( xs[j]-mu[i],2) / sigma ); // kernel weight this 'x' data
            xh += f;         // build x hat
            yh += f * ys[j]; // build y hat
        }

        // avoid divide by zero errors
        yhat[i] = xh > 0 ? yh / xh : 0;
        
        
        // STEP 3: compute regression error
        if (err)
        {
            for (size_t j=lbIdx; j<ubIdx; j++) // step back through data
                eh += pow(ys[j]-yhat[i],2);  // build e hat

            // avoid divide by zero errors
            ehat[i] = xh > 0 ? sqrt(eh) / xh: 0;
        }

    }

    // deallocate sorted arrays before exiting
    free(xs);
    free(ys);

} // mexFunction

