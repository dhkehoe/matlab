% Overview of many MATLAB features with an emphasis on visual neuroscience.

%% Creating matrices/vectors

% 1a.  Make x equal to a vector from 1 to 10.


% 1b.  Make x equal to a vector from -2pi to 2pi in 1000 steps.


% 1c.  Make x equal to a column matrix that consists of the numbers 20 to 30.


% 1d.  Make x equal to a matrix that has the numbers 100 to 200 in the first
% row and 300 to 400 in the second row.


%% Indexing

% 2.  In the following questions, use a matrix m that is a 20 x 5 matrix of
% normally distributed random numbers.  Resample a new matrix m for each
% question, e.g., don't let any changes to the matrix m in part (a) affect
% the matrix m that you use in part (b).


% 2a.  Make x equal to the first row of m.


% 2b.  Make x equal to all the elements of m that are greater than zero.


% 2c.  Make x equal to all the elements of m that are less than -1 or
% greater than 1.


% 2d.  Make x a row vector with elements that are the maximum of each row
% of m.


% 2e.  Make x equal to one if all elements of m are greater than zero, and
% zero otherwise.


% 2f.  Set any elements of m in the third column that are less than zero to
% NaN.


% 2g.  Set any rows of m that have a value less than -1.5 to NaN.


% 2h.  Set x to the number of elements in m that are greater than 2.


% 2i.  Delete the fourth row of m.


% 2j.  Suppose you didn't know the size of matrix m.  Set a equal to the
% number of rows in m, and b equal to the number of columns.


% 2k.  Suppose you didn't know the size of matrix m.  Set c equal to the
% number of elements in m.


% 2l.  Set the fourth column of m to zero in rows where the third column is
% less than zero.


% 2m.  Set f equal to the linear indices of the elements of m that are less
% than zero.


% 2n.  Use find() to set the elements of m that are less than zero to NaN.


% 2o.  Set x to the rows of m that are less than zero in the third column.


%% Matrix operations
%  3. Create the follow vectors 'x' and 'y' as follows:
%   x = randn(20,1)+2;
%   y = randn(20,1);

%  3a. Set 'z' equal to the sum of squared 'x' scores using matrix
%  multiplication and without using sum() or the ^ operator.


%  3b. Set 'z' equal to the sum of every 'x' score multiplied by every 'y'
% score without using meshgrid().


%  3c.  Set 'z' equal to the covariance matrix of 'x' and 'y' using matrix
%  multiplication of 'x' and 'y' without using cov().


%  3d. Using only matrix operations, solve for x, y, and z in the following
% system of linear equations, setting 'a' equal to the vector [x; y; z]
% 2x + 3y +  4z  =  6
% 4x + 9y + 12z  = 12
%  x + 3y +  5z  = 15


%% Printing text and data

% 4.  Set a = 3.14 and b = 'abc'.  Use fprintf() to print the following
% message:  The value of a is 3.1400 and the value of b is 'abc'.


% 5.  Write a for loop that prints all the prime numbers between 1 and 100.


% 6.  Use fprintf() to write the prime numbers between 1 and 100 to a text
% file called prime.txt


% 7.  Write a loop that prints the first prime number greater than 100.


%% Functions

% 8.  Write a function that takes two input arguments.  The function
% returns 1 if the second argument is greater, -1 if the first argument
% is greater, and 0 if the two arguments are equal.


% 9. Write an inline function called lbs2kg() that converts imperial pounds
%  to metric kgs


% 10. Write a recursive function to compute a factorial


% 11.  Use fminsearch to find the values of x and y that minimize
% the function (x-3)^2 + (y-2)^2


% 12.  Use fminsearch to find the number that has the minimum sum of
% squared distances to the numbers 1, 5, 10, and 20.


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


%%  Advanced matrix manipulations

% 14.  Make 'im' equal to a 3-dimensional matrix with the dimensions of
% (200,200,3) with every index equal to zero. Display im with the imagesc()
% function. This is a blank (black) image. Now, modify this image so that
% the top one third (1/3) is red, the middle one third is green, and the
% bottom one third is blue


% 15.  Use coordinate matrices to make two 100 x 100 images of a circle
% with a radius of 40 pixels.
% First image: black background and white circle
% Second image: blue background and magenta circle


% 16. Create a Gabor patch that's 800 x 800 pixels, with an orientation of 
% 45 degrees, phase of pi/2, a frequency of 30 pixels, standard deviation
% of 50 pixels, an aspect ratio of 1/2, a contrast of 25%, and a background
% luminance of 50%. Display stimulus with imshow(). HINT: to render the
% stimulus properly, rescale to 8-bit color depth, take the floor, and
% convert to uint8 data type.


%% Graphics/handles

% 17.  Set x equal to 20 samples from -pi to pi.  Set y equal to the tangent
% of x.  Plot y versus x with a solid green line and no data point markers.
% Label the axes 'angle' and 'tangent'.


% 18.  Use plot to plot a red sine wave and a blue cosine wave on the
% interval [0,2*pi], and use a handle for the axis object to set the width
% of the lines to 5 pixels, add a figure legend, add a title, and label the
% x and y axes.


% 19.  Use fplot to plot a sine wave on the interval [0,2*pi], and use
% 'saveas' to save the figure to an .eps file called sine.eps.


% 20.  Repeat the plot from the previous analysis, but now save the figure
% to a .pdf file called sine.pdf, using 300 dots-per-inch resolution, with
% the correct aspect ratio (i.e. eliminating white space below/above the
% figure), using the 'print' function.


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