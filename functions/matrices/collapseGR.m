% Function that collapses the R and G matrices in time such that each
% pixel is represented by its average over all timepoints.
%========================================================================

function [collapsedR, collapsedG] = collapseGR(R, G)

sizeR = size(R);
nTimePoints = sizeR(1); % returns length of 1st dimension of R

if (nTimePoints < 264)
    display('Cannot collapse G and R matrices. Region of interest must include at least 264 timepoints.');
    return;
end;

% initialize variables
collapsedR = zeros(nTimePoints,1); % collapsed means avg of pixel intensities for each timepoint
collapsedG = zeros(nTimePoints,1);

% compute collapsed R and G
for k=1:nTimePoints
    collapsedR(k) = mean( R(k,:) ); % red
    collapsedG(k) = mean( G(k,:) ); % green
end;

end