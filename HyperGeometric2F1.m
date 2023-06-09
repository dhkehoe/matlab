function Result = HyperGeometric2F1(a, b, z)
    % Evaluation of the hypergeometric function with p = 2 numerator and q = 1 denominator coefficients
    %
    % - Syntax -
    %
    % Result = HyperGeometric2F1(a, b, z)
    %
    % - Inputs -
    %
    % a                 - 2-element vector (numerator coefficients).
    % b                 - 1-element vector (denominator coefficients).
    % z                 - Matrix with values at which the function is evaluated.
    %
    % - Outputs -
    %
    % Result            - Matrix which contains the results of size(z).
    %
    % - Test -
    %
    % HyperGeometric2F1([-1.2 1], 1.5, [-2 0.5])
    %
    % ported from C: http://www.mathworks.com/matlabcentral/fileexchange/43865-gauss-hypergeometric-function
    global Debug
    Debug = false;
    
    CallMessage(a, b, z)
    
    if numel(a) ~= 2 || numel(b) ~= 1
        error('Input a must be a 2-element vector and b must be a scalar.') 
    end
    z_size                  = size(z);
    Result                  = reshape(hyp2F1(a, b, z(:)), z_size);
    ReturnMessage(Result)    
    
end
function Result = hyp2F1(a, b, z)
    CallMessage(a, b, z)
    
    %% Preparation
    z_numel                 = numel(z);
    
    LeftIndices             = true(z_numel, 1);
    Result                  = zeros(z_numel, 1);
    
    MaxError                = 1e-12;
    s                       = 1 - z;
    d                       = b - a(1) - a(2);
    p                       = b - a(1);
    r                       = b - a(2);
    
    a1_int                  = round(a(1));
    a2_int                  = round(a(2));
    b_int                   = round(b);
    d_int                   = round(d);
    p_int                   = round(p);
    r_int                   = round(r);
    
    IsA1NegativeInt         = a(1)  <= 0 && a(1)== a1_int;
    IsA2NegativeInt         = a(2)  <= 0 && a(2)== a2_int;
    IsBNegativeInt          = b     <= 0 && b   == b_int;
    IsPNegativeInt          = p     <= 0 && p   == p_int;
    IsRNegativeInt          = r     <= 0 && r   == r_int;
              
    %% Calculation for all indices
    
    %
    if (a(1) == 0 || a(2) == 0) && b ~= 0
        Result              = ones(z_numel, 1);
        ReturnMessage(Result), return
    end
    
    %
    if IsBNegativeInt
        if (IsA1NegativeInt && (a1_int > b_int)) || (IsA2NegativeInt && (a2_int > b_int))
            [Result, Error]	= hyt2f1(a, b, z);
            if any(Error > MaxError)
                warning('Error threshold not reached.')
            end
            ReturnMessage(Result), return
        else
            Result       	= inf(z_numel, 1);
            warning('Overflow range error. Corresponding values are set to inf.')
            ReturnMessage(Result), return
        end
    end
    
    % 
    if (IsA1NegativeInt || IsA2NegativeInt)
        [Result, Error]     = hyt2f1(a, b, z);
        if any(Error > MaxError)
            warning('Error threshold not reached.')
        end
        ReturnMessage(Result), return
    end  
       
    %% Calculation for specific indices
    
    %
    if d <= -1 && ~(IsA1NegativeInt || IsA2NegativeInt)
        if abs(d - d_int) < eps
            Result(LeftIndices)   	= s(LeftIndices).^d .* hyp2F1([b - a(1), b - a(2)], b, z(LeftIndices));
            ReturnMessage(Result), return
        else
            Indices               	= s >= 0 & LeftIndices;
            if any(Indices)
                Result(Indices)   	= s(Indices).^d .* hyp2F1([b - a(1), b - a(2)], b, z(Indices));
                LeftIndices       	= LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
            end
        end
    end
    
    %
    Indices                        	= z == 0 & LeftIndices;
    Result(Indices)              	= 1;
    LeftIndices                     = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
    
    %
    if d <= 0 && ~(IsA1NegativeInt || IsA2NegativeInt)  
        Indices                   	= z == 1 & LeftIndices;
        Result(Indices)           	= Inf;
        LeftIndices                 = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
        if any(Indices)
            warning('Overflow range error. Corresponding values are set to inf.')
        end
    end
    %
    if abs(a(1) - b) < eps
        Indices                 	= (abs(z) < 1.0 | z == -1.0) & LeftIndices;
        Result(Indices)             = s(Indices).^-a(2);
        LeftIndices                 = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
    elseif abs(a(2) - b) < eps
        Indices                   	= (abs(z) < 1.0 | z == -1.0) & LeftIndices;
        Result(Indices)            	= s(Indices).^-a(1);
        LeftIndices                 = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
    end
     
    %
    t1                           	= abs(a(2) - a(1));
    
    if abs(t1 - round(t1)) > eps
        Indices                   	= z < -2.0 & LeftIndices;
        if any(Indices)
            % This transform has a pole for b-a integer, and may produce large cancellation errors for |1/x| close 1.
            p1                  	= hyp2F1([a(1), 1 - b + a(1)], 1 - a(2) + a(1), 1.0 ./ z(Indices));
            q                    	= hyp2F1([a(2), 1 - b + a(2)], 1 - a(1) + a(2), 1.0 ./ z(Indices));
            p1                    	= p1 .* (-z(Indices)).^(-a(1));
            q                    	= q .* (-z(Indices)).^(-a(2));
            t1                    	= gamma(b);
            s1                   	= t1 * gamma(a(2) - a(1)) / (gamma(a(2)) * gamma(b - a(1)));
            y                    	= t1 * gamma(a(1) - a(2)) / (gamma(a(1)) * gamma(b - a(2)));
            Result(Indices)         = s1 * p1 + y * q;
            LeftIndices             = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
        end
    end
    
    if abs(a(1)) < abs(a(2))
        Indices                 	= z < -1.0 & LeftIndices;
        if any(Indices)
            Result(Indices)         = s(Indices).^-a(1) .* hyp2F1([a(1), b - a(2)], b, z(Indices) ./ (z(Indices) - 1));
            LeftIndices             = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
        end
    else
        Indices                   	= z < -1.0 & LeftIndices;
        if any(Indices)
            Result(Indices)         = s(Indices).^-a(2) .* hyp2F1([a(2), b - a(1)], b, z(Indices) ./ (z(Indices) - 1));
            LeftIndices             = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
        end
    end
    
    %
    Indices                       	= abs(z) > 1 & LeftIndices;
    Result(Indices)                 = Inf;
    LeftIndices                     = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
    if any(Indices)
    	warning('Overflow range error. Corresponding values are set to inf.')
    end
    
    %
	if IsPNegativeInt || IsRNegativeInt
        if (d >= 0) % Alarm exit
            Indices               	= (abs(z) == 1 & z > 0) & LeftIndices;
            if any(Indices)
                [TmpResult, Error]	= hys2f1([b - a(1), b - a(2)], b, z(Indices));
                Result(Indices)     = TmpResult .* s(Indices).^d;
                LeftIndices         = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
                if any(Error > MaxError)
                    warning('Error threshold not reached.')
                end
            end
        else
            Indices               	= (abs(z) == 1 & z > 0) & LeftIndices;
            Result(Indices)         = Inf;
            LeftIndices             = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
            if any(Indices)
                warning('Overflow range error. Corresponding values are set to inf.')
            end
        end
	end
    if d <= 0.0
        Indices                  	= (abs(z) == 1 & z > 0) & LeftIndices;
        Result(Indices)             = Inf;
        LeftIndices                 = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
        if any(Indices)
            warning('Overflow range error. Corresponding values are set to inf.')
        end
    else
        Indices                  	= (abs(z) == 1 & z > 0) & LeftIndices;
        Result(Indices)             = gamma(b) * gamma(d) ./ (gamma(p) * gamma(r));
        LeftIndices                 = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
    end
    
    if d <= -1.0
        Indices                   	= abs(z) == 1 & LeftIndices;
        Result(Indices)             = Inf;
        LeftIndices                 = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
        if any(Indices)
            warning('Overflow range error. Corresponding values are set to inf.')
        end
    end
    
    %
    if d < 0
        
        % Try the power series first
        [TmpResult, Error]       	= hyt2f1(a, b, z(LeftIndices));
        IndicesShort             	= Error < MaxError;
        if any(~LeftIndices)
            Indices2                = logical(InsertAt1D(IndicesShort, find(~LeftIndices), 0, 3));
        else
            Indices2                = IndicesShort;
        end
        Result(Indices2)            = TmpResult(IndicesShort);
        LeftIndices                 = LeftIndices & ~Indices2; if ~any(LeftIndices), ReturnMessage(Result), return, end
        
        % Apply the recurrence if power series fails
        aid                        	= 2 - d_int;
        e                        	= b + aid;
        d2                        	= hyp2F1([a(1), a(2)], e, z(LeftIndices));
        d1                         	= hyp2F1([a(1), a(2)], e + 1.0, z(LeftIndices));
        q                       	= a(1) + a(2) + 1.0;
        
        for i = 0 : aid - 1
            r                     	= e - 1.0;
            y                     	= (e * (r - (2.0 * e - q) * z(LeftIndices)) .* d2 + (e - a(1)) * (e - a(2)) * z(LeftIndices) .* d1) ./ ...
                                      (e * r * s(LeftIndices));
            e                      	= r;
            d1                     	= d2;
            d2                    	= y;
        end
        
        Result(LeftIndices)         = y;
        
    elseif IsPNegativeInt || IsRNegativeInt
        
        [TmpResult, Error]        	= hys2f1([b - a(1), b - a(2)], b, z(LeftIndices));
        Result(LeftIndices)      	= TmpResult .* s(LeftIndices).^d;
        if any(Error > MaxError)
            warning('Error threshold not reached.')
        end
        
    else
        
        [TmpResult, Error]      	= hyt2f1(a, b, z(LeftIndices));
        Result(LeftIndices)     	= TmpResult;
        if any(Error > MaxError)
            warning('Error threshold not reached.')
        end
        
    end    
        
    ReturnMessage(Result)
    
end
% Apply transformations for |z| near 1 then call the power series
function [Result, Error] = hyt2f1(a, b, z)
    CallMessage(a, b, z)
        
    %% Preparation
    z_numel                      	= numel(z);
    
    LeftIndices                    	= true(z_numel, 1);
    Result                          = zeros(z_numel, 1);
    s                             	= 1 - z;
    d                              	= b - a(1) - a(2);
    
    a1_int                        	= round(a(1));
    a2_int                         	= round(a(2));
    d_int                          	= round(d);
    
    IsA1NegativeInt                	= a(1)  <= 0 && a(1)== a1_int;
    IsA2NegativeInt                	= a(2)  <= 0 && a(2)== a2_int;
    MaxIterations                  	= 10000;
    MaxError                      	= 1e-12;
    Error                         	= zeros(z_numel, 1);
    
    MACHEP                        	= 1.4e-15;
    
    %% Calculation  
    if ~(IsA1NegativeInt || IsA2NegativeInt)
        if a(2) > a(1)
            Indices              	= z < -0.5 & LeftIndices;
            if any(Indices)
                Result(Indices)     = s(Indices).^-a(1) .* hys2f1([a(1), b - a(2)], b, -z(Indices) ./ s(Indices));
                LeftIndices         = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
            end
        else
            Indices              	= z < -0.5 & LeftIndices;
            if any(Indices)
                Result(Indices)     = s(Indices).^-a(2) .* hys2f1([b - a(1), a(2)], b, -z(Indices) ./ s(Indices));
                LeftIndices         = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
            end
        end
    end
    if ~(IsA1NegativeInt || IsA2NegativeInt)
        
        if d ~= d_int
            
            % Try the power series first
            Indices               	= z > 0.9 & LeftIndices;
            if any(Indices)
                
                [TmpResult, TmpError1] = hys2f1(a, b, z(Indices));
                Result(Indices)     = TmpResult;
                Error(Indices)    	= TmpError1;
                LeftIndices         = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
                if any(TmpError1 > MaxError)
                    warning('Error threshold not reached.')
                end
                               
            end
            
            % If power series fails, then apply AMS55 #15.3.6            
            Indices              	= z > 0.9 & LeftIndices;
            if any(Indices)
                
                [q, TmpError1]   	= hys2f1(a, 1.0 - d, s(Indices));
                Sign               	= 1;
                tmp               	= gamma(d);
                w                 	= log(abs(tmp));
                Sign               	= Sign * sign(tmp);
                tmp               	= gamma(b - a(1));
                w                  	= w - log(abs(tmp));
                Sign              	= Sign * sign(tmp);
                tmp               	= gamma(b - a(2));
                w                 	= w - log(abs(tmp));
                Sign             	= Sign * sign(tmp);
                q                 	= q * Sign * exp(w);
                [r, TmpError2]   	= hys2f1([b - a(1), b - a(2)], d + 1.0, s(Indices));
                r                 	= r .* s(Indices).^d;
                Sign              	= 1;
                tmp               	= gamma(-d);
                w                 	= log(abs(tmp));
                Sign               	= Sign * sign(tmp);
                tmp                	= gamma(a(1));
                w                  	= w - log(abs(tmp));
                Sign               	= Sign * sign(tmp);   
                tmp               	= gamma(a(2));
                w                 	= w - log(abs(tmp));
                Sign               	= Sign * sign(tmp);
                r                  	= r * Sign * exp(w);
                y                 	= q + r;
                % estimate cancellation error
                q                  	= abs(q);
                r                 	= abs(r);
                if (q > r)
                    r              	= q;
                end
                Error(Indices)      = Error(Indices) + (TmpError1 + TmpError2 + (MACHEP * r) ./ y);
                Result(Indices)     = y * gamma(b);
                LeftIndices         = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
                
            end
            
        elseif any(z(LeftIndices) > 0.9)
            
            % Psi function expansion, AMS55 #15.3.10, #15.3.11, #15.3.12
            % Although AMS55 does not explicitly state it, this expansion fails
            % for negative integer a or b, since the psi and Gamma functions involved have poles.  
            
            Indices                 = z > 0.9 & LeftIndices;
            
            if (d_int >= 0)
                e               	= d;
                d1              	= d;
                d2              	= 0.0;
                aid              	= d_int;
            else
                e                  	= -d;
                d1                 	= 0;
                d2               	= d;
                aid               	= -d_int;
            end
            ax                   	= log(s(Indices));
            % sum for t = 0
            y                     	= psi(1) + psi(1 + e) - psi(a(1) + d1) - psi(a(2) + d1) - ax;
            y                    	= y / gamma(e + 1.0);
            p                   	= (a(1) + d1) * (a(2) + d1) * s(Indices) / gamma(e + 2.0); % Poch for t=1
            t                       = 1;
            
            LoopIndices             = true(numel(ax), 1);
            q                    	= zeros(numel(ax), 1);
            
            while true
                                
                r                 	= psi(1 + t) + psi(1 + t + e) - psi(a(1) + t + d1) - psi(a(2) + t + d1) - ax(LoopIndices);
                q(LoopIndices)    	= p(LoopIndices) .* r;
                y(LoopIndices)     	= y(LoopIndices) + q(LoopIndices);
                p(LoopIndices)    	= p(LoopIndices) .* s(LoopIndices) * (a(1) + t + d1) / (t + 1);
                p(LoopIndices)    	= p(LoopIndices) * (a(2) + t + d1) / (t + 1 + e);
                t                  	= t + 1;
                               
                if (t > MaxIterations)
                    
                    warning('Too many iterations.')
                    y(LoopIndices)	= NaN;
                    Error(Indices)	= isnan(y); % Set Error to 1 where isnan(y);
                    break
                    
                end
                           
                IndicesToRemove    	= ~(y == 0 | abs(q ./ y) > eps);
                LoopIndices        	= LoopIndices & ~IndicesToRemove;
                
                if ~any(LoopIndices) 
                    break
                end
                
            end
                       
            if d_int == 0
                
                Result(Indices)     = y * gamma(b) / (gamma(a(1)) * gamma(a(2)));
                LeftIndices         = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
                
            else
                
                y1               	= 1;
                if aid ~= 1
                    t            	= 0;
                    p              	= 1;
                    for i = 1 : aid - 1
                        r          	= 1 - e + t;
                        p        	= p * s(Indices) * (a(1) + t + d2) * (a(2) + t + d2) / r;
                        t       	= t + 1;
                        p         	= p / t;
                        y1         	= y1 + p;
                    end
                    
                end
                p                	= gamma(b);
                y1                	= y1 * gamma(e) * p / (gamma(a(1) + d1) * gamma(a(2) + d1));
                
                y                 	= y * p / (gamma(a(1) + d2) * gamma(a(2) + d2));
                if (bitand(aid, 1) ~= 0)
                    y = -y;
                end
                fprintf('xxx = %d\n', y)
                q                	= s(Indices).^d_int;
                if (d_int > 0.0)
                    y             	= y .* q;
                else
                    y1            	= y1 .* q;
                end
                Result(Indices)     = y + y1;
                LeftIndices         = LeftIndices & ~Indices; if ~any(LeftIndices), ReturnMessage(Result), return, end
                
            end
            
        end
    end
    % Use defining power series if no special cases
    [TmpResult, TmpError]        	= hys2f1(a, b, z(LeftIndices));
    Result(LeftIndices)           	= TmpResult;
    Error(LeftIndices)           	= TmpError;
    ReturnMessage(Result)
    
end
% Defining power series expansion of Gauss hypergeometric function
function [Result, Error] = hys2f1(a, b, z)
    CallMessage(a, b, z)
    %% Preparation
    z_numel                     = numel(z);
    
    a2_int                      = round(a(2));
    
    MaxIterations               = 10000;
    Error                       = zeros(z_numel, 1);
    
    MACHEP                      = 1.4e-15;
    intflag                     = 0;
    
    %% Calculation  
    if abs(a(2)) > abs(a(1))
        % Ensure that |a| > |b| ... 
        f                       = a(2);
        a(2)                    = a(1);
        a(1)                    = f;
    end
    if a(2) == a2_int && a2_int <= 0 && abs(a(2)) < abs(a(1))
        % .. except when `b` is a smaller negative integer
        f                       = b;
        b                       = a;
        a                       = f;
        intflag                 = 1;
    end
    if (abs(a(1)) > abs(b) + 1 || intflag) && abs(b - a(1)) > 2 && abs(a(1)) > 2
        % |a| >> |c| implies that large cancellation error is to be expected.
        % We try to reduce it with the recurrence relations
        [Result, Error]         = hyp2f1ra(a, b, z);
        ReturnMessage(Result), return
    end
    i                           = 0;
    umax                        = zeros(z_numel, 1);
    f                           = a(1);
    g                           = a(2);
    h                           = b;
    s                           = ones(z_numel, 1);
    u                           = ones(z_numel, 1);
    k                           = 0;
   
    if abs(h) < eps
        Error                   = ones(z_numel, 1);
        Result                  = inf;
        ReturnMessage(Result), return
    end
    
    LoopIndices                 = true(z_numel, 1);
    
	while true
           
        m                       = k + 1.0;
        u(LoopIndices)          = u(LoopIndices) .* ((f + k) * (g + k) * z(LoopIndices) / ((h + k) * m));
        s(LoopIndices)          = s(LoopIndices) + u(LoopIndices);
        k                       = abs(u(LoopIndices)); % remember largest term summed
        Indices                 = k > umax(LoopIndices);
        umax(Indices)           = k(Indices);        
        k                       = m;
        i                       = i + 1;
        
        if (i > MaxIterations) % should never happen
            Error(LoopIndices)  = 1;
            break
        end
        
        IndicesToRemove         = s == 0 | abs(u ./ s) <= MACHEP;
        LoopIndices             = LoopIndices & ~IndicesToRemove;
        if ~any(LoopIndices)
            Error              	= (MACHEP * umax) ./ abs(s) + (MACHEP * i); % estimated relative error
            break
        end
        
    end
    
    Result                      = s;
    ReturnMessage(Result)
    
end
%  Evaluate hypergeometric function by two-term recurrence in `a`.
%  This avoids some of the loss of precision in the strongly alternating
%  hypergeometric series, and can be used to reduce the `a` and `b` parameters
%  to smaller values.
%  
%  AMS55 #15.2.10
function [Result, Error] = hyp2f1ra(a, b, z)
    CallMessage(a, b, z)
    %% Preparation
    
    z_numel                 = numel(z);
    
    MaxIterations       	= 10000;
    
    Error                  	= zeros(z_numel, 1);
    
    %% Calculation
    % Don't cross c or zero
    if (b < 0 && a(1) <= b) || (b >= 0 && a(1) >= b)
        da                	= round(a(1) - b);
    else
        da                	= round(a(1));
    end
    
    t                      	= a(1) - da;
    % assert(da != 0);
    if da == 0
        warning('da is zero.')
    end
    if abs(da) > MaxIterations
        warning('Too expensive to compute this value, so give up.')
        Error            	= ones(z_numel, 1);
        Result              = NaN(z_numel, 1);
        ReturnMessage(Result), return
    end
    if da < 0
        
        % Recurse down
        [f1, TmpError]      = hys2f1([t, a(2)], b, z);
        Error             	= Error + TmpError;
        [f0, TmpError]      = hys2f1([t - 1, a(2)], b, z);
        Error             	= Error + TmpError;
        t                  	= t - 1;
        
        for n = 1 : -da - 1
            f2           	= f1;
            f1            	= f0;
            f0            	= -(2 * t - b - t * z + a(2) * z) / (b - t) .* f1 - t * (z - 1) / (b - t) .* f2;
            t              	= t - 1;
        end
        
    else
        
        % Recurse up
        [f1, TmpError]      = hys2f1([t, a(2)], b, z);
        Error             	= Error + TmpError;
        [f0, TmpError]      = hys2f1([t + 1, a(2)], b, z);
        Error             	= Error + TmpError;
        t                  	= t + 1;
        
        for n = 1 : da - 1
            f2           	= f1;
            f1             	= f0;
            f0             	= -((2 * t - b - t * z + a(2) * z) * f1 + (b - t) * f2) / (t * (z - 1));
            t            	= t + 1;
        end
        
    end
    Result                  = f0;
    ReturnMessage(Result)
    
end
function CallMessage(a, b, z)
    global Debug
    if Debug
    
        StackInformation    = dbstack;
        if length(StackInformation) >= 2
            FunctionName    = StackInformation(2).name;
        else
            FunctionName    = '';
        end
        fprintf('%s was called with a1 = %f, a2 = %f, b = %f, z = %f.\n', FunctionName, a(1), a(2), b, z)
    
    end
    
end
function ReturnMessage(Result)
    global Debug
    if Debug
    
        StackInformation    = dbstack;
        if length(StackInformation) >= 2
            FunctionName    = StackInformation(2).name;
        else
            FunctionName    = '';
        end
        fprintf('%s returned %f.\n', FunctionName, Result)
    
    end
    
end
function Result = InsertAt1D(Data, InsertPositions, InsertValues, PositionMode)
    %% Check input data
    
    if ~isvector(Data)
        error('Data must a vector.')
    end
    
    if ~isvector(InsertPositions)
        error('InsertPositions must a vector.')
    end
    
    if ~isvector(InsertValues)
        error('InsertValues must a vector.')
    end
    
    if numel(InsertValues) > 1 && numel(InsertPositions) ~= numel(InsertValues)
        error('InsertPositions and InsertValues must be the same length.')
    end
    
    %% Preparation
    
    Data            = Data(:);
    InsertPositions = InsertPositions(:);
    InsertValues    = InsertValues(:);
    switch PositionMode
        case 1
            InsertPositions             = cumsum(InsertPositions + 1) - 1;
        case 2
            InsertPositions             = cumsum([InsertPositions(1, 1); diff(InsertPositions) + 1]);
        case 3
            
        otherwise
            error('Specified position mode not supported.')
    end
       
    NewLength                       = length(Data) + length(InsertPositions);
    
    if min(InsertPositions) < 1 || max(InsertPositions) > NewLength
        error('At least one insert position exceeds the range from 0 to data length + 2.')
    end
    
    Result(NewLength, 1)            = NaN;   
    Result(InsertPositions)         = InsertValues;
    
    DataPositions                   = 1 : length(Result); 
    DataPositions(InsertPositions)  = [];
    
    Result(DataPositions)           = Data;
        
end
