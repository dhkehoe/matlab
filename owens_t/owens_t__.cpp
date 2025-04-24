// mex instructions:
// mex owens_t.cpp -I'C:\boost_1_87_0' -output owens_t

#include "mexAdapter.hpp"
#include <stdexcept>
#include <boost/math/special_functions/owens_t.hpp>

class MexFunction : public matlab::mex::Function {
public:
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        
        // Ensure correct number of inputs
        if (inputs.size() != 2)
            throw std::invalid_argument("Must pass 2 arguments.");

        // Get TypedArray<double> pointers to input arrays
        matlab::data::TypedArray<double> h = std::move(inputs[0]);
        matlab::data::TypedArray<double> a = std::move(inputs[1]);

        // Return if either input is empty
        if ( h.isEmpty() || a.isEmpty() )
            throw std::invalid_argument("One or more empty argument(s) passed.");

        // Get array sizes
        size_t n = h.getNumberOfElements();
        size_t m = a.getNumberOfElements();
        
        // Ensure matching sizes of h and a or that at least one is scalar
        if (  !(n == m || n == 1 || m == 1)  )
            throw std::invalid_argument("Input size mismatch. Arguments must be either the same size or at least one argument must be scalar.");

        // Determine which input size to replicate
        matlab::data::ArrayDimensions dim;
        if (n<m)
            dim = a.getDimensions();
        else
            dim = h.getDimensions();

        // Allocate memory for output
        matlab::data::ArrayFactory f;
        matlab::data::TypedArray<double> y = f.createArray<double>(dim);

        // Cast  matlab::data::TypedArrays<double>  to  matlab::data::buffer_ptr_t<double>
        // which is simply a wrapper around std::unique_ptr<T[]>. Therefore,
        //  buffer_ptr_t<T>[] operator returns data, whereas
        //  TypedArrays<T>[] operator returns some other silly object: ArrayElementTypedRef<T, true>
        matlab::data::buffer_ptr_t<double> H = h.release();
        matlab::data::buffer_ptr_t<double> A = a.release();

        // Define data policy for boost::math
        typedef boost::math::policies::policy<
            boost::math::policies::promote_double<false>,
            boost::math::policies::promote_float<false>,
            boost::math::policies::max_series_iterations<100>
            > my_policy;

        // Compute output
        // NOTE: must use iterator to write to n-dimensional 
        //       matlab::data::TypedArray<T>(matlab::data::ArrayDimensions)
        //       object in linear order.
        size_t i = 0; // For simple linear indexing of input arrays
        if (n == m)
            for(matlab::data::TypedIterator<double> yi = y.begin(); yi != y.end(); yi++, i++)
                *yi = boost::math::owens_t(H[i], A[i], my_policy());       
        else if (m == 1)
            for(matlab::data::TypedIterator<double> yi = y.begin(); yi != y.end(); yi++, i++)
                *yi = boost::math::owens_t(H[i], A[0], my_policy());
        else // if (n == 1)
            for(matlab::data::TypedIterator<double> yi = y.begin(); yi != y.end(); yi++, i++)              
                *yi = boost::math::owens_t(H[0], A[i], my_policy());
    
          
        // Return output
        outputs[0] = y;
    }
};

