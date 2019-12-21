function varargout = photobleachingGui(varargin)
% PHOTOBLEACHINGGUI MATLAB code for photobleachingGui.fig
%      PHOTOBLEACHINGGUI, by itself, creates a new PHOTOBLEACHINGGUI or raises the existing
%      singleton*.
%
%      H = PHOTOBLEACHINGGUI returns the handle to a new PHOTOBLEACHINGGUI or the handle to
%      the existing singleton*.
%
%      PHOTOBLEACHINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHOTOBLEACHINGGUI.M with the given input arguments.
%
%      PHOTOBLEACHINGGUI('Property','Value',...) creates a new PHOTOBLEACHINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before photobleachingGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to photobleachingGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help photobleachingGui

% Last Modified by GUIDE v2.5 14-Jun-2016 15:44:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @photobleachingGui_OpeningFcn, ...
                   'gui_OutputFcn',  @photobleachingGui_OutputFcn, ...
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


% --- Executes just before photobleachingGui is made visible.
function photobleachingGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to photobleachingGui (see VARARGIN)

% Choose default command line output for photobleachingGui
handles.output = hObject;

% define lower bound
handles.nPointsLowerBound = 4;

% get data for the x axis
handles.timepoints = dlmread('timepoints.txt');

% retrieve photobleachingMap if already set
if isappdata(0,'photobleachingMap')
    handles.photobleachingMap = getappdata(0,'photobleachingMap');
end;

% update handles
guidata(hObject, handles);

% perform callback on selected item to update graphs
listbox_roi_Callback(hObject, eventdata, handles);



% --- Outputs from this function are returned to the command line.
function varargout = photobleachingGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_fitting_Callback(hObject, eventdata, handles)
% hObject    handle to slider_fitting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderVal = get(hObject,'Value');
editVal = round( (handles.sizeCollapsedR - handles.nPointsLowerBound)*sliderVal + handles.nPointsLowerBound );

% ensure fitting >= correction
if ~isValidFittingValue_Slider(handles,editVal), return; end;

set(handles.edit_fitting,'string',num2str(editVal));

% update gui handles data
handles.nPointsFitting = editVal;
guidata(hObject, handles);

updateGraphs(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider_fitting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_fitting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_correction_Callback(hObject, eventdata, handles)
% hObject    handle to slider_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderVal = get(hObject,'Value');
editVal = round( (handles.sizeCollapsedR - handles.nPointsLowerBound)*sliderVal + handles.nPointsLowerBound );

% ensure fitting >= correction
if ~isValidCorrectionValue_Slider(handles,editVal), return; end;

set(handles.edit_correction,'string',num2str(editVal));

% update gui handles data
handles.nPointsCorrection = editVal;
guidata(hObject, handles);

updateGraphs(hObject,handles);


% --- Executes during object creation, after setting all properties.
function slider_correction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_fitting_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fitting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fitting as text
%        str2double(get(hObject,'String')) returns contents of edit_fitting as a double
editVal = str2num(get(hObject,'String'));

% ensure fitting >= correction
if ~isValidFittingValue_Edit(handles,editVal), return; end;

editVal = adjustEditVal(handles,editVal);

% overwrite edit value
set(handles.edit_fitting,'string',num2str(editVal));

sliderVal = (editVal - handles.nPointsLowerBound) / (handles.sizeCollapsedR - handles.nPointsLowerBound);
set(handles.slider_fitting,'value',sliderVal);

% update gui handles data
handles.nPointsFitting = editVal;
guidata(hObject, handles);

updateGraphs(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit_fitting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fitting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_correction_Callback(hObject, eventdata, handles)
% hObject    handle to edit_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_correction as text
%        str2double(get(hObject,'String')) returns contents of edit_correction as a double
editVal = str2num(get(hObject,'String'));

% ensure fitting >= correction
if ~isValidCorrectionValue_Edit(handles,editVal), return; end;

editVal = adjustEditVal(handles,editVal);

% overwrite edit value
set(handles.edit_correction,'string',num2str(editVal));

sliderVal = (editVal - handles.nPointsLowerBound) / (handles.sizeCollapsedR - handles.nPointsLowerBound);
set(handles.slider_correction,'value',sliderVal);

% update gui handles data
handles.nPointsCorrection = editVal;
guidata(hObject, handles);

updateGraphs(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_correction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear;
close;


% ================================
% HELPER FUNCTIONS - BEGINS HERE
% ================================

function updateGraphs(hObject,handles)
if ~isfield(handles,'timepoints')
    handles.timepoints = dlmread('timepoints.txt');
    guidata(hObject, handles);
end;

% Graph BEFORE photobleaching correction
axes(handles.axes_before);

x = handles.timepoints(1:handles.nPointsFitting);
y = handles.collapsedR(1:handles.nPointsFitting);
f = fit(x,y,'exp2');
plot(f,x,y);
title('Initial data BEFORE photobleaching correction (EXP2 curve fitting)');
xlabel('Time (s)');
ylabel('Pixel intensity');

% In-between computations - To identify EXP component
% exp component of f, where f(x) = ae^(bx) + ce^(dx)
if abs(f.d) <= abs(f.b)
    exp_component = (f.a)*exp((f.b)*x(:));
else
    exp_component = (f.c)*exp((f.d)*x(:));
end;

% Graph AFTER photobleaching correction
axes(handles.axes_after);

y(1:handles.nPointsCorrection) = y(1:handles.nPointsCorrection) - exp_component(1:handles.nPointsCorrection);
% f2 = fit(x,y,'exp2');
s = scatter(x,y);
set(s,'Marker','.','MarkerEdgeColor','b');
title('Data AFTER photobleaching correction');
xlabel('Time');
ylabel('Pixel intensity');

% ensure both graphs have to same y axis to facilitate comparison
linkaxes([handles.axes_before,handles.axes_after],'y');

% save data to root
savePhotobleachingMap(handles);

% to validate new Fitting Slider value
function isValid = isValidFittingValue_Slider(handles,newVal)
if newVal < handles.nPointsCorrection
    previousSliderVal = (handles.nPointsFitting - handles.nPointsLowerBound) / (handles.sizeCollapsedR - handles.nPointsLowerBound);
    set(handles.slider_fitting,'value',previousSliderVal);
    warndlg('The fitting curve must include at least the same number of datapoints as the number of datapoints to be corrected.','Datapoints error');
    isValid = 0;
else
    isValid = 1;
end;


% to validate new Correction Slider value
function isValid = isValidCorrectionValue_Slider(handles,newVal)
if newVal > handles.nPointsFitting
    previousSliderVal = (handles.nPointsCorrection - handles.nPointsLowerBound) / (handles.sizeCollapsedR - handles.nPointsLowerBound);
    set(handles.slider_correction,'value',previousSliderVal);
    warndlg('The number of datapoints to be corrected cannot exceed the number of points used in the curve fitting.','Datapoints error');
    isValid = 0;
else
    isValid = 1;
end;


% to validate new Fitting Edit value
function isValid = isValidFittingValue_Edit(handles,newVal)
if newVal < handles.nPointsCorrection
    set(handles.edit_fitting,'string',handles.nPointsFitting);
    warndlg('The fitting curve must include at least the same number of datapoints as the number of datapoints to be corrected.','Datapoints error');
    isValid = 0;
else
    isValid = 1;
end;


% to validate new Correction Edit value
function isValid = isValidCorrectionValue_Edit(handles,newVal)
if newVal > handles.nPointsFitting
    set(handles.edit_correction,'string',handles.nPointsCorrection);
    warndlg('The number of datapoints to be corrected cannot exceed the number of points used in the curve fitting.','Datapoints error');
    isValid = 0;
else
    isValid = 1;
end;


function adjustedEditVal = adjustEditVal(handles,editVal)
% adjust val if beyond boundaries
if editVal > handles.sizeCollapsedR, editVal = handles.sizeCollapsedR; end;
if editVal < handles.nPointsLowerBound, editVal = handles.nPointsLowerBound; end;

% remove decimal part, if any
adjustedEditVal = floor(editVal);


function savePhotobleachingMap(handles)
% save map to root
isChecked = get(handles.checkbox_correctPhotobleaching, 'Value');
if isChecked && isfield(handles,'photobleachingMap')
    listboxItems = get(handles.listbox_roi, 'String');
    idx = get(handles.listbox_roi, 'Value');
    roi_name = listboxItems{idx};
    
    handles.photobleachingMap(roi_name) = [1,handles.nPointsFitting,handles.nPointsCorrection];
    setappdata(0,'photobleachingMap',handles.photobleachingMap);
end;

% remove map from root if empty or not present
if isappdata(0,'photobleachingMap')
    if ~isfield(handles,'photobleachingMap')
        rmappdata(0,'photobleachingMap');
    elseif isempty(handles.photobleachingMap)
        rmappdata(0,'photobleachingMap');
    end;
end;


function toggleButtons(handles,state)
set(handles.listbox_roi,'Enable',state);
set(handles.checkbox_correctPhotobleaching,'Enable',state);
set(handles.slider_fitting,'Enable',state);
set(handles.slider_correction,'Enable',state);
set(handles.edit_fitting,'Enable',state);
set(handles.edit_correction,'Enable',state);

% ================================
% HELPER FUNCTIONS - ENDS HERE
% ================================


% --- Executes on selection change in listbox_roi.
function listbox_roi_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_roi contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_roi

% ======================

% Disable buttons
toggleButtons(handles,'off');

% get access to main gui data
h_mainGui = findobj('Tag','gui_main');
if ~isempty(h_mainGui)
    mainGui = guidata(h_mainGui);
end;

% get selected roi name
listboxItems = get(handles.listbox_roi, 'String');
idx = get(handles.listbox_roi, 'Value');
roi_name = listboxItems{idx};

% get points
points = mainGui.roiMap(roi_name);

% get submatrices
redAvg = mainGui.redAvg(points(3):points(4), points(1):points(2));
greenAvg = mainGui.greenAvg(points(3):points(4), points(1):points(2));

% collapse matrices
[collapsedR,collapsedG] = collapseGR(redAvg, greenAvg);
handles.collapsedR = collapsedR;
handles.sizeCollapsedR = length(collapsedR);

% update checkbox state, nPointsFitting, nPointsCorrection
if isfield(handles, 'photobleachingMap')
    if isKey(handles.photobleachingMap,roi_name)
        mData = handles.photobleachingMap(roi_name);        

        % checkbox state: 1 is 'checked', 0 otherwise
        if mData(1)
            set(handles.checkbox_correctPhotobleaching,'Value',1); % checked
        else
            set(handles.checkbox_correctPhotobleaching,'Value',0); % NOT checked
        end;
        
        % num fitting & correction points
        if mData(2) && mData(3)
            % use this value and then update graph
            handles.nPointsFitting = mData(2);
            handles.nPointsCorrection = mData(3);
        else
            % get optimal params and update graph
            [handles.nPointsFitting, handles.nPointsCorrection] = getOptimalPhotobleachingParams(collapsedR);
        end;
    else
        set(handles.checkbox_correctPhotobleaching,'Value',0); % NOT checked
        [handles.nPointsFitting, handles.nPointsCorrection] = getOptimalPhotobleachingParams(collapsedR);
    end;
else
    set(handles.checkbox_correctPhotobleaching,'Value',0); % NOT checked
    [handles.nPointsFitting, handles.nPointsCorrection] = getOptimalPhotobleachingParams(collapsedR);
end;
guidata(hObject,handles); % save changes to handles

% update edit text values
set(handles.edit_fitting,'string',num2str(handles.nPointsFitting));
set(handles.edit_correction,'string',num2str(handles.nPointsCorrection));

% update sliders
sliderVal = (handles.nPointsFitting - 1) / (handles.sizeCollapsedR - 1);
set(handles.slider_fitting,'value',sliderVal);

sliderVal = (handles.nPointsCorrection - 1) / (handles.sizeCollapsedR - 1);
set(handles.slider_correction,'value',sliderVal);

% update graphs
updateGraphs(hObject,handles);

% Enable buttons
toggleButtons(handles,'on');


% --- Executes during object creation, after setting all properties.
function listbox_roi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

h_mainGui = findobj('Tag','gui_main');
if ~isempty(h_mainGui)
    mainGui = guidata(h_mainGui);
end;

roiItems = get(mainGui.listbox_ROI, 'String');
set(hObject,'String',transpose(roiItems));

% --- Executes on button press in checkbox_correctPhotobleaching.
function checkbox_correctPhotobleaching_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_correctPhotobleaching (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_correctPhotobleaching

% get selected roi name
listboxItems = get(handles.listbox_roi, 'String');
idx = get(handles.listbox_roi, 'Value');
roi_name = listboxItems{idx};

% get checkbox state
isChecked = get(handles.checkbox_correctPhotobleaching, 'Value');
if (isChecked)
    if ~isfield(handles, 'photobleachingMap')
        % instantiate roiMap and add new key-value pair
        handles.photobleachingMap = containers.Map('KeyType','char','ValueType','any');
    end;

    % add/update item to photobleachingMap
    handles.photobleachingMap(roi_name) = [1,handles.nPointsFitting,handles.nPointsCorrection]; 
else
    if isfield(handles, 'photobleachingMap')
        if isKey(handles.photobleachingMap,roi_name)
            remove(handles.photobleachingMap,roi_name);
        end;
        
        if length(handles.photobleachingMap) < 1
            handles = rmfield(handles,'photobleachingMap');
        end;
    end;
end;
guidata(hObject, handles); 

% save changes to photobleaching map
savePhotobleachingMap(handles);

