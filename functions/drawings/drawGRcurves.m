% Function that draws the R, G, and delta G/R curves for the 
% selected region of interest.
%========================================================================

function drawGRcurves(collapsedR,collapsedG,deltaGR,roi_name)

h = figure('Name', 'Delta G/R','Color','w');
movegui(h,'northeast');

hold on;

% get data for the x axis
[ymax_r, xmax_r] = size(redAvg);
timepoints = dlmread('timepoints.txt');
timepoints = timepoints(1:ymax_r);

% RED (R)
subplot(3,1,1);
plot(timepoints,collapsedR, 'Color','red');
title(strcat('[',roi_name,']  Red (R)'));
xlabel('Time (s)');
ylabel('Pixel intensity');

% GREEN (G)
subplot(3,1,2);
plot(timepoints,collapsedG,'Color','green');
title(strcat('[',roi_name,']  Green (G)'));
xlabel('Time (s)');
ylabel('Pixel intensity');

% Delta G/R
subplot(3,1,3);
plot(timepoints,deltaGR,'Color','black');
title(strcat('[',roi_name,']  \Delta G/R'));
xlabel('Time (s)');
ylabel('\Delta G/R');

hold off;

end

