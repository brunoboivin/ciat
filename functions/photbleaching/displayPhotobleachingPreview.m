% Function that displays a preview of the photobleaching
% correction with the specified parameters.
%========================================================================

function displayPhotobleachingPreview(collapsedR, nPointsFitting, nPointsCorrection)

figure;

% Initial data with curve fitting
ax1 = subplot(2,1,1);
x =(1:1:nPointsFitting)';
y = collapsedR(1:nPointsFitting);
f = fit(x,y,'exp2');
plot(f,x,y);
title('Initial data with EXP2 curve fitting');
xlabel('Time');
ylabel('Pixel intensity');

% exp component of f, where f(x) = ae^(bx) + ce^(dx)
if abs(f.d) <= abs(f.b)
    exp_component = (f.a)*exp((f.b)*x(:));
else
    exp_component = (f.c)*exp((f.d)*x(:));
end;

% Corrected datapoints with curve fitting
ax2 = subplot(2,1,2);
x2 =(1:1:nPointsFitting)';
y2 = collapsedR(1:nPointsFitting);
y2(1:nPointsCorrection) = y2(1:nPointsCorrection) - exp_component(1:nPointsCorrection);
f2 = fit(x2,y2,'exp2');
plot(f2,x2,y2);
title(sprintf( ['Data without exponential component with EXP2 curve fitting\n', 'Datapoints (fitting,correction) = (', num2str(nPointsFitting), ',', num2str(nPointsCorrection), ')'] ));
xlabel('Time');
ylabel('Pixel intensity');

linkaxes([ax1,ax2],'y');

end

