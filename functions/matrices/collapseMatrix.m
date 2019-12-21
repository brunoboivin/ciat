% Function that collapses a matrix to a single row.
% Each pixel is represented by its average over all timepoints.
%========================================================================

function collapsedMatrix = collapseMatrix(M)

sizeM = size(M);
nTimePoints = sizeM(1); % returns length of 1st dimension of M

% initialize variables
collapsedMatrix = zeros(nTimePoints,1); % collapsed means avg of pixel intensities for each timepoint

% compute collapsed R and G
for k=1:nTimePoints
    collapsedMatrix(k) = mean( M(k,:) );
end;

end