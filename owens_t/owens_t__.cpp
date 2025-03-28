// mex instructions:
// mex owens_t__.cpp -I'C:\boost_1_87_0' -output owens_t__

#include "mexAdapter.hpp"
#include <stdexcept>
#include <boost/math/special_functions/owens_t.hpp>

class MexFunction : public matlab::mex::Function {
public:
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        
        // Ensure 2 inputs
        if (inputs.size() != 2)
            throw std::invalid_argument( "Must pass 2 arguments" );

        // Get TypedArray<double> pointers to input arrays
        matlab::data::TypedArray<double> h = std::move(inputs[0]);
        matlab::data::TypedArray<double> a = std::move(inputs[1]);

        // Return if either input is empty
        if ( h.isEmpty() || a.isEmpty() )
            throw std::invalid_argument( "Empty array passed" );

        // Get array sizes
        size_t n = h.getNumberOfElements();
        size_t m = a.getNumberOfElements();
        
        // Ensure matching sizes of h and a or that at least one is scalar
        if (  !(n == m || n == 1 || m == 1)  )
            throw std::invalid_argument( "Input array size mismatch" );

        // Allocate memory for output
        matlab::data::ArrayFactory f;
        matlab::data::TypedArray<double> y = f.createArray<double>(std::vector<size_t>{std::max(n,m)});

        // Cast MATLAB TypedArrays to STL
        // TypedArray<double> -> unique_ptr<double[]>
        auto H = h.release();
        auto A = a.release();

        // Define data policy
        typedef boost::math::policies::policy<
            boost::math::policies::promote_double<false>,
            boost::math::policies::promote_float<false>,
            boost::math::policies::max_series_iterations<100>
            > my_policy;

        // Compute output
        if (n == m) {
            for(size_t i = 0; i < n; i++)
                y[i] = boost::math::owens_t(H[i], A[i], my_policy());
        }
        else if (m == 1) {
            for(size_t i = 0; i < n; i++)
                y[i] = boost::math::owens_t(H[i], A[0], my_policy());
        }
        else { // if (n == 1)
            for(size_t i = 0; i < m; i++)
                y[i] = boost::math::owens_t(H[0], A[i], my_policy());
        }    
          
        // Return output
        outputs[0] = y;
    }
};

