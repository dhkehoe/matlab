/**************************************************************************
* Memory and computationally efficient Gaussian kernel regression function.
*
*
* USAGE (MATLAB):
*   xhat = krege(x,y);
*   yhat = krege(x,y,d,bw);
*   yhat = krege(x,y,[],[]);
*   [xhat,yhat,ehat] = krege(x,y,d,bw);
*
* INPUT:
*    double x[]: The x-coordinate values of the data to be regressed.
*    double y[]: The y-coordinate values of the data to be regressed.
*       NOTE: 'x' and 'y' must contain the same number of elements.
*
* OPTIONAL INPUT:
*    double d[]: Specifies the x-domain of the regression function. It may
*                follow 2 formats:
*                   1) [ARRAY] When the number of elements is greater than 
*                      1, this is treated as the exact x-domain of the
*                      regression function.
*                   2) [SCALAR] When the number of elements is exactly 1,
*                      the x-domain of the regression function is computed
*                      as
*                           mu = linspace(min(x),max(x),d)
*                      That is, the scalar 'd' is the number of equally
*                      spaced points between the min/max of the empirical
*                      values in 'x' that constitute the x-domain. Values
*                      of [], 0, Nan, or Inf, will be defaulted to d=100.
*    double bw: The kernel bandwidth. Values of [], bw<0, Nan, or Inf will
*               ne defaulted to the value computed using Silverman's rule
*               (see https://en.wikipedia.org/wiki/Kernel_density_estimation).
*
* OUTPUT:
*   double xhat[]: The fitted regression function. Equal length to 'd'.
*   double yhat[]: The fitted regression function. Equal length to 'd'.
*   double ehat[]: The fitted regression function error. Equal length to 'd'.
*       NOTE: If a single output is designated, the function returns 'yhat'.
*                   e.g., scatter(x,y); hold on; plot(d,krege(x,y,d));
*             If 2 or 3 outputs are designated, the function returns them
*             in the order 'xhat', 'yhat', 'ehat'.
*
* EXCEPTIONS:
*   1) Greater than 3 values were returned.
*   2) Fewer than 2 arguments were passed.
*   3) Empty array passed as an argument for 'x' or 'y'.
*   4) Mismatched number of elements in 'x' and 'y'.
*   5) Insufficient valid (~isnan && ~isinf) elements in 'x' or 'y'.
*   6) Insufficient valid (~isnan && ~isinf) elements in array 'd'.
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
*   August 6, 2023
*
* HISTORY:
*   author  date            task         
*   dhk     aug  6, 2023    -written
*   dhk     oct 29, 2023    -ignore nan/inf values
*                           -'bw' arg is optional
*   dhk     nov 28, 2025    -flexible domain specification
*                           -return values optional + flexibly ordered
*   dhk     nov 29, 2025    -adopted OpenMP for parallelization (x5 speed-up)
*
* NOTES:
*   (nov 29, 2025):
*       With the adoption of multithreading, it nows runs blazingly fast. 
*       Quick testing shows it performs sub 1 GHz per datum:
*           t = N * M * 5e-10
*       where N = numel(x) is the number of 'x' data and M = numel(d) is
*       the number of domain values. For perspective, that's smoothing 50
*       seconds worth of a 2 kHz time series in 5 seconds. That's assuming
*       a reasonable bandwidth.
*
* DO TO:
*   1) A user-beware-of-danger flag to turn off the safeguards and skip all
*      the sorting and integreity checks.
*
**************************************************************************/

#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <omp.h>

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
    // Allocate indexed-array instance, then deep copy the input data array
    iarray* ia = malloc(n * sizeof(iarray));
    for (size_t i = 0; i<n; i++)
    {
        ia[i].index = i;
        ia[i].value = arr[i];
    }

    // qsort() the indexed-array
    qsort(ia, n, sizeof(iarray), comp);

    // Deep copy the sorted indices array
    size_t* idx = malloc(n * sizeof(size_t)); 
    for (size_t i = 0; i<n; i++)
        idx[i] = ia[i].index;

    // Release indexed-array
    free(ia);

    return idx;
}

// Replicate MATLAB linspace()
double* linspace(double min, double max, size_t n)
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
double roundn(double x, size_t n)
{
    double f = pow(10,(double)n);
    return round(x * f) / f;
}

// Compute interquartile range using the exact method
double iqr(const double x[], size_t n)
{
    // Protect against n<=1
    if (n<2)
        return NAN;

    double *f = calloc(DEFAULT_LS, sizeof(double)); // Empirical CDF
    double *d = linspace(getmin(x, n), getmax(x, n), DEFAULT_LS); // Function domain
    double r, lb = NAN, ub, interval = (d[1]-d[0])/2; // round(f[i]), lower/upper bound of IQR, interval between domain points

    for(size_t i = 0; i<DEFAULT_LS; i++) // Step through domain
    {
        for(size_t j = 0; j<n; j++) // Step through data
            f[i] += d[i] - interval < x[j] && x[j] <= d[i] + interval; // Count instances in this bin
        
        f[i] /= n-1; // Convert to proportion

        // Convert to cumulative sum
        if (i>0)
            f[i] += f[i-1];

        r = roundn(f[i],2); // Round this value to 2 decimal places to ensure the quartile check can find exact matches

        // Check for IQR values
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
                break; // No use continuing
            }
        }
    } 
  
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
        ssx += x[i] * x[i];
        sxs += x[i];
    }
    return sqrt( (ssx - (sxs*sxs)/n)/(n-1) );
}

/**************************************************************************
*                                   MEX                                   *
**************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //////////////////////////////////////////////////////////////////////
    //                          BASIC DATA HYGENE
    ///////////////////////////////////////////////////////////////////////

    // Check number of outputs
    if (nlhs>3)
        mexErrMsgIdAndTxt("kreg:inputError","Cannot return more than 3 outputs.");
    // Get 'x' and 'y' inputs
    if (nrhs<2)
        mexErrMsgIdAndTxt("kreg:inputError","Minimum two inputs required: krege(x,y)");
    // else:
    double* x  = mxGetPr(prhs[0]); // arg 0 --> x data
    double* y  = mxGetPr(prhs[1]); // arg 1 --> y data

    // Ensure data arrays are filled
    if (x == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'x'");
    if (y == NULL)
        mexErrMsgIdAndTxt("kreg:inputError","Empty matrix passed to argument 'y'");

    ///////////////////////////////////////////////////////////////////////
    //          SORT 'X' AND 'Y' AND REMOVE NANS/INFS
    ///////////////////////////////////////////////////////////////////////

    // Get size variable for data
    size_t m = mxGetNumberOfElements(prhs[0]); // Number of (x,y) data
    if(mxGetNumberOfElements(prhs[1]) != m) // Check for parity
        mexErrMsgIdAndTxt("kreg:inputError","Dimension mismatch between arguments 'x' and 'y'");

    // Get sorted indices of 'x'
    size_t* idx = qsortIndex(x, m);

    // Create sorted copies of 'x' and 'y', skipping over any 'nan' or 'inf' values
    double* xs = malloc(m * sizeof(double));    // Sorted 'x'
    double* ys = malloc(m * sizeof(double));    // Sorted 'y'
    size_t i = 0, j, ex = 0; // Iterators i/j (used throughout); Number of excluded indices
    while (i<m) {
        j = i+ex;
        if( isnan(x[idx[j]]) || isinf(x[idx[j]]) || isnan(y[idx[j]]) || isinf(y[idx[j]]) ) // bad values found
        {
            ex++; // Increment exclusions
            m--;  // Decrement number of valid data cases. Now we do not need to
                  // realloc(), since all subsequent steps through 'xs' or 'ys'
                  // use for(;i<m;i++) and since 'xs' and 'yx' only contain valid
                  // cases for indices { 0, ..., m }
        }
        else // Neither x_i nor y_i contain nan
        {
            xs[i] = x[idx[j]]; // Deep copy
            ys[i] = y[idx[j]]; // Deep copy
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
    //      SORT 'MU' (i.e., the function domain) AND REMOVE NANS/INFS
    ///////////////////////////////////////////////////////////////////////
    
    double* mu; // Create pointer for potential user input of function domain
    double* mus; // Create pointer for sorted/valid data specifying function domain
    size_t n;

    // Was domain provided?
    if (nrhs<3) { // Omitted
        mu = NULL;
        n = 0;
    } else { // Provided
        mu = mxGetPr(prhs[2]); // Get user data
        n = mxGetNumberOfElements(prhs[2]); // Get number of domain points       
    }

    // Set defaults?
    if (mu == NULL) { // Empty
        n = (size_t)DEFAULT_LS; // Default to min/max linspace with 100 points
        mus = linspace(getmin(xs,m),getmax(xs,m),n);

    } else if (n==1) { // Scalar
        if ((*mu)==0 || isnan(*mu) || isinf(*mu)) // Catch bad values
            n = (size_t)DEFAULT_LS;
        else
            n = (size_t)(*mu); // Default to min/max linspace with 'n' points
        mus = linspace(getmin(xs,m),getmax(xs,m),n);

    } else { // Array: sorting/data hygiene checks required

        // Create sorted copy of 'mu' skipping over any 'nan' or 'inf' values
        mus = malloc(n * sizeof(double));

        // Get sorted indices of 'mu'
        idx = qsortIndex(mu, n);

        // Copy valid cases
        ex = 0, i = 0;
        while (i<n) {
            j = i+ex;
            if( isnan(mu[idx[j]]) || isinf(mu[idx[j]]) ) { // bad values found
                ex++; // Increment exclusions
                n--;  // Decrement number of valid data cases
            }
            else // mu_i is valid
            {
                mus[i] = mu[idx[j]]; // deep copy
                i++;
            }
        }
        free(idx);

        // Verify that not all the data has been excluded
        if(!i) {
            free(xs);
            free(ys);
            free(mus);
            mexErrMsgIdAndTxt("kreg:inputError","Insufficient valid data in 'd'.");
        };
    } // else
    

    ///////////////////////////////////////////////////////////////////////
    //                      SET DEFAULT BANDWIDTH?
    ///////////////////////////////////////////////////////////////////////

    double bw;
    if (nrhs<4)
        bw = nan("");
    else
        bw = mxGetScalar(prhs[3]); // arg 3 --> bandwidth

    // Ensure validity of bw; set a default for invalid cases using Silverman's rule
    if (bw<=0 || isnan(bw) || isinf(bw)) // Will catch bw<=0, bw==[], bw==NaN, bw==Inf
    {
        double s = std(xs,m);
        double I = iqr(xs,m)/1.34;
        bw = .9 * (s < I ? s : I)  * 1.0/pow((double)m, 1.0/5);
    }
    
    ///////////////////////////////////////////////////////////////////////
    //                          INITIALIZE OUTPUTS
    //
    //      Dynamically determine the order of outputs:
    //          Case 1:  krege(...)
    //                      OR
    //                  yhat = krege(...)
    //          Case 2: [xhat, yhat] = krege(...)
    //          Case 3: [xhat, yhat,ehat] = krege(...)
    ///////////////////////////////////////////////////////////////////////

    // Function always returns something
    plhs[0] = mxCreateDoubleMatrix(1, n, mxREAL);

    // Allocate additional outputs, if necessary
    for (i = 1; i<nlhs; i++)
        plhs[i] = mxCreateDoubleMatrix(1, n, mxREAL);

    // Create pointers to each potential output; default 1st output to regression
    double *yhat = mxGetPr(plhs[0]), *xhat, *ehat;

    // Domain is being returned
    if (nlhs > 1) {

        // Reassign pointer order
        xhat = mxGetPr(plhs[0]);
        yhat = mxGetPr(plhs[1]);

        // Fill the sorted array of domain values
        for (i = 0; i<n; i++)
            xhat[i] = mus[i];
    }

    // Check whether error is being computed
    bool err = nlhs==3;
    if (err)
        ehat = mxGetPr(plhs[2]); // Assign pointer



    ///////////////////////////////////////////////////////////////////////
    //                          REGRESSION ROUTINE
    ///////////////////////////////////////////////////////////////////////

    //////////////////
    // STEP 1: For computational easing, find the lower/upper bounds of the data
    //         for computing each kernel. (Limit computation to within +/- NUM_BW)
    //         This step is poorly suited for parallelization.
    size_t* lbIdx = malloc(n * sizeof(double)); // Indices of 'xs' and 'ys' that correspond to mu +/- NUM_BW * bw
    size_t* ubIdx = malloc(n * sizeof(double));
    double sigma = 2 * bw * bw, // Bandwidth converted to Gaussian sigma
           lbVal, ubVal; // Lower/Upper bound values of 'xs' and 'ys' for i_th kernel

    // Solve iteration one
    i = 0;
    ubVal = mus[i]+bw*NUM_BW;
    lbVal = mus[i]-bw*NUM_BW;

    lbIdx[i] = 0; // This gives a reasonable starting location for lower bound
    while ( (xs[lbIdx[i]] < lbVal) && (lbIdx[i] < m-1) ) // Step through data
        lbIdx[i]++;
    ubIdx[i] = lbIdx[i]; // This gives a reasonable starting location for upper bound
    while ( (xs[ubIdx[i]] < ubVal) && (ubIdx[i] < m) ) // Step through data
        ubIdx[i]++;

    // Solve any remaining iterations by piggy-backing off of previous values
    for (i = 1; i<n; i++) { // Step through domain (kernels)

        // Compute numerical limits
        ubVal = mus[i]+bw*NUM_BW;
        lbVal = mus[i]-bw*NUM_BW;

        // Find indices
        lbIdx[i] = lbIdx[i-1]; // Starting from previous value
        while ( (xs[lbIdx[i]] < lbVal) && (lbIdx[i] < m-1) ) // Step through data
            lbIdx[i]++;
        ubIdx[i] = ubIdx[i-1]; // Starting from previous value
        while ( (xs[ubIdx[i]] < ubVal) && (ubIdx[i] < m) ) // Step through data
            ubIdx[i]++;
    }


    /////////////////////
    // STEP 2: build kernels and weight outcome variable by kernels.
    double   f, // K(X_i-x_j)           --> kernel function (i,j): centered on X_i, weighting datum x_j
            xh, // sum( K(X_i-x_j )     --> " summed across j
            yh, // y_j * K(X_i-x_j)     --> regression datum y_j, weighted by kernel (i,j)
            eh, // (yhat[i]-y_j).^2     --> SE between fitted regression (yhat_i) and datum y_j
            diff; // Compute squared error (powers of 2) without using pow()

    // Open parallel section
    long long int k; // OpenMP compiled under MSVC is only supported for the C89 standard :D

    // Utilize the maximum number of threads available
    omp_set_num_threads(omp_get_max_threads());
    #pragma omp parallel shared(yhat,ehat,xs,ys,mus,ubIdx,lbIdx,sigma,n) private(k,j,xh,yh,eh,f,diff)
    {
        #pragma omp for schedule(static)
        for (k = 0; k<n; k++) // Step through domain
        {   
            xh = 0, yh = 0, eh = 0; // Reset summation variables
            for (j = lbIdx[k]; j<ubIdx[k]; j++) // Step through data
            {
                diff = xs[j]-mus[k];
                f = exp( -(diff*diff) / sigma ); // kernel weight this 'x' data
                xh += f;         // build x hat
                yh += f * ys[j]; // build y hat
            }

            // Avoid divide by zero errors
            #pragma omp critical
            yhat[k] = xh > 0 ? yh / xh : 0;

        } // pramga omp for

        // STEP 3: (if necessary) compute regression error
        if (err)
        {
            #pragma omp for schedule(static) nowait
            for (k = 0; k<n; k++) // Step (back) through domain
            {
                for (j = lbIdx[k]; j<ubIdx[k]; j++) // Step back through data
                {
                    diff = ys[j]-yhat[k];
                    eh += diff * diff;  // Build ehat
                }

                // Avoid divide by zero errors
                #pragma omp critical
                ehat[k] = xh > 0 ? sqrt(eh) / xh: 0;

            } // pragma omp for nowait
        } // if (err)

    } // #pragma omp parallel

    // Free any allocated arrays before exiting
    free(lbIdx);
    free(ubIdx);
    free(xs);
    free(ys);
    free(mus);

} // mexFunction

