% Function that draws the RED and GREEN surfaces side by side in the same
% figure.
%========================================================================

function h = drawGRsurfaces(redAvg, greenAvg)

h = figure('Name', 'Red & Green Submatrices Average','Color','w');
movegui(h,'northwest');

hold on;

% Axes for RED
[ymax_r, xmax_r] = size(redAvg);
[ymax_g, xmax_g] = size(greenAvg);

% get data for the x axis
timepoints = dlmread('timepoints.txt');
timepoints = timepoints(1:ymax_r); % ymax_r should be equal to ymax_g

% 3D Surface (RED)
subplot(2,2,1);
surf(1:xmax_r,timepoints,redAvg);
shading interp;
title('Red (3D)');
xlabel('Pixel'); % pixels along line scan
ylabel('Time (s)');
zlabel('Pixel intensity');

% 3D Surface (GREEN)
subplot(2,2,2);
surf(1:xmax_g,timepoints,greenAvg);
shading interp;
title('Green (3D)');
xlabel('Pixel');
ylabel('Time (s)');
zlabel('Pixel intensity');


% 2D view of surface (RED)
subplot(2,2,3);
surf(1:xmax_r,timepoints,redAvg);
shading interp;
title('Red (2D)');
xlabel('Pixel');
ylabel('Time (s)');
zlabel('Pixel intensity');
view(2);

% 2D view of surface (GREEN)
subplot(2,2,4);
surf(1:xmax_g,timepoints,greenAvg);
shading interp;
title('Green (2D)');
xlabel('Pixel');
ylabel('Time (s)');
zlabel('Pixel intensity');
view(2);

hold off;

colormap hot;

end