% Function that removes the exponent component from the input curve; 
% this is used for correcting photobleaching.
%========================================================================

function [collapsedR_no_exp,compensation,photobleachingFitParams,fitCurveEquation] = removePhotobleaching(collapsedR, nPointsFitting, nPointsCorrection)
% 'compensation' returned refers to the compensation (correction) applied
% on each point

% Ensure # of datapoints does not exceed size of collapsedR
if nPointsFitting > length(collapsedR)
    nPointsFitting = length(collapsedR);
end;
if nPointsCorrection > length(collapsedR)
    nPointsCorrection = length(collapsedR);
end;

% Get fit curve f(x)=a*e^(bx) + c*e^(dx)
x =(1:1:nPointsFitting)';
y = collapsedR(1:nPointsFitting);
[f,gof] = fit(x,y,'exp2');

% Extract and reconstruct exp component from f(x)
if abs(f.d) <= abs(f.b)
    exp_component = (f.a)*exp((f.b)*x(:));
else
    exp_component = (f.c)*exp((f.d)*x(:));
end;

% Subtract exp_component from y
y(1:nPointsCorrection) = y(1:nPointsCorrection) - exp_component(1:nPointsCorrection);

% Return data with exp component removed
collapsedR_no_exp = [y; collapsedR(nPointsFitting+1:length(collapsedR))];

compensation = zeros(length(collapsedR),1);
compensation(1:nPointsCorrection) = exp_component(1:nPointsCorrection);

fitCurveEquation = strcat('f(x)=',num2str(f.a),'*exp(',num2str(f.b),'*x)+',num2str(f.c),'*exp(',num2str(f.d),'*x)');
photobleachingFitParams = [nPointsFitting nPointsCorrection gof.adjrsquare;];

end