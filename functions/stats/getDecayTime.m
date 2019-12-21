% Function that returns the rate of decay of a given input function.
%========================================================================

function [exp1_decayTime, exp1_adjR, exp2_decayTime_fast, exp2_decayTime_slow, exp2_adjR, fitCurveEquation_exp1, fitCurveEquation_exp2] = getDecayTime(C)
% C is the input curve (e.g. deltaGR)

[ymax_r, xmax_r] = size(C);
timepoints = dlmread('timepoints.txt');
timepoints = timepoints(1:ymax_r);

% Step 1: Identify peak time and keep only timepoints from that point onwards
smoothed_C = smooth(C);
[peakValue, peakIndex] = max(smoothed_C(200:800));
peakTime = timepoints(peakIndex); % timepoint at which curve reaches its peak
expComp_C = C(peakIndex:length(C)); % keeping portion of G that starts with the exponential decay

% Step 2: Fit exp1/exp2 curves to the data
% X: timepoints
% Y: input curve C
[f1, gof1] = fit(timepoints(peakIndex:length(C)),expComp_C,'exp1');
[f2, gof2] = fit(timepoints(peakIndex:length(C)),expComp_C,'exp2');

% Compute decay times and adjusted R values (to measure goodness of fit)
% EXP1
exp1_decayTime = abs(1/f1.b);
exp1_adjR = gof1.adjrsquare;

% EXP2
if abs(1/f2.b) <= abs(1/f2.d)
    exp2_decayTime_fast = abs(1/f2.b);
    exp2_decayTime_slow = abs(1/f2.d);
else 
    exp2_decayTime_fast = abs(1/f2.d);
    exp2_decayTime_slow = abs(1/f2.b);
end;
exp2_adjR = gof2.adjrsquare;

% fitting curve equations
fitCurveEquation_exp1 = strcat('f(x)=',num2str(f1.a),'*exp(',num2str(f1.b),'*x)');
fitCurveEquation_exp2 = strcat('f(x)=',num2str(f2.a),'*exp(',num2str(f2.b),'*x)+',num2str(f2.c),'*exp(',num2str(f2.d),'*x)');

end



