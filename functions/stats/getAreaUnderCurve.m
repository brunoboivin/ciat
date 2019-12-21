% Function that computes and returns the area under the curve 
% using the trapezoidal method for a given function.
%========================================================================

function area = getAreaUnderCurve(C)

[ymax_r, xmax_r] = size(C);
timepoints = dlmread('timepoints.txt');
timepoints = timepoints(1:ymax_r);

area = trapz(timepoints,C);

end

