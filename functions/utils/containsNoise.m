% Function that determines whether there is noisy above a specified
% threshold in a given matrix.
%========================================================================

function isNoisy = containsNoise(G,noise_threshold)
isNoisy = 0;

if length(G) < 200
    display('Matrix must contain at least 200 datapoints.');
    return;
end;

% collapse matrix
collapsedG = collapseMatrix(G);

% smooths data using a moving average with window size of 5
smooth_collapsedG = smooth(collapsedG);

% left portion of curve (first 200 points)
isNoisy = sectionIsNoisy(1,200,G,smooth_collapsedG,noise_threshold);
if isNoisy, return; end;

if length(G) < 400, return; end;

% right portion of curve (all points beyond 400 inclusively)
isNoisy = sectionIsNoisy(400,length(G),G,smooth_collapsedG,noise_threshold);
if isNoisy, return; end;

end


% Helper method used to detect noise in subsection of input data
function sectionContainsNoise = sectionIsNoisy(startIndex,endIndex,data,smoothed_data,threshold)
sectionContainsNoise = 0;

% define threshold & initialize counter
noise_nPoints = 3; % num of points above threshold for data to be considered noisy
counter = 0;

% fit curve to specified portion of input data
x =(1:1:length(data))';
y = smoothed_data(1:length(data));
f = fit(x,y,'poly1');

% look for deviations from curve, 3 in a row => considered noise
for k=startIndex:endIndex
    dist = y(k) - f(k);
    if dist >= 0
        if dist/f(k) > threshold            
            counter = counter + 1;
            if counter >= noise_nPoints
                sectionContainsNoise = 1;
                return;
            end;
        else
            counter = 0;
        end;
    end;
end;

end
