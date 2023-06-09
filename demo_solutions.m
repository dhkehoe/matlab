% Overview of many MATLAB features with an emphasis on visual neuroscience.

%% Creating matrices/vectors

% 1a.  Make x equal to a vector from 1 to 10.
x = 1:10;
x = 1:1:10; % Interval of 1 is the default so this is redundant
x = linspace(1,10,1);
x = [1 2 3 4 5 6 7 8 9 10];

% 1b.  Make x equal to a vector from -2pi to 2pi in 1000 steps.
x = linspace(-2*pi,2*pi,1000);
x = -2*pi : (4*pi) / (1000-1) : 2*pi;

% 1c.  Make x equal to a column matrix that consists of the numbers 20 to 30.
x = (20:30)';
x = linspace(20,30,1)';

% 1d.  Make x equal to a matrix that has the numbers 100 to 200 in the first
% row and 300 to 400 in the second row.
x = [100:200; 300:400];
x = reshape([100:200,300:400],101,2);

%% Indexing

% 2.  In the following questions, use a matrix m that is a 20 x 5 matrix of
% normally distributed random numbers.  Resample a new matrix m for each
% question, e.g., don't let any changes to the matrix m in part (a) affect
% the matrix m that you use in part (b).
m = randn(20,5); copy = m;

% 2a.  Make x equal to the first row of m.
x = m(1,:);

% 2b.  Make x equal to all the elements of m that are greater than zero.
x = m( m>0 );
x = m( find(m>0) );

% 2c.  Make x equal to all the elements of m that are less than -1 or
% greater than 1.
x = m( m<-1 | m>1 );
x = m( find(m<-1 | m>1) );

% 2d.  Make x a row vector with elements that are the maximum of each row
% of m.
x = max(m,[],2);
x = max( m' );

% 2e.  Make x equal to one if all elements of m are greater than zero, and
% zero otherwise.
x = all( m(:)>0 );
x = sum( m(:)>0 ) == numel(x);

% 2f.  Set any elements of m in the third column that are less than zero to
% NaN.
m(m(:,3)<0,3) = NaN;
m = copy;

% 2g.  Set any rows of m that have a value less than -1.5 to NaN.
m(min(m,[],2)<-1.5,:) = NaN;
m(sum(m<-1.5,2)>0,:) = NaN;
m = copy;

% 2h.  Set x to the number of elements in m that are greater than 2.
x = sum(m(:)>2);

% 2i.  Delete the fourth row of m.
m(4,:) = [];
m = copy;
m = m([1:3,5:end],:);
m = copy;

% 2j.  Suppose you didn't know the size of matrix m.  Set a equal to the
% number of rows in m, and b equal to the number of columns.
[a,b] = size(m);

% 2k.  Suppose you didn't know the size of matrix m.  Set c equal to the
% number of elements in m.
c = numel(m);
c = prod(size(m));

% 2l.  Set the fourth column of m to zero in rows where the third column is
% less than zero.
m( m(:,3)<0,4) = 0;
m = copy;

% 2m.  Set f equal to the linear indices of the elements of m that are less
% than zero.
f = find(m<0);

% 2n.  Use find() to set the elements of m that are less than zero to NaN.
m(find(m<0)) = NaN;
m = copy;

% 2o.  Set x to the rows of m that are less than zero in the third column.
x = m(m(:,3)<0,:);


%% Matrix operations
% For questions 3a, 3b, 3c, 3d, and 3e, create the follow vectors 'x' and
% 'y' as follows:
%   rng(18);
%   x = randn(20,1)*2+2;
%   y = x+randn(20,1)*4;

%  3a. Set 'z' equal to the product of every row-wise element of 'x' and
%  'y'.
z = x .* y;

%  3b. Set 'z' equal to the Euclidean distance from the origin of each
% row-wise pair of (x,y) scores.
z = sqrt(x.^2+y.^2);
z = sqrt(sum([x,y].^2,2));

%  3c. Set 'z' equal to the sum of squared 'x' scores using matrix
%  multiplication and without using sum() or the ^ operator.
z = x' * x;

%  3d. Set 'z' equal to the sum of every 'x' score multiplied by every
% other 'y' score without using meshgrid().
z = sum( x*y' ,'all');
z = sum( x*y' ,[1,2]);
z = sum(reshape( x*y' ,[],1));

%  3e.  Set 'z' equal to the covariance matrix of 'x' and 'y' using matrix
%  multiplication of 'x' and 'y' without using cov().
xy = [x,y]-mean([x,y]);
z = (xy' * xy) / (numel(x)-1);

%  3f. Create the following vector 'x':
%   x = (0:255)';
% Create a matrix with 5 columns, where 'x' is repeated across each column.
% However, the vales in the first column are scaled by the proportion (1), 
% the values in the second column are scaled by the proportion (.8), the 
% values in the third column are scaled by the proportion (.6), the values
% in the fourth column are scaled by the proportion (.4), and the values in
% the fifth column are scaled by the proportion (.2). Solve this without
% using repmat().
z = (0:255)' * linspace(.2,1,5);
z = (0:255)' * (1:-.2:.2);
z = (0:255)' * fliplr(1:5)/5;

%  3g. Using only matrix operations, solve for x, y, and z in the following
% system of linear equations, setting 'a' equal to the vector [x; y; z]
%          x/2  +   z  =  6
%        -3y    +   z  = 11
%  2x  +   y    +  3z  = 15
a = inv([1/2,0,1;0,-3,1;2,1,3]) * [6;11;15];
a = [1/2,0,1;0,-3,1;2,1,3] \ [6;11;15];
% a = [-4; -1; 8]


%% Printing text and data

% 4.  Set a = 3.14 and b = 'abc'.  Use fprintf() to print the following
% message:  The value of a is 3.1400 and the value of b is 'abc'.
a = 3.14; b = 'abc';
fprintf('The value of a is %.4f and the value of b is ''%s''.\n',a,b);

% 5.  Write a for loop that prints all the prime numbers between 1 and 100.
for i = 1:100
    if isprime(i)
        fprintf('%d\n',i);
    end
end

% 6.  Use fprintf() to write the prime numbers between 1 and 100 to a text
% file called prime.txt
fid = fopen('prime.txt',wt);
for i = 1:100
    if isprime(i)
        fprintf(fid,'%d\n',i);
    end
end
fclose(fid);

% 7.  Write a loop that prints the first prime number greater than 100.
i = 100;
while ~isprime(i)
    i = i+1;
end
fprintf('\nThe first prime number greater than 100 is %d\n',i);

%% Functions

% 8.  Write a function that takes two input arguments.  The function
% returns 1 if the second argument is greater, -1 if the first argument
% is greater, and 0 if the two arguments are equal.
function c = fun(a,b)
if a > b
    c = -1;
elseif b > a
    c = 1;
else
    c = 0;
end
end
fun = @(a,b) sign(b-a);

% 9. Write an inline function called lbs2kg() that converts imperial pounds
%  to metric kgs
lbs2kg = @(x) x*.453592;
lbs2kg = @(x) x/2.20462;

% 10. Write a recursive function to compute a factorial
function x = factorial(n)
if n==1, x = 1;
else, x = n*factorial(n-1);
end
end

% 11.  Use fminsearch to find the values of x and y that minimize
% the function (x-3)^2 + (y-2)^2
fun = @(p) (p(1)-3)^2 + (p(2)-2)^2;
p_hat = fminsearch(fun,[1 1]);

% 12.  Use fminsearch to find the number that has the minimum sum of
% squared distances to the numbers 1, 5, 10, and 20.
data = [1,5,10,20];
errfun = @(p) sum( (data-p).^2 );
p_hat = fminsearch(errfun,1);
p_hat = fminsearch( @(p)sum( (data-p).^2 ),1);

% 13.  Write a function called 'printtime' that takes a value of uint64
% system time (as returned by the MATLAB function tic) as an argument. Call
% this variable 't'. This function will print a nicely formatted string to
% indicate the amount of time that has elapsed since 't' with this format:
%
% Time elapsed (h:mm:ss.ms):
% x.xx:xx.xx
%
% where 'h' is hours, 'm' is minutes, 's' is seconds, and 'ms' is
% milliseconds.
%
% Additionally, throw an error if 't' is not of type uint64. Secondly,
% provide an optional output for the function. The output is a 3-element
% vector with the elapsed [hours,minutes,seconds.milliseconds]. If an
% output argument is called by the user, the function does not print.
function varargout = printtime(t)
if ~isa(t,'uint64)'), error('''t'' must be type uint64'), end
out = [floor(toc(t)/60^2),floor(rem(toc(t),60^2)/60),rem(toc(t),60)];
if nargout, varargout{1} = out;
else, fprintf('Elapsed time (h:mm:ss.ms):\n%d:%02d:%05.2f',out);
end
end


%%  Advanced matrix manipulations

% 14.  Make 'im' equal to a 3-dimensional matrix with the dimensions of
% (200,200,3) with every index equal to zero. Display im with the imagesc()
% function. This is a blank (black) image. Now, modify this image so that
% the top one third (1/3) is red, the middle one third is green, and the
% bottom one third is blue
im = zeros(200,200,3); imagesc(im);
s = size(im,1);
im(1:ceil( s*(1/3) ),:,1) = 1;
im(ceil( s*(1/3) )+1 : ceil( s*(2/3) ),:,2) = 1;
im(ceil( s*(2/3)+1 ) : end,:,3) = 1;
imagesc(im);

im = zeros(200,200,3);
for i = 1:3, im( ceil(200*((i-1)/3))+1 : ceil(200*(i/3)),:,i) = 1; end

% 15.  Use coordinate matrices to make two 100 x 100 images of a circle
% with a radius of 40 pixels.
% First image: black background and white circle
x = 1:100; x = x - round(length(x)/2); y = x';
[x,y] = meshgrid(x,y);
im = sqrt( x.^2 + y.^2 )<=40;
imshow(im);

% Second image: blue background and magenta circle
x = 1:100; x = x - round(length(x)/2); y = x';
[x,y] = meshgrid(x,y);
c = sqrt( x.^2 + y.^2 ) <= 40;
im = zeros(100,100,3);
im(:,:,1) = c;
im(:,:,3) = 1;
imshow(im);

% 16. Create a Gabor patch that's 800 x 800 pixels, with an orientation of 
% 45 degrees, phase of pi/2, a frequency of 30 pixels, standard deviation
% of 50 pixels, an aspect ratio of 1/2, a contrast of 25%, and a background
% luminance of 50%. Display stimulus with imshow(). HINT: to render the
% stimulus properly, rescale to 8-bit color depth, take the floor, and
% convert to uint8 data type.
theta = pi/4;
lambda = 30;
psi = pi/2;
sigma = 50;
gamma = 1/2;
contrast = .25;
bckgrdlum = .5;
[x,y] = meshgrid(-400:399,-400:399);
x = x*cos(theta)+y*sin(theta); % rotate x
y = -x*sin(theta)+y*cos(theta); % rotate y
gabor = cos(x./lambda.*2*pi+psi) ...
    .* exp( -x.^2./(2*sigma^2) - y.^2./(2*sigma^2/gamma)) ...
    .*contrast/2+bckgrdlum;
imshow(uint8(floor(gabor*255))); daspect([1,1,1]);

%% Graphics/handles

% 17.  Set x equal to 20 samples from -pi to pi.  Set y equal to the tangent
% of x.  Plot y versus x with a solid green line and no data point markers.
% Label the axes 'angle' and 'tangent'.
x = linspace(-pi,pi,20); y = tan(x);
plot(x,y,'g-'), xlabel('Angle'), ylabel('Tangent');
% Shortcut (if the label only consists of one word):
xlabel Angle,
ylabel Tangent;

% 18.  Use plot to plot a red sine wave and a blue cosine wave on the
% interval [0,2*pi], and use a handle for the axis object to set the width
% of the lines to 5 pixels, add a figure legend, add a title, and label the
% x and y axes.
x = linspace(0,2*pi);
h = plot(x,sin(x),'r-'); set(h,'LineWidth',5); hold on,
h = plot(x,cos(x),'b-'); set(h,'LineWidth',5);
xlabel('X'), ylabel('Y'), title('Sine and Cosine Functions'), legend('Sin(x)','Cos(x)');

% 19.  Use fplot to plot a sine wave on the interval [0,2*pi], and use
% 'saveas' to save the figure to an .eps file called sine.eps.
hold off, fplot(@(x) sin(x),[0,2*pi]);
saveas(gcf,'sine.eps');

% 20.  Repeat the plot from the previous analysis, but now save the figure
% to a .pdf file called sine.pdf, using 300 dots-per-inch resolution, with
% the correct aspect ratio (i.e. eliminating white space below/above the
% figure), using the 'print' function.
hold off, fplot(@sin,[0,2*pi]);
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'Renderer','painters','PaperUnits','Inches','PaperPositionMode','Manual',...
    'PaperPosition',[0,0,pos(3),pos(4)],...
    'PaperSize',[pos(3),pos(4)]);
print(f,filename,'-dpdf',['-r',num2str(300)]);

%% Statistical model fitting
% For these questions, ensure you have the Statistics and Machine Learning
% Toolbox installed for MATLAB.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 21.  Generate a randomly generated distrubution of 1000 samples from the
% gamma distribution with parameters alpha = 10, beta = 4. Use maximum
% likelihood estimation to fit to this data (1) a gamma probability density
% function (PDF) and (2) a skew-normal PDF (see below):
% 
%  sknormpdf = @(x,mu,sigma,omega) 2/sigma*normpdf((x-mu)./sigma).*normcdf((x-mu)./sigma.*omega);
% 
% Plot both fitted models against the data. Compare the model fits with a
% ratio test.
%
% HINT: use initial parameter guesses of [20,20,1] for the skew-normal
% PDF model.
rng(1);
x = gaminv(rand(1000,1),10,4);
[phat1,ll(1)] = fminsearch(@(p)-sum(log(gampdf(x,p(1),p(2)))),[1,1]);
[phat2,ll(2)] = fminsearch(@(p)-sum(log(sknormpdf(x,p(1),p(2),p(3)))),[20,20,1]);
fprintf('ratio-test, p = %.3f\n',1-chi2cdf(abs(2*diff(-ll)),1));
d = 0:.1:max(x);
hold off; histogram(x,'normalization','pdf'); hold on;
h(1) = plot(d,gampdf(d,phat1(1),phat1(2)),'r');
h(2) = plot(d,sknormpdf(d,phat2(1),phat2(2),phat2(3)),'b');
xlabel('$x$','Interpreter','latex');
ylabel('$P(x)$','Interpreter','latex');
legend(h,{'Gamma','Skew-Normal'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 22. Create some artifical data by first creating a straight line (slope =
% 2.2, intercept = 3), and then add some normally distributed, random noise
% to the data (standard deviation = 12). Fit a linear function to the data
% using the following techniques:
% (a) Minimizing an ordinary least squares loss function
% (b) Solving for the beta matrix in closed-form using linear algebra
% (c) Maximizing the likelihood function assuming Gaussian error
% (d) Using the Statistics and Machine Learning Toolbox, e.g., fitglm()
%   HINT: Use fminsearch() for (a) and (c)

% Fit linear function
rng(18)
linfun = @(x,p) p(1) + x.*p(2); % Define linear function
x = (-5:2:15)'; y = linfun(x,[2.2 3]); % Create some data
y = y+randn(size(y)).*12; % Add Gaussian noise to data (SD = 12)

p_hat = fminsearch(@(p) sum( (y-linfun(x,p)).^2 ), [1,1]); % Least squares loss function
X = [ones(size(x)),x];
p_hat2 = (X'*X)\X'*y;
p_hat3 = fminsearch(@(p) -sum(log(normpdf(y,linfun(x,p),std(y)))),[1,1]); % MLE loss function

plot(x,y,'ro'), hold on, plot(x,linfun(x,p_hat),'b-');
h = legend('Data','Fit'); set(h,'Location','NorthWest');

% Linear regression analysis
df1 = length(p_hat)-1; df2 = length(x\length(p_hat);
SSr = sum( (linfun(x,p_hat)-mean(y)).^2 );
SSe = sum( (linfun(x,p_hat)-y).^2 );
MSr = SSr / df1;
MSe = SSe / df2;
F = MSr / MSe;
p = 1 - fcdf(F,df1,df2);
R2 = SSr / ( SSr+SSe );
fprintf('\nF(%d,%d) = %.2f, p = %.3f, R^2 = %.2f\n',df1,df2,F,p,R2);

% All-in-one linear regression analysis using the SaML toolbox function, fitglm()
m = fitglm(x,y);
fprintf('\nF(%d,%d) = %.2f, p = %.3f, R^2 = %.2f\n',...
    m.NumCoefficients-1, m.DFE, table2array(m.Coefficients(2,3))^2,...
    table2array(m.Coefficients(2,4)), m.Rsquared.Ordinary);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 23.  Compare the goodness-of-fit of a kernel (non-parametric) regression
% and a linear (parametric) regression model fit to data with an obvious
% non-linearity. First, generate the following data:
%
%   rng(1);
%   n = 500;
%   x = sort(rand(n,1)*10+5');
%   dgp = @(x) 20+x*3.*(1+exp(-(x-10).^2));
%   y = dgp(x) + randn(size(x)).*10;
%
% Here, we have 'n' observations of 'x' and 'y', where some hidden process 
% generates 'y' from 'x'. With the power of contrived examples, we know
% that 'dgp' is the true data generating process. We also assume that 'x'
% is observed without error, while 'y' is observed with i.i.d. additive
% measurement error.
%
% First, fit a Gaussian kernel regression model to the data. Use a kernel
% bandwidth estimated using Silverman's rule-of-thumb. Compute the
% log-likelihood of the fitted model.
%
% Second, fit an parametric linear regression model
%   y ~ intercept + x * slope
% to the same data using maximum likelihood estimation. Compute the
% log-likelihood of the fitted model.
%
% Third, compare the model fits with a ratio-test and report the results.
% Also, generate a plot with (1) a raw data scatter plot, (2) the true 
% data generating process, (3) the kernel regression fit, and (4) the
% linear model fit.

% Generate data
rng(1);
n = 500;
x = sort(rand(n,1)*10+5');
dgp = @(x) 20+x*3.*(1+exp(-(x-10).^2));
y = dgp(x) + randn(size(x)).*10;

% Kernel regression
sigma = .9*min([std(x),iqr(x)/1.34])*n^(-1/5);
[d,i] = sort([x',linspace(x(1),x(end),1000)]);
i = i<=n;
[d2,x2] = meshgrid(d,x);
f = exp( -(x2-d2).^2 ./ (2*sigma^2) ); % Kernels
fy = sum(f.*repmat(y,1,size(d2,2))) ./ sum(f);
ll2 = sum(log(normpdf(fy(i)',y,std(y))));

% Linear regression
lm = @(x,p) p(1)+p(2)*x;
[phat,ll1] = fminsearch(@(p)-sum(log(normpdf(lm(x,p),y,std(y)))),[1,1]);
ll1=-ll1;

% Model comparison
chi2 = 2*abs(ll1-ll2);
df = numel(phat)-1;
p = 1-chi2cdf(chi2,df);

% Plot
set(groot,'DefaultAxesTickLabelInterpreter','LaTeX');
figure; hold on; h = 1:4;
h(1) = scatter(x,y,'ko','MarkerFaceColor','k','MarkerFaceAlpha',.25,'MarkerEdgeColor','none');
h(2) = plot(d,dgp(d),'k','LineWidth',2);
h(3) = plot(x,lm(x,phat),'r','LineWidth',2);
h(4) = plot(d,fy,'b','LineWidth',2);
legend(h,{'Data','True Process','Linear Regression','Kernel Regression'},...
    'Location','northwest','Interpreter','latex');
title(['Ratio-test: $\chi^2(',num2str(df),',N = ',num2str(n),')=',...
    num2str(chi2),',p=',strrep(num2str(p,3),'0.','.'),'$'],...
    'Interpreter','latex');
xlabel('$x$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  24. Use leave-one-out cross-valdiation (CV) to estimate the optimal
% bandwidth for a kernel regression. Imagine we measured some signal 'y'
% that varies as an unknown and noisy function of some other variable 'x'.
% There is no parametric model we know of to model their relationship, so
% instead we will utilize (parameter-free) kernel regression (KR).
% However, strictly speaking, kernels do have a 'bandwidth' parameter: the
% smoothing interval. When the bandwidth is too narrow, the KR will begin
% to fit even the smallest flucations in the signal (the noise), which is
% bad because this fails to represent the signal. This is called
% 'over-fitting'. Conversely, when the bandwith is too wide, the KR will
% begin to converge on the grand mean of the signal, which is similarly
% bad because this to fails to represent the signal also. This is called
% 'under-fitting'. Somewhere in between these extremes is an optimal
% bandwidth, which very well represents the signal. However, it is not
% always clear what this optimal bandwidth is, but we can rely on
% computationally intensive methods to estimate it: cross-validation. The
% principle behind CV is that we fit the model to a subset of the data
% (i.e., a cross-fold), and predict the remaining data. Then, we measure
% the amount of error in the predictions (i.e., how well did our model
% generalize?). The most extreme case of cross-validation is leave-one-out
% CV, in which each cross fold contains all but a single datum. So, for
% 'n' data, we comptue the error across 'n' cross-folds. To combine CV
% with bandwidth estimation, we can repeat the LOOCV process across a
% range of potential bandwidths. The bandwidth that minimizes the total 
% error across cross-folds is definitionally optimal. We can ease the
% computational runtime of these operations by combining the problem 
% space into a set of large, multi-dimensional matrices. (MATLAB is orders
% of magnitude faster computing matrix operations than computing
% consecutive scalar operations!) First, set up the simulation as below:
%
% rng(18); % For reproducability
% n = 2000; % Number of observations
% dgp = @(x) cos(x*2*pi).*exp( -x.^2/2 ); % True data generating process
% x = randn(n,1)*2; % Observations of x-variable
% y = dgp(x)+randn(size(x)).*exp(-x.^2/4); % Observations of y-variable
%
% Here, 'n' is the number of observations, 'dgp' is the True (but unknown)
% data generating process that maps the variable 'x' onto the noisy signal
% 'y'. In reality, it's unknown, but for a simulation, we can define it to
% check how well our methodology works.
%
% Find the optimal bandwidth 'bw' for the KR regression model y ~ K(X-x,bw),
% where 
%   K(X-x,bw) = sum(y * exp(-(X-x).^2/(2*bw^2)) / sum( exp(-(X-x).^2/(2*bw^2)),
% which is simply a Gaussian kernel regression. Use the following range of
% potential bandwith values to search for the optimal bandwidth:
%
%   bw = linspace(.001^(1/10),.5^(1/10),25).^10;
%
% Perform a leave-one-out cross-validation for each bandwidth. For each
% bandwidth, compute the root-mean squared error (RMSE) across the 'n'
% cross-folds. Find the value of 'bw' that minimizes the RMSE. Construct a
% plot of RMSE as a function of 'bw'. Next, fit the KR model to the data
% separately using 3 values of 'bw': [bw(1), bw(s), bw(end)], where 's' is
% the index of 'bw' with minimum RMSE. This plot will illustrate
% over-fitting, optimal fitting, and under-fitting (respectively). Plot
% each of these models against the 'dgp', the true data generating process
% to see how accurately each on captures the underlying relationship
% between 'x' and 'y'.
%
% HINT: the purpose of this exercise is encourage you to think in matrices.
% This problem is solvable with a single 'for loop'. (In fact, with
% infinite RAM, it's theoretically possible to solve it with zero loops,
% but that's not going to be possible here.) First, create an 'X' domain
% for the model, with 'm' elements. Next, meshgrid() this with the 'x' data
% to create the (X-x) matrix of size n by m. Repeat the 'y' data into 2
% dimensions also (i.e., a column of the 'y' data for each point on the 'X'
% domain, which is n by m). Now, repeat both of these 2D matrices into 3
% dimensions, where each 2D matrix is repeated for each value of 'bw'. As
% 'bw' has 25 elements, these 3d matrices are n by m by 25. Finally, create
% a 3D matrix of 'bw' called, e.g., bw3. 'bw3' will be of equal size to the
% 3D data matrices (n by m by 25), and where 
%   all(bw3(:,:,1) == bw(1)), all(bw3(:,:,2) == bw(2)), ..., etc.
% With these 3 matrices, it's now possible to fit the model across the
% domain 'X', for every pair of 'x' and 'y' data and for every value of
% 'bw' before even attempting the cross-validation. All you need to do for
% the cross-validation then is to use a for loop to iterate over the
% cross-folds.

% Set up the simulation
rng(18); % For reproducability
n = 2000; % Number of observations
dgp = @(x) cos(x*2*pi).*exp( -x.^2/2 ); % True data generating process
x = randn(n,1)*2; % Observations of x-variable
y = dgp(x)+randn(size(x)).*exp(-x.^2/4); % Observations of y-variable

bw = expspace(.001,.5,10,25); % Potential bandwidth values
ss = nan(n,numel(bw)); % The sum-of-squared error for each cross-fold X each bandwidth value

% Set up the model
w = .01; % x domain precision
X = min(x)-mod(min(x),w) : w : max(x)-mod(max(x),w)+w; % x domain
y2 = repmat(y,1,numel(X)); % y data in 2 dimensions
[X2,x2] = meshgrid(X,x); % x data and domain in 2 dimensions
x2 = -(X2-x2).^2; % Kernel numerators in 2 dimensions
x3 = exp( repmat( x2 ,1,1,numel(bw)) ./...
    shiftdim(repmat(2*bw.^2',1,numel(x),numel(X)),1)... Bandwidth values in 3 dimensions (bw3 in description)
    ); % Kernels in 3 dimensions
y3 = repmat( y2 ,1,1,numel(bw)); % y data in 3 dimensions
i = ~eye(numel(x)); % Exhaustive set of indices for each cross-fold
% [X3,x3,s3] = meshgrid(X,x,2*bw.^2); % x data and domain in 2 dimensions
% x3 = exp( -(X3-x3).^2 ./ s3 );  % Kernels in 3 dimensions

% Run the cross validation and compute the error in each cross fold
for j = 1:numel(x) % For each datum
    h = X-w/2 <= x(j) & x(j) <= X+w/2; % Get the domain bin for this datum (we can save time by limiting the scope of the regression)
    f = squeeze(sum( x3(i(:,j),h,:) )); % Sum of kernels across the x data
    yhat = squeeze(sum(   x3(i(:,j),h,:) .* y3(i(:,j),h,:)   )) ./ f; % Fitted model
    yhat(f==0) = 0; % Protect against divide by zero erors (NaN)
    ss(j,:) = ( y(j) - yhat ).^2; % Sum-of-squared errors between model prediction and observed y datum
end
rmse = sqrt(mean(ss)); % Compute the root-mean square error (RMSE)
s = find(min(rmse)==rmse); % Get the (empirically) optimal bandwidth

% Set up plots
figure;
set(groot,'DefaultAxesTickLabelInterpreter','LaTeX');
set(gcf,'units','normalized','outerposition',[.25,.1,.5,.8]);
pt = [1,s,numel(bw)]; % Plot a variety of bandwidth values --> [over-fitting, optimal fitting, under-fitting]
cols = {'g','r','b'}; % Plot each in a different color for visual effect

% Plot the cross validation results
subplot(2,3,2); semilogx(nan,nan); hold on;
plot(bw,rmse,'ko-','linewidth',2);
for i = 1:numel(pt)
    plot(bw(pt(i)),rmse(pt(i)),[cols{i},'o'],'linewidth',2);
end
plot(bw(s),  rmse(s)+range(ylim)*.1,'kv','markersize',10);
xlabel('Kernel Bandwidth','Interpreter','latex');
ylabel('RMSE','Interpreter','latex');

% Plot the fitted models with various bandwidths --> [over-fitting, optimal fitting, under-fitting]
model = @(bw)  sum(y2.*exp(x2./(2*bw^2)))./sum(exp(x2./(2*bw^2))); % The kernel regression model
for i = 1:numel(pt)
    subplot(2,3,3+i); hold on; h = 1:2;
    scatter(x,y,'MarkerEdgeColor','none','MarkerFaceColor','k','MarkerFaceAlpha',100/n); hold on;
    h(1) = plot(X,model(bw(pt(i))),cols{i},'linewidth',2);
    h(2) = plot(X,dgp(X),'k:','LineWidth',2);
    title(strrep(sprintf('Kernel Bandwidth $= %.3f$',bw(pt(i))),'0.','.'),'Interpreter','latex');
    xlabel('$x$','Interpreter','latex');
    ylabel('$y$','Interpreter','latex');
    xlim([-4,4]); ylim([-3,3]);
    legend(h,{'Fitted Model',sprintf('True Process')});
end


%% Neuroscience/experimental psychology analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 25.  Simulate the results and analysis from a simple 2-AFC experiment.
% Imagine an experiment in which subjects are shown either stimulus A or B
% and on every trial must discriminate which of the two stimuli is being
% shown. Each stimulus appears on 100 trials in random order. The stimuli
% are embedded in a lot of noise and thus the discrimination is rather
% difficult. From this hypothetical experiment, we get the following data
% in the below confusion matrix:
%
%               Choice
%                A | B
%             -----------
%           A | 82 | 18 |
%  Stimulus --|----|----|
%           B | 24 | 76 |
%             -----------
%
% Perform a conventional 2-AFC analysis on these data: (1) compute d-prime,
% (2) compute a receiver-operating characteristic (ROC) curve, (3) compute
% the area under the ROC curve, and (4) plot the ROC curve.
cm = [82,18;24,76];
hit = sum(cm(logical(eye(size(cm,1)))))/sum(cm(:));
fa = 1-hit;
dprime = (norminv(hit) - norminv(fa)) / sqrt(2);
% ROC
d = -3:.01:dprime+3; % decision variable domain
x = normcdf(d,dprime); % integral of HIT distribution for all values of decision variable 
y = normcdf(d); % integral of FA distribution for all values of decision variable
auc = trapz(x,y);
% Plot
figure; hold on; set(groot,'DefaultAxesTickLabelInterpreter','LaTeX'); % Use latex tick labels
plot(x,y,'k'); % false alarm rate as a function of hit rate
plot([0,1],[0,1],'k--');
fill([x,1,0],[y,0,0],'k','LineStyle','none','FaceAlpha',.1);
title(sprintf('Area under the curve = %s',strrep(num2str(auc,'%.3f'),'0.','.')),...
    'Interpreter','latex'); % area under the curve
xlabel('$P$(Hit)','Interpreter','latex');
ylabel('$P$(FA)','Interpreter','latex');
daspect([1,1,1]); set(gca,'XTick',[0,.5,1],'YTick',[0,.5,1]); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 26.  Compute the temporal point of subjective equality (PSE) for a cued
% stimulus. Imagine the following temporal order judgement (TOJ) task. On
% every trial, subjects maintain central fixation and 2 stimuli appear: one
% to the left and one to right of fixation. There is a delay between the
% exact onset of the left and right stimuli. Sometimes the left stimulus
% appears first, while other times the right stimulus appears first. The
% time between onsets is referred to as stimulus onset asynchrony (SOA).
% The participant's task is to discriminate whether the right or left
% stimulus onset first. On a subset of trials, we cue (flash) the location
% where the left stimulus appears 100 ms ahead of either stimulus onset. We
% are analyzing that specific subset of trials. The cue should speed
% processing of the left stimulus, so participants should have a biased
% perception of when that left stimulus appeared (i.e., they should
% perceive it as having onset earlier than it actually did). We want to
% measure how much faster they perceived the cued stimulus.
%
% Generate the following data from a hypothetical TOJ task:
%
%   rng(18);
%   n = 20;
%   t = -96:16:96;
%   r = round(normcdf(t,20,5)*n + randn(1,numel(t)).*exp(-(t-10).^2/2e3)*4);
%   r(r<0)=-r(r<0); r(r>n)=2*n-r(r>n);
%
% Here, 'n' is the number of repeated trials at each stimulus level. 't' is
% the SOA values. And 'r' is the number of trials on which the participant
% indicated that the right stimulus appeared first.
%
% Fit the normal cumulative distribution function (normcdf) to the
% proportion of rightward responses as a function of SOA. The fitted 'mu'
% parameter gives the PSE and indicates the magnitude of speeded processing
% elicited by the cue. Perform a ratio-test comparing this fit to the mean
% proportion of rightward responses as a function of SOA as your null
% hypothesis. This serves as a measure of goodness-of-fit. Plot all the
% results.
% 
% HINTs: (1) to compute the ratio test, you will need to fit the normal CDF
% using maximum-likelihood estimation. (2) The probability of 'r' choices
% on 'n' trials is binomially distributed.

% Generate data
rng(18);
n = 20;
t = -96:16:96;
r = round(normcdf(t,20,5)*n + randn(1,numel(t)).*exp(-(t-10).^2/2e3)*4);
r(r<0)=-r(r<0); r(r>n)=2*n-r(r>n);

% Fit sigmoid, compute goodness-of-fit test
[phat,ll1] = fminsearch(@(p)-sum(log(binopdf(r,n,normcdf(t,p(1),p(2))))),[0,10]);
ll1=-ll1;
ll0 = sum(log(binopdf(r,n,mean(r/n))));
chi2 = 2*abs(ll1-ll0);
df = numel(phat)-1;
p = 1-chi2cdf(chi2,df);

% Plot/report results
figure; hold on; set(groot,'DefaultAxesTickLabelInterpreter','LaTeX');
scatter(t,r/n,'ko','MarkerFaceColor','k','MarkerEdgeColor','none','MarkerFaceAlpha',.4);
fx = linspace(t(1),t(end),1000);
plot(fx,normcdf(fx,phat(1),phat(2)),'k','LineWidth',2);
plot([phat(1),phat(1),t(1)],[0,.5,.5],'k');
title(['Goodness-of-fit: $\chi^2(',num2str(df),',N = ',num2str(numel(t)),')=',...
    num2str(chi2),',p=',strrep(num2str(p,3),'0.','.'),'$',newline,...
    'PSE $=',num2str(phat(1)),'$'],'Interpreter','latex');
xlabel('Stimulus Onset Asynchrony (ms)','Interpreter','LaTeX');
ylabel('Proportion of Responses','Interpreter','LaTeX');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 27.  Generate hypothetical spike trains observed across 50 trials
% emulating a scenario in which a visual neuron responds to a spot of light
% in its receptive field, as below:
%
%   rng(1);
%   nTrials = 50;
%   t = -50:250;
%   y = rand(nTrials,numel(t))<exp( -(t-70).^2/3200 ) ./ (1+exp(-.4*(t-70)))*.25+.01;
%
% Here, 'nTrials' is the number of trials. 't' is the time in milliseconds
% before the onset of the visual stimulus, ranging from -50 milliseconds
% prior to onset to 250 milliseconds after onset. 'y' are the spike trains.
% 'y' has 50 rows, where each row is the spike train on the i_th trial. 'y'
% has numel(t) columns, where each column corresponds to a particular time
% after the onset of the stimulus. For example, y(:,151) contains the data
% 100 ms after the onset time of the stimulus as t(151) == 100. Each cell
% in the matrix 'y' contains either a 1 or a 0 indicating whether or not a
% spike was observed on every millisecond of every trial.
%
% To analyze this data, first, generate a spike density function with a
% convolution kernel of 5 milliseconds (a conventional choice in
% neurophysiology). HINT: Use the kernel density estimation technique to 
% generate a count density, then convert the count density from
% milliseconds into seconds.
%
% Second, compute the average firing rate of the neuron in the baseline
% period (-50 through 0) milliseconds before the onset of the stimulus.
% Repeat this for every trial.
%
% Third, compare the spike density function to the baseline activity
% millisecond-by-millisecond using paired-samples t-tests for each time
% bin. A signficant t-test indicates that the cell is firing above
% baseline the rate in the respective time bin and is thus responding to
% the visual stimulus.
%
% Forth, isolate the sequence of contiguous time bins that all contain
% significant visual activity. The upper and lower bounds of this epoch is
% referred to as a visual onset burst. Ensure that the onset burst is at
% least 10 ms in duration to be sure you haven't isolated noise in the
% signal.
%
% Fifth, plot everything. Plot a classic raster plot of the raw spike
% trains. Superimpose over the rasters the spike density function with
% shading to indicate the standard error of the mean. Finally, plot a black
% bar along the x-axis to indicate the range of the visual onset burst.

rng(1);
nTrials = 50;
t = -50:250;
y = rand(nTrials,numel(t))<exp( -(t-70).^2/3200 ) ./ (1+exp(-.4*(t-70)))*.25+.01;

% Analysis
% Generate SDF
f = nan(nTrials,numel(t));
for i = 1:nTrials
    [d,x] = meshgrid(t,t(y(i,:)));
    f(i,:) = sum(normpdf(x,d,5))*1000;
end
m = mean(f);
e = std(f)./sqrt(nTrials);
% Compute baseline activation
b = -50<=t&t<=0;
b = sum(y(:,b),2)*1000/sum(b);
% Analyze sliding t-test
p = f-b;
p = tcdf( -mean(p)./sqrt(var(p)/nTrials) ,nTrials-1) < .05;
% Isolate visual onset burst
s = nan(1,2);
for i = 1:numel(p)
    if p(i) && isnan(s(1))
        s(1) = t(i);
    elseif ~p(i) && ~isnan(s(1)) && t(i-1) - s(1) > 10
        s(2) = t(i-1);
        break;
    elseif i==numel(p)
        s(2) = t(i);
    end
end

% Plot
set(groot,'DefaultAxesTickLabelInterpreter','LaTeX');
figure; hold on; 
yl = [0,275];
% Rasters
for i = 1:nTrials
    for j = 1:numel(t)
        if y(i,j)
            rectangle('Position',[t(j),yl(2)*i/nTrials,1,yl(2)/nTrials],'FaceColor',[.4,.4,.4],'LineStyle','none');
        end
    end
end
% Spike density function
plot(t,mean(f),'k','LineWidth',3);
fill([t,fliplr(t)],[m+e,fliplr(m-e)],'k','FaceAlpha',.4,'LineStyle','none');
% Visual burst
rectangle('Position',[s(1),0,range(s),range(yl)*.01],'FaceColor','k','LineStyle','none');
% Formating
set(gca,'FontSize',12);
ylim(yl);
xlabel('Time after Stimulus (ms)','Interpreter','LaTeX');
ylabel('Spike Rate (s$^{-1})$','Interpreter','LaTeX');
