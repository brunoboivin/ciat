% Function that renders an lsm file as R and G images side by side in the
% same figure.
%========================================================================

function renderlsm(R,G,R_colormap,G_colormap)

timepoints = dlmread('timepoints.txt'); % time axis
[ymax_r, xmax_r] = size(R);
timepoints = timepoints(1:ymax_r);
pixels = 1:xmax_r; % pixel axis

figure('Name', 'Average lsm previews','Color','w');

% RED (R)
redAxes = subplot(1,2,1);
image(pixels,timepoints,R,'CDataMapping','scaled')
colorbar
title('Red (R)');
xlabel('Pixel');
ylabel('Time (s)');
colormap(redAxes,R_colormap);
set(gca,'Ydir','Normal')

hold on;

% GREEN (G)
greenAxes = subplot(1,2,2);
image(pixels,timepoints,G,'CDataMapping','scaled')
colorbar
title('Green (G)');
xlabel('Pixel');
ylabel('Time (s)');
colormap(greenAxes,G_colormap);
set(gca,'Ydir','Normal');

hold off;

end

