% Function that returns the peak value computed in various ways.
%========================================================================

function [peakValue_abs, peakValue_50ms] = getPeakValue(C)
% C is the input curve (e.g. deltaGR)
% peakValue_abs: using value of data at peak timepoint
% peakValue_50ms: using 50ms avg around the peak timepoint

[ymax_r, xmax_r] = size(C);
timepoints = dlmread('timepoints.txt');
timepoints = timepoints(1:ymax_r);

startTime = 1.98167; % timepoint at which curve starts to rise
startIndex = find(timepoints == startTime);

[peakValue_abs,peakIndex] = max( C(startIndex:500) );
peakIndex = peakIndex + startIndex - 1;

% Each timepoints is about 0.0067s, so 6 timepoints ~[40ms;50ms]
peakValue_50ms = mean( C(peakIndex-3:peakIndex+3) );

end