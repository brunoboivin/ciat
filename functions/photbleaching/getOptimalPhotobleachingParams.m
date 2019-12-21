% Algorithm that attempts to suggest optimal parameters
% for correcting photobleaching in the provided matrix.
%========================================================================

function [nPointsFitting, nPointsCorrection] = getOptimalPhotobleachingParams(collapsedR)

% Step 1: Curve FITTING 
%   --> To identify an optimal number of datapoints for curve fitting

nPointsFitting = length(collapsedR); % default initial value, will get changed below
d = 99999.99; % simulates infinity; d in  f(x)=ae^(bx) + ce^(dx)

% stepSize: # of additional datapoints to include before fitting a curve on
% the data
stepSize = abs( ceil((length(collapsedR) - 612.667) / 13.733) );

if stepSize < 5, stepSize = 5; end; % min step size
if stepSize > 100, stepSize = 100; end; % max step size

% compute number of steps based on step size
nSteps = floor(length(collapsedR) / stepSize);
ds = 999*(ones(nSteps,1)); % 999 simulates infinity
useD = 1; % boolean variable to specify whether to use 'd'(1) or 'b'(0)

% Try fitting a curve on each possible set of datapoints given the
% specified step size, and select the one that yields the best fit
for k=1:nSteps
    x =(1:1:nPointsFitting)';
    y = collapsedR(1:nPointsFitting);
    f = fit(x,y,'exp2');
    
    % determine which of (a,b) or (c,d) is the constant component
    % and use b or d accordingly (use smallest one here)
    if k == 1
        if abs(f.d) <= abs(f.b)
            useD = 1;
        else
            useD = 0;
        end;
    end;
    if useD
        ds(k) = abs( f.d );
    else
        ds(k) = abs( f.d );
    end;
    
    nPointsFitting = nPointsFitting - stepSize;
end;

% Rebuild f with min value for d
% The min d will yield the best fit, i.e. one constant component and one
% exponential component.
[M,I] = min(ds);
nPointsFitting = length(collapsedR) - stepSize*I;
if nPointsFitting < 4, nPointsFitting = 4; end;
x =(1:1:nPointsFitting)';
y = collapsedR(1:nPointsFitting);
f = fit(x,y,'exp2');


% Step 2: Curve CORRECTION
%   --> To identify an optimal number of datapoints for curve correction
fitMinusMean = zeros(2,1); % 1 refers to current, 2 refers to previous
deltaFitMinusMean = zeros(length(collapsedR),1); % change in 'fitMinusMean' values
counter = 0;
threshold = 0.01; % min distance between datapoint and baseline
nPointsCorrection = length(collapsedR);

% Compute baseline from second half of the curve so that we can then
% measure the distance between each point in the first half to that
% baseline and plot an exponential decay curve on the data.
latterHalfStartIdx = int32(length(collapsedR)/2);
latterHalfAvg = mean( collapsedR(latterHalfStartIdx:length(collapsedR)) );

for k=1:length(collapsedR)
    fitMinusMean(1) = abs( f(k) - latterHalfAvg ); % mean of second half of data
    
    if k == 1
        deltaFitMinusMean(k) = 0;
    else
        deltaFitMinusMean(k) = abs( fitMinusMean(1) - fitMinusMean(2) );
        if deltaFitMinusMean(k) < threshold
            counter = counter + 1;
            if counter > 4
                nPointsCorrection = k;
                break;
            end;
        else
            counter = 0;
        end;
    end;
    
    fitMinusMean(2) = fitMinusMean(1);
end;


if nPointsCorrection < 4, nPointsCorrection = 4; end; % not needed, just here to match limits in UI (can theoretically go down to 1)

% code below prevents bugs in the photobleaching Gui; we cannot correct
% photobleaching if the exponential component we wish to remove has not been calculated
if nPointsFitting < nPointsCorrection
    nPointsFitting = length(collapsedR);
    nPointsCorrection = 4;
end;


