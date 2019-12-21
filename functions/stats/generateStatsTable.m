% Function that generates a statistics table into a new figure.
%========================================================================

function f = generateStatsTable( statsMap )

f = figure('Name', 'Statistics', 'Color', 'w');

keySet = keys(statsMap);
valueSet = values(statsMap,keySet);

d = valueSet{1};
for k=2:length(valueSet)
    d = [d; valueSet{k}];
end;

% Create the column and row names in cell arrays 
cnames = {'Area under curve','Rise time (s)','Peak (abs)','Peak (50ms avg)', ...
    'Decay time (exp1)','Adjusted R (exp1)', ... 
    'Decay time (exp2,fast)','Decay time (exp2,slow)','Adjusted R (exp2)' };

% set figure size
cellWidth = 100;
f.Position(3) = (length(cnames)+1)*cellWidth;
f.Position(4) = 80 + 20*length(keySet);

% create uitable
t = uitable(f,'Data',d,...
            'ColumnName',cnames,... 
            'RowName',keySet,...
            'ColumnWidth',{cellWidth});
        
% set width and height
t.Position(3) = (length(cnames)+1)*cellWidth - 30;
t.Position(4) = 40 + 20*length(keySet);

end

