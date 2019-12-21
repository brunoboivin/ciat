% Function that returns the rate of decay of a given function.
%========================================================================

function riseTime = getRiseTime(C)
% C is the input curve (e.g. deltaGR)

[ymax_r, xmax_r] = size(C);
timepoints = dlmread('timepoints.txt');
timepoints = timepoints(1:ymax_r);

startTime = 1.98167; % timepoint at which curve starts to rise
startIndex = find(timepoints == startTime);

smoothed_C = smooth(C,10);

[peakValue,peakIndex] = max( smoothed_C(startIndex:500) );
peakIndex = peakIndex + startIndex - 1;

peakTime = timepoints(peakIndex); % timepoint at which curve reaches its peak
riseTime = peakTime - startTime;

end



 