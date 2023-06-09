//mex owens_t.cpp__ -I'C:\Program Files\boost\boost_1_80_0'

#include "mexAdapter.hpp"

#include <iostream>
#include <stdexcept>

#include <boost/math/special_functions/owens_t.hpp>

class MexFunction : public matlab::mex::Function {
public:
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        
        // Ensure 2 inputs
        if (inputs.size() != 2)
            throw std::invalid_argument( "Must pass 2 arguments" );

        // Cast inputs to arrays
        const matlab::data::TypedArray<double> h = std::move(inputs[0]);
        const matlab::data::TypedArray<double> a = std::move(inputs[1]);

        // Get array sizes
        size_t n = h.getNumberOfElements();
        size_t m = a.getNumberOfElements();

        // Return if either is empty
        if (!n || !m)
            throw std::invalid_argument( "Empty array passed" );
        
        // Ensure matching sizes of h and a or that at least one is scalar
        if (n != m && n != 1 && m != 1)
            throw std::invalid_argument( "Input array size mismatch" );

        // Allocate memory for outputs
        matlab::data::ArrayFactory f;
        matlab::data::TypedArray<double> y = f.createArray<double>(std::vector<size_t>{std::max(n,m)});

        // Compute output
        if (n == m)
        {
            for(int i = 0; i < n; i++)
            {
                y[i] = (double)boost::math::owens_t((double)h[i], (double)a[i]);
            }
        }
        else if (m==1)
        {
            for(int i = 0; i < n; i++)
            {
                y[i] = boost::math::owens_t((double)h[i], (double)a[0]);
            }
        }
        else if (n==1)
        {
            for(int i = 0; i < m; i++)
            {
                y[i] = boost::math::owens_t((double)h[0], (double)a[i]);
            }
        }    
          
        // Return output
        outputs[0] = y;
    }
};

