function varargout = mainGui(varargin)
% MAINGUI MATLAB code for mainGui.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainGui

% Last Modified by GUIDE v2.5 10-Dec-2017 23:07:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainGui_OpeningFcn, ...
                   'gui_OutputFcn',  @mainGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mainGui is made visible.
function mainGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainGui (see VARARGIN)

% Choose default command line output for mainGui
handles.output = hObject;

handles.max_columns = 1986; % max # of columns to store in database

% Update handles structure
guidata(hObject, handles);

% Display SickKids logo in logoAxes
axes(handles.logoAxes);
imshow('sickkids-logo.png');

axes(handles.axesAppLogo);
imshow('calcium-elem-banner.png');

axes(handles.neuronRedBannerAxes);
imshow('neuron-red-banner.png');

axes(handles.neuronGreenBannerAxes);
imshow('neuron-green-banner.png');

% clear memory
clearMemory();

% set path to include SQLite driver
javaaddpath('lib/sqlite-jdbc-3.8.11.2.jar');
% javaaddpath('C:/Users/bruno boivin/Documents/MATLAB/SickKidsProject/lib/sqlite-jdbc-3.8.11.2.jar');


% UIWAIT makes mainGui wait for user response (see UIRESUME)
% uiwait(handles.gui_main);


% --- Outputs from this function are returned to the command line.
function varargout = mainGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_addlsm.
function pushbutton_addlsm_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addlsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Step 1: Get filenames and corresponding paths
[filenames, path] = uigetfile({'*.lsm'},'Select file(s)', 'MultiSelect', 'on');

% Fix for no selection
if path == 0 % if no path returned => user cancelled and no files were selected
    return;
end;

% fix for 1 file selected
if ~iscell(filenames)
    filenames = {filenames}; % convert to cell array
end;

% Step 2: Create array of filenames (path+filename) and update GUI
files = cell(1,length(filenames));
for k = 1:length(filenames)
    files(k) = strcat(path,filenames(k));
end;

% Step 3: Update list of files and listbox as appropriate
if isfield(handles, 'files')
    handles.files = [handles.files files];
    previousListboxItems = get(handles.listbox_files, 'String');
    set(handles.listbox_files,'String',[transpose(previousListboxItems) filenames]);
else
    handles.files = files;
    set(handles.listbox_files,'String',filenames);
end;

handles.selectedFileIndex = 1; % default file index after non-empty selection
guidata(hObject, handles);

% Step 4: Enable/disable 'remove' button as appropriate
listboxItems = get(handles.listbox_files, 'String');
if isempty(listboxItems)
    set(handles.pushbutton_removelsm,'Enable','off');
else
    set(handles.pushbutton_removelsm,'Enable','on');
end;

% Step 5: Display preview of avg of lsm files (default behaviour)
[handles.redAvg, handles.greenAvg] = updateLsmAvgPreviews(handles);
guidata(hObject,handles);

% Step 6: Reset lsm params
resetParams(hObject,eventdata,handles);


% --- Executes on selection change in listbox_files.
function listbox_files_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_files


% --- Executes during object creation, after setting all properties.
function listbox_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% STEP 0: Ensure non-empty list of files and ROI defined
% Ensure list of files is specified and non-empty
if ~isfield(handles, 'files')
    warndlg('Please add lsm files for analysis before proceeding.','List of files error');
    return;
end;
if isempty(handles.files)
    warndlg('Please add lsm files for analysis before proceeding.','List of files error');
    return;
end;

% Ensure ROI is defined
if ~isfield(handles, 'roiMap')
    warndlg('No region of interest defined. Please set a region of interest before proceeding.','Region of interest error');
    return;
end;

% ensure moving average span is positive
smoothData = get(handles.checkbox_smooth,'Value');
if smoothData
    spanText = get(handles.edit_smooth_value,'String');
    span = round( str2num(spanText) );
    set(handles.edit_smooth_value,'String',num2str(span)); % round number to keep only integer part
    
    if isempty(span) || span < 1
        warndlg('The moving average span must be positive in order to smooth the data.','Invalid moving average span error');
        return;
    end;
else
    if isfield(handles,'smoothed')
        handles = rmfield(handles,'smoothed');
    end;
end;

% clear previous figure references
if isfield(handles,'surfFig')
    handles = rmfield(handles,'surfFig');
end;
if isfield(handles,'deltaGRFig')
    handles = rmfield(handles,'deltaGRFig');
end;
if isfield(handles,'statsFig')
    handles = rmfield(handles,'statsFig');
end;
guidata(hObject,handles);
    
% Start analysis

% determine # of steps to be used in progress bar
nSteps = 2;
if isfield(handles,'roiMap')
    nSteps = nSteps + length(handles.roiMap);
end;

% display progress bar
h = waitbar(0,'Please wait...'); % progress bar
waitbar(1/nSteps); % illusion of work-in-progress

% STEP 1: Remove images that contain noise above specified threshold
nFiles = length(handles.files); % to keep track of length of handles.files before removing the noisy imgs
[filesRemovedText,nFilesRemoved] = removeNoisyImg(hObject, eventdata, handles);
if ~isempty(filesRemovedText)
    % close progress bar and clear params (ROIs)
    if isvalid(h), close(h); end;
    resetParams(hObject,eventdata,handles);
    
    % fix to ensure handles.files gets updated and roiMap is cleared
    handles.files = getappdata(0,'files');
    if isfield(handles,'roiMap')
        handles = rmfield(handles,'roiMap');
    end;
    guidata(hObject, handles);
    
    message = sprintf( strcat('Noise above specified threshold detected. The following files were removed:',filesRemovedText) );
    warndlg(message,'Noise detected');
    return;
end;

% fix to ensure handles.files gets updated
handles.files = getappdata(0,'files');
guidata(hObject, handles);

% Ensure there are some files remaining before proceeding
if nFiles == nFilesRemoved
    if isvalid(h), close(h); end;
    return;
end;

% STEP 2: Draw GR surfaces (3D and 2D views)
if ~isfield(handles,'redAvg') || ~isfield(handles,'greenAvg')    
    points = [1 1; 1024 1986];
    [handles.redAvg, handles.greenAvg] = submatrixaverage(handles.files,points);
    guidata(hObject,handles);
end;

if get(handles.checkbox_GRsurfaces, 'Value')
    surfFig = drawGRsurfaces(handles.redAvg, handles.greenAvg);
    handles.surfFig = surfFig;
end;
waitbar(2/nSteps);

% ensure roiMap exists
if ~isfield(handles,'roiMap')
    if isvalid(h), close(h); end; % close loading dialog box
    return;
end;

% map used to store stats
statsMap = containers.Map('KeyType','char','ValueType','any');


% STEP 3: Draw GR curves for all ROIs (remove photobleaching when required)
% Define new figure for GR curves
if get(handles.checkbox_GRcurves, 'Value')
    deltaGRFig = figure('Name', 'Delta G/R','Color','w');
    movegui(deltaGRFig,'northeast');
    hold on;
    
    timepoints = dlmread('timepoints.txt'); % get data for the x axis
    [ymax_r, xmax_r] = size(handles.redAvg);
    timepoints = timepoints(1:ymax_r);
    
    handles.deltaGRFig = deltaGRFig;
end;

% for each ROI defined, do the following:
keySet = keys(handles.roiMap);
nROIs = length(keySet);
currentPosition = 1;
for k=1:length(keySet)
    currentROImap = containers.Map('KeyType','char','ValueType','any');
    
    roi_name = keySet{k};
    points = handles.roiMap(roi_name);
    
    % get red and green avg for current ROI, then collapse matrices
    redAvg = handles.redAvg(points(3):points(4), points(1):points(2));
    greenAvg = handles.greenAvg(points(3):points(4), points(1):points(2));
    [collapsedR, collapsedG] = collapseGR(redAvg, greenAvg);

    % fix photobleaching if required
    if isappdata(0,'photobleachingMap')
        % retrieve photobleachingMap
        photobleachingMap = getappdata(0,'photobleachingMap');

        if isKey(photobleachingMap,roi_name)
            % get params vector for current ROI
            photobleachingParams = photobleachingMap(roi_name);

            % correct photobleaching if required
            if photobleachingParams(1)
                [collapsedR,photobleachingCompensation,photobleachingFitParams,photobleachingFitCurveEquation] = removePhotobleaching(collapsedR, photobleachingParams(2), photobleachingParams(3));
%                 if length(photobleachingCompensation) > handles.max_columns
%                    photobleachingCompensation = photobleachingCompensation(1:handles.max_columns);
%                 end;
                currentROImap('photobleachingCompensation') = photobleachingCompensation;
                currentROImap('photobleachingFitParams') = photobleachingFitParams;
                currentROImap('photobleachingFitCurveEquation') = photobleachingFitCurveEquation;
            end;
        end;
    end;

    % compute and draw GR curves
    deltaGR = computeGRcurve(collapsedR,collapsedG);

    % smooth data if required
    if smoothData       
        collapsedR = smooth(collapsedR,span);
        collapsedG = smooth(collapsedG,span);
        deltaGR = smooth(deltaGR,span);
    end;
    
    % populate subplots in GR curves figure
    if get(handles.checkbox_GRcurves, 'Value')
        % Update subplots
        % RED (R)
        subplot(3,nROIs,currentPosition);
        plot(timepoints,collapsedR, 'Color','red');
        title(strcat('[',roi_name,']  Red (R)'));
        xlabel('Time (s)');
        ylabel('Pixel intensity');

        % GREEN (G)
        subplot(3,nROIs,currentPosition+nROIs);
        plot(timepoints,collapsedG,'Color','green');
        title(strcat('[',roi_name,']  Green (G)'));
        xlabel('Time (s)');
        ylabel('Pixel intensity');

        % Delta G/R
        subplot(3,nROIs,currentPosition+2*nROIs);
        plot(timepoints,deltaGR,'Color','black');
        title(strcat('[',roi_name,']  \Delta G/R'));
        xlabel('Time (s)');
        ylabel('\Delta G/R');
    end;

    % STATS
    auc = getAreaUnderCurve(deltaGR);
    riseTime = getRiseTime(deltaGR);
    [exp1_decayTime, exp1_adjR, exp2_decayTime_fast, exp2_decayTime_slow, exp2_adjR, fitCurveEquation_exp1, fitCurveEquation_exp2] = getDecayTime(deltaGR);
    [peakValue1, peakValue2] = getPeakValue(deltaGR);
    statsMap(roi_name) = [auc riseTime peakValue1 peakValue2 exp1_decayTime exp1_adjR exp2_decayTime_fast exp2_decayTime_slow exp2_adjR];
    
    % update position counter
    currentPosition = currentPosition + 1;

    % update progress bar
    waitbar((2+k)/nSteps);
    
    % save all data to memory so that it is ready to be saved to database
%     if length(deltaGR) > handles.max_columns
%         deltaGR = deltaGR(1:handles.max_columns);
%     end;
%     if length(collapsedR) > handles.max_columns
%         collapsedR = collapsedR(1:handles.max_columns);
%     end;
%     if length(collapsedG) > handles.max_columns
%         collapsedG = collapsedG(1:handles.max_columns);
%     end;
    
    currentROImap('deltaGR') = deltaGR;
    currentROImap('collapsedR') = collapsedR;
    currentROImap('collapsedG') = collapsedG;
    currentROImap('statistics') = [auc riseTime peakValue1 peakValue2 exp1_decayTime exp1_adjR exp2_decayTime_fast exp2_decayTime_slow exp2_adjR];
    currentROImap('stats_equation_exp1') = fitCurveEquation_exp1;
    currentROImap('stats_equation_exp2') = fitCurveEquation_exp2;
    
    if ~isfield(handles,'dataToSave')
        handles.dataToSave = containers.Map('KeyType','char','ValueType','any');
    end;
    handles.dataToSave(roi_name) = currentROImap;
    guidata(hObject,handles);
end;
if get(handles.checkbox_GRcurves, 'Value')
  hold off; % for GR curves figure  
end;


% Stats in separate figure
if get(handles.checkbox_stats, 'Value')
    statsFig = generateStatsTable(statsMap);
    handles.statsFig = statsFig;
end;

% save smooth params
if smoothData
    handles.smoothed = span;% the value is the moving avg span
end;

waitbar(1); % show complete loading bar
% close loading dialog box
if isvalid(h), close(h); end;

% save changes to handles
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function redPreviewAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to redPreviewAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate redPreviewAxes

% --- Executes during object creation, after setting all properties.
function greenPreviewAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to greenPreviewAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate greenPreviewAxes


% --- Executes on button press in pushbutton_removelsm.
function pushbutton_removelsm_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_removelsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'files')
    return;
end;

% Step 1: Remove from listbox
listboxItems = get(handles.listbox_files, 'String');
idx = get(handles.listbox_files, 'Value');

listboxItems(idx)=[];
set(handles.listbox_files,'String',listboxItems);

% reset default selection
set(handles.listbox_files,'Value',1);
handles.selectedFileIndex = 1;

% Step 2: Remove from handles.files
handles.files(idx)=[];
guidata(hObject, handles);

% Step 3: Disable 'delete' button if listbox is empty
listboxItems = get(handles.listbox_files, 'String');
if isempty(listboxItems)
    set(handles.pushbutton_removelsm,'Enable','off');
    cla(handles.redPreviewAxes,'reset');
    cla(handles.greenPreviewAxes,'reset');
    
    % also clear ROIs
    pushbutton_clearROI_Callback(hObject, eventdata, handles);
    
    % clear cellID
    set(handles.edit_cellid,'String',[]);
    
    % reset morphology and firing type
    set(handles.popupmenu_morphology,'Value',1);
    set(handles.popupmenu_firingtype,'Value',1);
else
    set(handles.pushbutton_removelsm,'Enable','on');
    
    % update previews of avg of lsm files
    [handles.redAvg, handles.greenAvg] = updateLsmAvgPreviews(handles);
    guidata(hObject,handles);
end;

% Step 4: Reset lsm params
resetParams(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function pushbutton_removelsm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_removelsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu_redColormap_value.
function popupmenu_redColormap_value_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_redColormap_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_redColormap_value contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_redColormap_value
items = get(hObject,'String');
chosenColormap = items{get(hObject,'Value')};
colormap(handles.redPreviewAxes,chosenColormap);

% --- Executes during object creation, after setting all properties.
function popupmenu_redColormap_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_redColormap_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',getLsmPreviewsColorList());
set(hObject,'Value',4); % 4 corresponds to 'hot' colormap (red)

% --- Executes on selection change in popupmenu_greenColormap_value.
function popupmenu_greenColormap_value_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_greenColormap_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_greenColormap_value contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_greenColormap_value
items = get(hObject,'String');
chosenColormap = items{get(hObject,'Value')};
colormap(handles.greenPreviewAxes,chosenColormap);

% --- Executes during object creation, after setting all properties.
function popupmenu_greenColormap_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_greenColormap_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',getLsmPreviewsColorList());


% --- Executes on button press in pushbutton_openPreviews.
function pushbutton_openPreviews_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_openPreviews (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ensure list of files is specified and non-empty
if ~isfield(handles, 'files')
    warndlg('Please add lsm files for analysis before proceeding.','No preview available error');
    return;
end;
if isempty(handles.files)
    warndlg('Please add lsm files for analysis before proceeding.','No preview available error');
    return;
end;

% compute required matrices if needed
if ~isfield(handles,'redAvg') || ~isfield(handles,'greenAvg')    
    points = [1 1; 1024 1986];
    [handles.redAvg, handles.greenAvg] = submatrixaverage(handles.files,points);
    guidata(hObject,handles);
end;

itemsRed = get(handles.popupmenu_redColormap_value,'String');
itemsGreen = get(handles.popupmenu_greenColormap_value,'String');
redColormap = itemsRed{get(handles.popupmenu_redColormap_value,'Value')};
greenColormap = itemsGreen{get(handles.popupmenu_greenColormap_value,'Value')};
renderlsm(handles.redAvg,handles.greenAvg,redColormap,greenColormap);


% --- Executes on button press in pushbutton_photobleaching.
function pushbutton_photobleaching_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_photobleaching (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ensure list of files is specified and non-empty
if ~isfield(handles, 'files')
    warndlg('Please add lsm files for analysis before proceeding.','List of files error');
    return;
end;
if isempty(handles.files)
    warndlg('Please add lsm files for analysis before proceeding.','List of files error');
    return;
end;

% Ensure ROI is defined
if ~isfield(handles, 'roiMap')
    warndlg('No region of interest defined. Please set a region of interest before proceeding.','Region of interest error');
    return;
end;

% display loading message
h_photobleachingToolLoading = msgbox('Loading photobleaching correction tool...');

nFiles = length(handles.files); % to keep track of length of handles.files before removing the noisy imgs
% filter out images with noise above threshold
[filesRemovedText, nFilesRemoved] = removeNoisyImg(hObject, eventdata, handles);
if ~isempty(filesRemovedText)
    % close progress bar and clear params (ROIs)
    if isvalid(h_photobleachingToolLoading), close(h_photobleachingToolLoading); end;
    resetParams(hObject,eventdata,handles);
    
    % fix to ensure handles.files gets updated and roiMap is cleared
    handles.files = getappdata(0,'files');
    if isfield(handles,'roiMap')
        handles = rmfield(handles,'roiMap');
    end;
    guidata(hObject, handles);
    
    message = sprintf( strcat('Noise above specified threshold detected. The following files were removed:',filesRemovedText) );
    warndlg(message,'Noise detected');
    return;
end;

% fix to ensure handles.files gets updated
handles.files = getappdata(0,'files');
guidata(hObject, handles);

if nFiles == nFilesRemoved
    if isvalid(h_photobleachingToolLoading), close(h_photobleachingToolLoading); end;
    return;
end;

% compute required matrices
if ~isfield(handles,'redAvg') || ~isfield(handles,'greenAvg')    
    points = [1 1; 1024 1986];
    [handles.redAvg, handles.greenAvg] = submatrixaverage(handles.files,points);
    guidata(hObject,handles);
end;

% close loading bar
if isvalid(h_photobleachingToolLoading), close(h_photobleachingToolLoading); end;

% clear data to be saved in case user changes photobleaching params
if isfield(handles,'dataToSave')
    handles = rmfield(handles,'dataToSave');
    guidata(hObject,handles);
end;

% open photobleaching gui
photobleachingGui;


% --- Executes during object creation, after setting all properties.
function logoAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logoAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate logoAxes

% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% ================================
% HELPER FUNCTIONS - BEGINS HERE
% ================================

function updateRefMarquee(p,handles)
axes(handles.greenPreviewAxes);
global refRect
delete(refRect);
refRect = rectangle('Position',p,'LineWidth',2,'EdgeColor','w','LineStyle','--');

% roi provided here is [x1 x2 width height]
function points = getPoints(roi,numTimepoints,numPixels)
x1 = roi(1);
y1 = roi(2);
x2 = roi(1) + roi(3);
y2 = roi(2) + roi(4);

% ensure roi is within tolerated values (x[1:1024],y[1:1986])
if (x1 < 1), x1 = 1;  end;
if (x1 > numPixels), x1 = numPixels;  end;
if (x2 < 1), x2 = 1;  end;
if (x2 > numPixels), x2 = numPixels;  end;

if (y1 < 1), y1 = 1;  end;
if (y1 > numTimepoints), y1 = numTimepoints;  end;
if (y2 < 1), y2 = 1;  end;
if (y2 > numTimepoints), y2 = numTimepoints;  end;

points = [x1 y1; x2 y2];


function [redAvg,greenAvg] = updateLsmAvgPreviews(handles)
points = [1 1; 1024 1986];
[redAvg, greenAvg] = submatrixaverage(handles.files,points);

[numTimepoints,numPixels] = size(redAvg);
timepoints = dlmread('timepoints.txt');
timepoints = timepoints(1:numTimepoints);

updateRedPreview(handles,redAvg,timepoints);
updateGreenPreview(handles,greenAvg,timepoints);


function updateRedPreview(handles,R,timepoints)
% update redPreviewAxes
axes(handles.redPreviewAxes);
image(1:1024,timepoints,R,'CDataMapping','scaled');
title('Red (R)');
xlabel('Pixel');
ylabel('Time (s)');
set(gca,'Ydir','Normal');

% Apply chosen colormap
items = get(handles.popupmenu_redColormap_value,'String');
chosenColormap = items{get(handles.popupmenu_redColormap_value,'Value')};
colormap(handles.redPreviewAxes,chosenColormap);


function updateGreenPreview(handles,G,timepoints)
% update greenPreviewAxes
axes(handles.greenPreviewAxes);
image(1:1024,timepoints,G,'CDataMapping','scaled');
title('Green (G)');
xlabel('Pixel');
ylabel('Time (s)');
set(gca,'Ydir','Normal');

% Apply chosen colormap
items = get(handles.popupmenu_greenColormap_value,'String');
chosenColormap = items{get(handles.popupmenu_greenColormap_value,'Value')};
colormap(handles.greenPreviewAxes,chosenColormap);


function colors = getLsmPreviewsColorList()
colors = {'parula','jet','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink'};

function fileExtensions = getFileExtensionList()
fileExtensions = {'jpg','png','pdf','fig','m','eps','bmp','emf','pbm','pcx','pgm','ppm','tif'};

function morphologies = getMorphologies()
morphologies = {'unclassified','fusiform','multipolar','pyramidal'};

function firingTypes = getFiringTypes()
firingTypes = {'unclassified','tonic','phasic','single spike','delayed onset'};


% call this function whenever the list of lsm files is altered
function resetParams(hObject,eventdata,handles)
% clear ROIs
pushbutton_clearROI_Callback(hObject, eventdata, handles);

% clear files (handles.files)
if isfield(handles,'files')
    if isempty(handles.files)
       handles = rmfield(handles,'files'); 
    end;
end;

if isfield(handles,'roiMap')
    handles = rmfield(handles,'roiMap');
end;

if isfield(handles,'dataToSave')
    handles = rmfield(handles,'dataToSave');
end;

% save changes to handles
guidata(hObject, handles);

% clear photobleaching data
clearMemory();

% only call this function if handles.files is non-empty
function [filesRemovedText, nFilesRemoved] = removeNoisyImg (hObject, eventdata, handles)

filesRemovedText = '';
nFilesRemoved = 0;
noise_threshold = str2double( get(handles.noise_threshold_value, 'String') );

listboxItems = get(handles.listbox_files, 'String');
nFiles = length(listboxItems);

for k=nFiles:-1:1
    lsmFile = imread(handles.files{k});
    G = double( lsmFile(:,:,2) );
    
    if containsNoise(G,noise_threshold)
       % get current listbox items
       listboxItems = get(handles.listbox_files, 'String');
                
       % update list of files removed  
       filesRemovedText = sprintf( strcat(filesRemovedText,'\n•',listboxItems{k} ) );
       nFilesRemoved = nFilesRemoved + 1;
       
       % reset default selection
       set(handles.listbox_files,'Value',k);
       handles.selectedFileIndex = k;
       guidata(hObject, handles);
       
       priorData =  handles.files{k}; % filename prior to removelsm callback
       
       pushbutton_removelsm_Callback(hObject, eventdata, handles);
       
       % remove from handles.files; fixed for the fact that it only works 
       % for last file deleted otherwise
       if length(handles.files) >= k
           if strcmp( handles.files{k}, priorData)
               handles.files(k)=[];
               guidata(hObject, handles);
           end;
       end;
    end;
end;
setappdata(0,'files',handles.files);


% Functions used to enable/disable buttons while user has not confirmed ROI
function disableButtons(handles)
set(handles.pushbutton_addROI,'Enable','off');
set(handles.pushbutton_photobleaching,'Enable','off');
set(handles.pushbutton_start,'Enable','off');

function enableButtons(handles)
set(handles.pushbutton_addROI,'Enable','on');
set(handles.pushbutton_photobleaching,'Enable','on');
set(handles.pushbutton_start,'Enable','on');


function clearMemory()
if isappdata(0,'photobleachingMap')
    rmappdata(0,'photobleachingMap');
end;

% Database prepared statements
function preparedStatement = getDBInsertStatement_GR(cellID,roi_name,table_name,data,span)
values = strjoin(arrayfun(@(x) num2str(x),data,'UniformOutput',false),',');
time_columns = strjoin(arrayfun(@(x) ['t' num2str(x)],1:length(data),'UniformOutput',false),',');
columns = ['cellID,roi,smoothed,movingAvgSpan,' time_columns];

if isempty(span)
    % data NOT smoothed
    preparedStatement = ['INSERT INTO ' table_name ' (' columns ') VALUES (''' cellID ''',''' roi_name ''',''no'',''n/a'',' values ')'];
else
    % data smoothed
    preparedStatement = ['INSERT INTO ' table_name ' (' columns ') VALUES (''' cellID ''',''' roi_name ''',''yes'',' num2str(span) ',' values ')'];
end;


function preparedStatement = getDBInsertStatement_Photobleaching(cellID,roi_name,table_name,data,currentROImap)
params = currentROImap('photobleachingFitParams');
nPointsFitting = num2str(params(1));
nPointsCorrection = num2str(params(2));
adjR = num2str(params(3));
fitCurveEquation = currentROImap('photobleachingFitCurveEquation');

values = strjoin(arrayfun(@(x) num2str(x),data,'UniformOutput',false),',');
time_columns = strjoin(arrayfun(@(x) ['t' num2str(x)],1:length(data),'UniformOutput',false),',');
columns = ['cellID,roi,nPointsFitting,nPointsCorrection,fitCurveEquation,adjustedR,' time_columns];

preparedStatement = ['INSERT INTO ' table_name ' (' columns ') VALUES (''' cellID ''',''' roi_name ''',' nPointsFitting ',' nPointsCorrection ',''' fitCurveEquation ''',' adjR ',' values ')'];


function preparedStatement = getDBInsertStatement_Stats(cellID,roi_name,table_name,currentROImap,handles)
% get data
stats = currentROImap('statistics');
auc = num2str(stats(1));
riseTime = num2str(stats(2));
peakValue1 = num2str(stats(3)) ;
peakValue2 = num2str(stats(4));
exp1_decayTime = num2str(stats(5));
exp1_adjR = num2str(stats(6));
exp2_decayTime_fast = num2str(stats(7));
exp2_decayTime_slow = num2str(stats(8));
exp2_adjR = num2str(stats(9));
equation_exp1 = currentROImap('stats_equation_exp1');
equation_exp2 = currentROImap('stats_equation_exp2');

% get morphology and firing type
morphologies = get(handles.popupmenu_morphology,'String');
firingTypes = get(handles.popupmenu_firingtype,'String');
morphology = morphologies{get(handles.popupmenu_morphology,'Value')};
firingType = firingTypes{get(handles.popupmenu_firingtype,'Value')};

preparedStatement = ['INSERT INTO ' table_name ' VALUES (''' cellID ''',''' roi_name ''',''' morphology ''',''' firingType ''',' auc ',' riseTime ',' peakValue1 ',' peakValue2 ',' exp1_decayTime ',''' equation_exp1 ''',' exp1_adjR ',' exp2_decayTime_fast ',' exp2_decayTime_slow ',''' equation_exp2 ''',' exp2_adjR ')'];


function preparedStatement = getDBInsertStatement_Parameters(cellID,roi_name,table_name,handles)
noiseThreshold = get(handles.noise_threshold_value,'String');
files = strjoin(handles.files,';\n');
preparedStatement = ['INSERT INTO ' table_name ' VALUES (''' cellID ''',''' roi_name ''',''' date ''',' noiseThreshold ',''' files ''')'];


function status = createNewDatabase(pathToDatabase)
try
    db = SQLiteDatabase(pathToDatabase);
    
    sqlCommands = strsplit(fileread('sql_scripts/createDatabase.sql'), '\n');
    for command = sqlCommands
        db.prepareStatement(command{1});
        db.query();
    end;
    
    db.close();
    status = 1;
catch
    status = 0;
end;


function saveFigures(handles,cellID)
% ensure there are figures to be saved
% if ~isValidFigure(handles,'surfFig') && ~isValidFigure(handles,'deltaGRFig') && ~isValidFigure(handles,'statsFig')
if ~(isfield(handles,'surfFig') && isvalid(handles.surfFig)) && ~(isfield(handles,'deltaGRFig') && isvalid(handles.deltaGRFig)) && ~(isfield(handles,'statsFig') && isvalid(handles.statsFig))
    warndlg('Nothing to save. Please generate the figures first.','No figures to save error');
    return;
end;

% get file extension and output directory
items = get(handles.popupmenu_fileExtension,'String');
fileExtension = items{get(handles.popupmenu_fileExtension,'Value')}; % might have to prepend '.'

outputDir = get(handles.edit_outputDir,'String');
figsSaved = '';

try
    % SURFACE FIG
    if isfield(handles,'surfFig') && isvalid(handles.surfFig)
        figName = 'avg-Surfaces';
        filename = strcat(cellID,'_',figName,'.',fileExtension);
        fullPath = strcat(outputDir,'\',filename);

        % if file exists, suggest overwriting it
        if exist(fullPath,'file') == 2
            choice = questdlg(['The file ''' filename ''' already exist in the specified output directory. Would you like to overwrite it with the new figure?'], ...
                            'File already exist', ...
                            'Yes','No','No'); % last 'No' is the default value

            if strcmp(choice,'Yes')
                saveas(handles.surfFig,fullPath);
                figsSaved = strcat(figsSaved,'\n• ',filename);
            end;
        else
            saveas(handles.surfFig,fullPath);
            figsSaved = strcat(figsSaved,'\n• ',filename); 
        end;
    end;

    % DELTAGR FIG
    if isfield(handles,'deltaGRFig') && isvalid(handles.deltaGRFig)
        figName = 'deltaGR-curves';
        filename = strcat(cellID,'_',figName,'.',fileExtension);
        fullPath = strcat(outputDir,'\',filename);

        % if file exists, suggest overwriting it
        if exist(fullPath,'file') == 2
            choice = questdlg(['The file ''' filename ''' already exist in the specified output directory. Would you like to overwrite it with the new figure?'], ...
                            'File already exist', ...
                            'Yes','No','No'); % last 'No' is the default value

            if strcmp(choice,'Yes')
                saveas(handles.deltaGRFig,fullPath);
                figsSaved = strcat(figsSaved,'\n• ',filename);
            end;
        else
            saveas(handles.deltaGRFig,fullPath);
            figsSaved = strcat(figsSaved,'\n• ',filename); 
        end;
    end;

    % STATS FIG
    if isfield(handles,'statsFig') && isvalid(handles.statsFig)
        figName = 'statistics';
        filename = strcat(cellID,'_',figName,'.',fileExtension);
        fullPath = strcat(outputDir,'\',filename);

        % if file exists, suggest overwriting it
        if exist(fullPath,'file') == 2
            choice = questdlg(['The file ''' filename ''' already exist in the specified output directory. Would you like to overwrite it with the new figure?'], ...
                            'File already exist', ...
                            'Yes','No','No'); % last 'No' is the default value

            if strcmp(choice,'Yes')
                saveas(handles.statsFig,fullPath);
                figsSaved = strcat(figsSaved,'\n• ',filename);
            end;
        else
            saveas(handles.statsFig,fullPath);
            figsSaved = strcat(figsSaved,'\n• ',filename); 
        end;
    end;

    if ~isempty(figsSaved)
        message = sprintf(strcat('Figure(s) successfully saved:',figsSaved));
        msgbox(message,'Success');
    end;
    
catch ME
    display(ME.message);
    % display error message
    msgbox('An error occured while saving the figures.', 'Figure saving error','error');
end;


% ================================
% HELPER FUNCTIONS - ENDS HERE
% ================================


function noise_threshold_value_Callback(hObject, eventdata, handles)
% hObject    handle to noise_threshold_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_threshold_value as text
%        str2double(get(hObject,'String')) returns contents of noise_threshold_value as a double
threshold = str2double(get(hObject,'String'));

if isempty(threshold) || isnan(threshold)
    set(handles.noise_threshold_value,'string',0.1); % default value 0.1
elseif threshold < 0
    set(handles.noise_threshold_value,'string',0);
elseif threshold > 1
    set(handles.noise_threshold_value,'string',1);
end;


% --- Executes during object creation, after setting all properties.
function noise_threshold_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_threshold_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_clearLsm.
function pushbutton_clearLsm_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clearLsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.listbox_files, 'String', {}); % clear listbox
set(handles.pushbutton_removelsm,'Enable','off'); % Disable button

% clear graphs (previews)
cla(handles.redPreviewAxes,'reset');
cla(handles.greenPreviewAxes,'reset');

% clear files (handles.files)
if isfield(handles,'files') 
    handles = rmfield(handles,'files');
end;
if isfield(handles,'dataToSave')
    handles = rmfield(handles,'dataToSave');
end;
guidata(hObject, handles);

% clear ROIs stuff
pushbutton_clearROI_Callback(hObject, eventdata, handles);

% clear photobleaching data
clearMemory();

% clear cellID
set(handles.edit_cellid,'String',[]);

% reset morphology and firing type
set(handles.popupmenu_morphology,'Value',1);
set(handles.popupmenu_firingtype,'Value',1);



% --- Executes on button press in pushbutton_addROI.
function pushbutton_addROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Step 0: Ensure list of files is specified and non-empty
if ~isfield(handles, 'files')
    warndlg('Please add lsm files for analysis before proceeding.','List of files error');
    return;
end;
if isempty(handles.files)
    warndlg('Please add lsm files for analysis before proceeding.','List of files error');
    return;
end;

% Step 1: Get user input for name of new ROI
prompt = 'Enter name for new region of interest: ';
dlg_title = 'New ROI';
roi_name = inputdlg(prompt,dlg_title,[1, 45]);

% ensure a name is provided for the new ROI
if isempty(roi_name), return; end; % when user clicks 'cancel'
if isempty(roi_name{1}), return; end; % when user clicks 'ok' with empty string

% Update ROI listbox
if isfield(handles, 'roiMap')
    % ensure unique name was provided, else return
    if isKey(handles.roiMap,roi_name{1})
        warndlg('The provided name is already assigned to another region of interest.','Unique ROI name error');
        return;
    end;

    % update listbox items
    previousListboxItems = get(handles.listbox_ROI, 'String');    
    set(handles.listbox_ROI,'String',[transpose(previousListboxItems) roi_name]);
    
    % select newly added item
    set(handles.listbox_ROI,'Value',length(previousListboxItems)+1);
else    
    % update listbox items
    set(handles.listbox_ROI,'String',roi_name);
    set(handles.listbox_ROI,'Value',1);
end;

% remove current outline if any
if isfield(handles,'selectedROI_rect')
    delete(handles.selectedROI_rect);
end;

% Step 2: Draw resizable/draggable ROI
% get limits on selection
[numTimepoints,numPixels] = size(handles.redAvg);
timepoints = dlmread('timepoints.txt');
maxTimepoint = timepoints(numTimepoints);

selectionWidth = 500;
if numPixels < 500
    selectionWidth = numPixels;
end;

% rectangular selection on red preview
axes(handles.redPreviewAxes);
h = imrect(gca, [0 0 selectionWidth maxTimepoint]); % use only 'imrect' if you want to avoid default selection
fcn = makeConstrainToRectFcn('imrect',[0 numPixels],[0 maxTimepoint]);
setPositionConstraintFcn(h,fcn);

% reference marquee on green preview
axes(handles.greenPreviewAxes);
global refRect
refRect = rectangle('Position',[0 0 selectionWidth maxTimepoint],'LineWidth',2,'EdgeColor','w','LineStyle','--');
addNewPositionCallback(h,@(p) updateRefMarquee(p,handles));
axes(handles.redPreviewAxes);

% disable button to ensure ROI is confirmed (double-clicked) before
% proceeding
disableButtons(handles);

% wait for user to confirm roi (double-click selection)
roi = wait(h); %roi = region of interest
roi = uint32(roi);

% Fix for analysis
roi(2) = 1;
roi(4) = numTimepoints;

% re-enable buttons
enableButtons(handles);

% if user deletes selection in any way (right-click deletion, click away,
% etc.), then do not set selected region
if isempty(roi)
    % 1. remove roi listbox
    listboxItems = get(handles.listbox_ROI, 'String');
    idx = get(handles.listbox_ROI, 'Value');
    listboxItems(idx)=[];
    set(handles.listbox_ROI,'String',listboxItems);
    
    % 2. update selected item in roi listbox
    if ~isempty(listboxItems)
        set(handles.listbox_ROI,'Value',1);
    end;
    return;
end;

% Update roiMap
if isfield(handles, 'roiMap')
    % add item to roiMap
    handles.roiMap(roi_name{1}) = getPoints(roi,numTimepoints,numPixels);
else 
    % instantiate roiMap and add new key-value pair
    keySet = {roi_name{1}};
    valueSet = {getPoints(roi,numTimepoints,numPixels)};
    mapObj = containers.Map(keySet,valueSet);
    handles.roiMap = mapObj;
end;
guidata(hObject, handles);

% delete draggable/resizable ROI and marquee in other preview box
delete(h);
delete(refRect);

% outline position of ROI
points = handles.roiMap(roi_name{1});
x1 = points(1);
y1 = 0;
width = points(2) - x1;
height = maxTimepoint;

r = rectangle('Position',[x1 y1 width ceil(height)],'LineWidth',2,'EdgeColor','y');
axes(handles.greenPreviewAxes);
rg = rectangle('Position',[x1 y1 width ceil(height)],'LineWidth',2,'EdgeColor','y');
axes(handles.redPreviewAxes);

% add ref to rectangle to roiRectMap
if ~isfield(handles,'roiRectMap')
    handles.roiRectMap = containers.Map('KeyType','char','ValueType','any');
end;
handles.roiRectMap(roi_name{1}) = [r,rg];

% Enable/Disable 'delete' button as appropriate
listboxItems = get(handles.listbox_ROI, 'String');
if isempty(listboxItems)
    set(handles.pushbutton_removeROI,'Enable','off');
else
    set(handles.pushbutton_removeROI,'Enable','on');
end;

% to outline currently selected ROI
listbox_ROI_Callback(hObject, eventdata, handles);



% --- Executes on selection change in listbox_ROI.
function listbox_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_ROI contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_ROI

% ensure listbox is not empty & get selected roi name
listboxItems = get(handles.listbox_ROI, 'String');
if strcmp(listboxItems,'No ROI defined')
    return;
end;
if isempty(listboxItems)
    return;
end;
idx = get(handles.listbox_ROI, 'Value');
roi_name = listboxItems{idx};

% remove current outline if any
if isfield(handles,'selectedROI_rect')
    delete(handles.selectedROI_rect);
end;

% get limits on selection
[numTimepoints,numPixels] = size(handles.redAvg);
timepoints = dlmread('timepoints.txt');
maxTimepoint = timepoints(numTimepoints);

% get rectangle coordinates
points = handles.roiMap(roi_name);
x1 = points(1);
y1 = 0;
width = points(2) - x1;
height = maxTimepoint;

% select RED preview & draw rectangle
axes(handles.redPreviewAxes);
r = rectangle('Position',[x1 y1 width ceil(height)],'LineWidth',2,'EdgeColor','g');
axes(handles.greenPreviewAxes);
rg = rectangle('Position',[x1 y1 width ceil(height)],'LineWidth',2,'EdgeColor','g');

% save changes to handles
handles.selectedROI_rect = [r,rg];
handles.selectedROI_name = roi_name;
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function listbox_ROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_clearROI.
function pushbutton_clearROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clearROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear listbox_roi items
set(handles.listbox_ROI, 'String', {});
set(handles.pushbutton_removeROI,'Enable','off');

% reload lsm preview if needed
listboxItems_files = get(handles.listbox_files, 'String');
if ~isempty(listboxItems_files)
    updateLsmAvgPreviews(handles);
end;

% clear ROIs data
fieldsToClear = {'roiMap','roiRectMap','selectedROI_rect','selectedROI_name','dataToSave'};
for f = fieldsToClear
    if isfield(handles,f{1})
        handles = rmfield(handles,f{1});
    end;
end;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_removeROI.
function pushbutton_removeROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_removeROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
listboxItems = get(handles.listbox_ROI, 'String');
idx = get(handles.listbox_ROI, 'Value');
key = listboxItems{idx};

% remove from roiMap
remove(handles.roiMap,key);

% remove from listbox
listboxItems(idx)=[];
set(handles.listbox_ROI,'String',listboxItems);

% remove item from roiRectMap
if isfield(handles,'roiRectMap')
    axes(handles.redPreviewAxes);
    
    % delete yellow rectangles from red and green previews
    rects = handles.roiRectMap(key);
    for k=1:length(rects)
        delete(rects(k));
    end;
    
    remove(handles.roiRectMap, key);
    if isempty(handles.roiRectMap)
        handles = rmfield(handles,'roiRectMap');
    end;
end;

if isfield(handles,'selectedROI_rect')
    r = handles.selectedROI_rect;
    delete(r);
    handles = rmfield(handles, 'selectedROI_rect');
end;

% Disable 'delete' button if listbox is empty
listboxItems = get(handles.listbox_ROI, 'String');
if isempty(listboxItems)
    set(handles.pushbutton_removeROI,'Enable','off');
    handles = rmfield(handles,'roiMap');
    % TBC - also removed everything related to ROIs (roiRectMap, _name,
    % _rect, etc.
else
    set(handles.pushbutton_removeROI,'Enable','on');
    set(handles.listbox_ROI,'Value',1); % reset default selection
end;

% save changes to handles
guidata(hObject, handles);

listbox_ROI_Callback(hObject, eventdata, handles); % to update current rect outline


% --- Executes on button press in checkbox_GRsurfaces.
function checkbox_GRsurfaces_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_GRsurfaces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_GRsurfaces


% --- Executes on button press in checkbox_GRcurves.
function checkbox_GRcurves_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_GRcurves (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_GRcurves


% --- Executes during object creation, after setting all properties.
function checkbox_GRsurfaces_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_GRsurfaces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function checkbox_GRcurves_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_GRsurfaces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkbox_stats.
function checkbox_stats_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_stats



function edit_cellid_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cellid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cellid as text
%        str2double(get(hObject,'String')) returns contents of edit_cellid as a double


% --- Executes during object creation, after setting all properties.
function edit_cellid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cellid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_saveToDB.
function pushbutton_saveToDB_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveToDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ensure there is data to be saved
if ~isfield(handles,'dataToSave')
    warndlg('Nothing to save. Please run the analysis first.','No data to save error');
    return;
end;
if isempty(handles.dataToSave)
    warndlg('Nothing to save. Please run the analysis first.','No data to save error');
    return;
end;

% get cell identifier 
cellID = get(handles.edit_cellid,'String');

% remove slashes from cellID if any (not allowed since they cause issue
% with the database)
cellID(regexp(cellID,'[\,/]')) = [];
set(handles.edit_cellid,'String',cellID);

% ensure cell identifier is non empty
if isempty(cellID)
    warndlg('A cell identifier must be specified.','Cell identifier error');
    return;
end;


% get path to database and ensure it is non empty and references a file
pathToDB = get(handles.edit_pathToDB,'String');
if isempty(pathToDB) || contains(pathToDB,'db') == 0
    warndlg('A path to the database file must be specified. File extension must be db.','Database path error');
    return;
end;
if exist(pathToDB,'file') ~= 2
    choice = questdlg('The database specified does not exist. Would you like to create a new empty database?', ...
      'Data not found error', ...
      'Yes','No','No'); % last 'No' is the default value
  
    if strcmp(choice,'Yes')
        status = createNewDatabase(pathToDB);
        if status == 0
            % display error message
            msgbox('An error occured while creating the database. Operation cancelled.', 'Database error','error');
            return;
        end;
    else
        return;
    end;
end;

% get smoothing moving average span
span = [];
smoothData = get(handles.checkbox_smooth,'Value');
if smoothData
    spanText = get(handles.edit_smooth_value,'String');
    span = str2num(spanText);
end;

% Connect to DB and insert/update data
try
    % open connection to database
    db = SQLiteDatabase(pathToDB);
    keySet = keys(handles.dataToSave); % all ROIs

    % start transaction
    db.prepareStatement('BEGIN TRANSACTION');
    db.query();

    for k=1:length(keySet)
        roi_name = keySet{k};
        currentROImap = handles.dataToSave(roi_name);

        % truncate data to fit in database (max length is handles.max_columns)
        if isKey(currentROImap,'photobleachingCompensation')
            photobleachingCompensation = currentROImap('photobleachingCompensation');
            if length(photobleachingCompensation) > handles.max_columns
                photobleachingCompensation = photobleachingCompensation(1:handles.max_columns);
            end;
        end;
        
        deltaGR = currentROImap('deltaGR');
        collapsedR = currentROImap('collapsedR');
        collapsedG = currentROImap('collapsedG');
        if length(deltaGR) > handles.max_columns
            deltaGR = deltaGR(1:handles.max_columns);
        end;
        if length(collapsedR) > handles.max_columns
            collapsedR = collapsedR(1:handles.max_columns);
        end;
        if length(collapsedG) > handles.max_columns
            collapsedG = collapsedG(1:handles.max_columns);
        end;
        
        try
            % perform inserts            
            db.prepareStatement( getDBInsertStatement_GR(cellID,roi_name,'deltagr',deltaGR,span) );
            db.query();
            db.prepareStatement( getDBInsertStatement_GR(cellID,roi_name,'redAbsIntensity',collapsedR,span) );
            db.query();
            db.prepareStatement( getDBInsertStatement_GR(cellID,roi_name,'greenAbsIntensity',collapsedG,span) );
            db.query();

            if isKey(currentROImap,'photobleachingCompensation')
                db.prepareStatement( getDBInsertStatement_Photobleaching(cellID,roi_name,'photobleachingCorrection',photobleachingCompensation,currentROImap) );
                db.query();
            end;

            db.prepareStatement(getDBInsertStatement_Stats(cellID,roi_name,'statistics',currentROImap,handles));
            db.query();

            % save configuration params to database
            db.prepareStatement(getDBInsertStatement_Parameters(cellID,roi_name,'parameters',handles));
            db.query();

        catch ME
            display(ME.message);
            if ~isempty( strfind(ME.message,'UNIQUE') )
                % notify user of non unique id issue
                choice = questdlg(['The combination of the cell identifier and roi (' cellID ',' roi_name ') was previously used, would you like to overwrite the old data with the new data?'], ...
                      'Non unique cell identifier', ...
                      'Yes','No','No'); % last 'No' is the default value


                if strcmp(choice,'Yes')
                    % step 1: delete current data for (cellID,roi) 
                    tablesToUpdate = {'deltagr','redAbsIntensity','greenAbsIntensity','photobleachingCorrection','statistics','parameters'};
                    for t = tablesToUpdate
                        db.prepareStatement( ['DELETE FROM ' t{1} ' WHERE cellID=''' cellID ''' AND roi=''' roi_name ''''] );
                        db.query();
                    end;

                    % step 2: insert new data
                    % perform inserts
                    db.prepareStatement( getDBInsertStatement_GR(cellID,roi_name,'deltagr',deltaGR,span) );
                    db.query();
                    db.prepareStatement( getDBInsertStatement_GR(cellID,roi_name,'redAbsIntensity',collapsedR,span) );
                    db.query();
                    db.prepareStatement( getDBInsertStatement_GR(cellID,roi_name,'greenAbsIntensity',collapsedG,span) );
                    db.query();

                    if isKey(currentROImap,'photobleachingCompensation')
                        db.prepareStatement( getDBInsertStatement_Photobleaching(cellID,roi_name,'photobleachingCorrection',photobleachingCompensation,currentROImap) );
                        db.query();
                    end;

                    db.prepareStatement(getDBInsertStatement_Stats(cellID,roi_name,'statistics',currentROImap,handles));
                    db.query();

                    % save configuration params to database
                    db.prepareStatement(getDBInsertStatement_Parameters(cellID,roi_name,'parameters',handles));
                    db.query();
                end;
            end;
        end;
    end;

    % commit transaction
    db.prepareStatement('COMMIT');
    db.query();

    % close connection
    db.close();

    % display success message
    msgbox('Data successfully saved to the database.','Success');

catch ME2
    display(ME2.message);
    % display error message
    msgbox('An error occured while saving to the database. No data was added to the database.', 'Database error','error');
end;


function edit_pathToDB_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pathToDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pathToDB as text
%        str2double(get(hObject,'String')) returns contents of edit_pathToDB as a double


% --- Executes during object creation, after setting all properties.
function edit_pathToDB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pathToDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browseDB.
function pushbutton_browseDB_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browseDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile({'*.*'},'Select database file');  % '*.db';'*.csv'
if path ~= 0
    fullPath = strcat(path,filename);
    set(handles.edit_pathToDB,'String',fullPath); 
end;




function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_saveFigures.
function pushbutton_saveFigures_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveFigures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cellID = get(handles.edit_cellid,'String');
% ensure cell identifier is non empty
if isempty(cellID)
    warndlg('A cell identifier must be specified.','Cell identifier error');
    return;
end;

saveFigures(handles,cellID);

% --- Executes on selection change in popupmenu_fileExtension.
function popupmenu_fileExtension_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_fileExtension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_fileExtension contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_fileExtension


% --- Executes during object creation, after setting all properties.
function popupmenu_fileExtension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_fileExtension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',getFileExtensionList());


function edit_outputDir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_outputDir as text
%        str2double(get(hObject,'String')) returns contents of edit_outputDir as a double


% --- Executes during object creation, after setting all properties.
function edit_outputDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browseOutputDir.
function pushbutton_browseOutputDir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browseOutputDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirPath = uigetdir;
if dirPath ~= 0
    set(handles.edit_outputDir,'String',dirPath);
end;


function edit_smooth_value_Callback(hObject, eventdata, handles)
% hObject    handle to edit_smooth_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_smooth_value as text
%        str2double(get(hObject,'String')) returns contents of edit_smooth_value as a double


% --- Executes during object creation, after setting all properties.
function edit_smooth_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_smooth_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_smooth.
function checkbox_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_smooth
isChecked = get(hObject,'Value');
if isChecked
    set(handles.text_smooth_label,'Enable','on');
    set(handles.edit_smooth_value,'Enable','on');
else
    set(handles.text_smooth_label,'Enable','off');
    set(handles.edit_smooth_value,'Enable','off');
    
    if isfield(handles,'smoothed')
        handles = rmfield(handles,'smoothed');
    end;
end;

% Clear data to save, analysis must be started again
% every time the state of this checkbox changes.
if isfield(handles,'dataToSave')
    handles = rmfield(handles,'dataToSave');
end;
guidata(hObject, handles);


% --- Executes on selection change in popupmenu_firingtype.
function popupmenu_firingtype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_firingtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_firingtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_firingtype


% --- Executes during object creation, after setting all properties.
function popupmenu_firingtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_firingtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',getFiringTypes());


% --- Executes on selection change in popupmenu_morphology.
function popupmenu_morphology_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_morphology (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_morphology contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_morphology


% --- Executes during object creation, after setting all properties.
function popupmenu_morphology_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_morphology (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',getMorphologies());




% --- Executes on button press in pushbutton_dbtool.
function pushbutton_dbtool_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dbtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
databaseGui;


% --- Executes on button press in pushbutton_saveToCSV.
function pushbutton_saveToCSV_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveToCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ensure there is data to be saved
if ~isfield(handles,'dataToSave')
    warndlg('Nothing to save. Please run the analysis first.','No data to save error');
    return;
end;
if isempty(handles.dataToSave)
    warndlg('Nothing to save. Please run the analysis first.','No data to save error');
    return;
end;

% get cell identifier 
cellID = get(handles.edit_cellid,'String');

% remove slashes from cellID if any (not allowed since they cause issue
% with the database)
cellID(regexp(cellID,'[\,/]')) = [];
set(handles.edit_cellid,'String',cellID);

% ensure cell identifier is non empty
if isempty(cellID)
    warndlg('A cell identifier must be specified.','Cell identifier error');
    return;
end;

% get path to csv file
pathToCSV = get(handles.edit_pathToDB,'String');
if isempty(pathToCSV) || contains(pathToCSV,'csv') == 0
    warndlg('A path to a csv file must be specified. File extension must be csv.','csv path error');
    return;
end;

% get smoothing moving average span
span = 'n/a';
smoothData = get(handles.checkbox_smooth,'Value');
if smoothData
    spanText = get(handles.edit_smooth_value,'String');
    span = spanText;
end;

% set smoothed variable
if strcmp(span, 'n/a')
    smoothed = 'no';
else
    smoothed = 'yes';
end;

% save deltaGR data to file
try
    % if new file, append header row
    if exist(pathToCSV, 'file') ~= 2
        fid = fopen(pathToCSV,'a');
        % write column headers
        colHeaders = {'cellID' 'roi' 'smoothed' 'movingAvgSpan'};
        colHeaders = strjoin(colHeaders, ',');
        fprintf(fid,'%s\n',colHeaders);
    else
        fid = fopen(pathToCSV,'a');
    end;

    keySet = keys(handles.dataToSave); % all ROIs
    for k=1:length(keySet)
        roi_name = keySet{k};
        currentROImap = handles.dataToSave(roi_name);
        deltaGR = currentROImap('deltaGR');

        % write row to file
        rowMetadata = {cellID roi_name smoothed span};
        rowMetadata = strjoin(rowMetadata,',');
        rowData = strjoin(string(deltaGR),',');
        fprintf(fid,'%s,%s\n',rowMetadata,rowData);
    end;
    fclose(fid);
    
    % display success message
    msgbox('Data successfully saved to csv file.','Success');
catch ME
    display(ME.message);
    msgbox('An error occured while saving to the csv file. Ensure the file is not opened or being used by another program and try again.', 'CSV error','error');
end;
