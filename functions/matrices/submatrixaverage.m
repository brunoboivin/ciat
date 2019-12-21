% Function that returns the element-wise average for both R and G for the
% set of specified files.
%========================================================================

function [redAvg, greenAvg] = submatrixaverage(files, points)

% Extract corner coordinates from specified rectangular selection
x1 = points(1,1); y1 = points(1,2);
x2 = points(2,1); y2 = points(2,2);

% Defining width,height of rectangular selection
% xlength = abs(x2-x1+1); % +1 to include both endpoints
% ylength = abs(y2-y1+1);

% Initializing variables
nFiles = length(files);
xlength = 1;
ylength = 1;
redSum = zeros(ylength,xlength);
greenSum = zeros(ylength,xlength);

for k = 1:nFiles
    % read full lsm file
    lsmFile = imread(files{k});
    
    % get image size
    [ylength_lsm,xlength_lsm,zlength_lsm] = size(lsmFile);
    
    if xlength == 1 && ylength == 1
        xlength = xlength_lsm;
        ylength = ylength_lsm;
        redSum = zeros(ylength,xlength);
        greenSum = zeros(ylength,xlength);
    end;
    
    % use largest common length of all lsm files
    if xlength_lsm < xlength
        xlength = xlength_lsm;
        redSum = redSum(:,x1:xlength);
        greenSum = greenSum(:,x1:xlength);
    end;
    if ylength_lsm < ylength
        ylength = ylength_lsm;
        redSum = redSum(y1:ylength,:);
        greenSum = greenSum(y1:ylength,:);
    end;
    
    % extract R and G from lsm matrix
    redSum = redSum + double(lsmFile(y1:ylength,x1:xlength,1)); % converting to double to keep sum and avg precise
    greenSum = greenSum + double(lsmFile(y1:ylength,x1:xlength,2));
end;

% Element-wise average for R and G
redAvg = redSum ./ nFiles;
greenAvg = greenSum ./ nFiles;

end