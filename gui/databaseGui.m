function varargout = databaseGui(varargin)
% DATABASEGUI MATLAB code for databaseGui.fig
%      DATABASEGUI, by itself, creates a new DATABASEGUI or raises the existing
%      singleton*.
%
%      H = DATABASEGUI returns the handle to a new DATABASEGUI or the handle to
%      the existing singleton*.
%
%      DATABASEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATABASEGUI.M with the given input arguments.
%
%      DATABASEGUI('Property','Value',...) creates a new DATABASEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before databaseGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to databaseGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help databaseGui

% Last Modified by GUIDE v2.5 24-Aug-2016 11:36:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @databaseGui_OpeningFcn, ...
                   'gui_OutputFcn',  @databaseGui_OutputFcn, ...
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


% --- Executes just before databaseGui is made visible.
function databaseGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to databaseGui (see VARARGIN)

% Choose default command line output for databaseGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

axes(handles.dbBannerAxes);
imshow('database-banner.jpg');

% get access to main gui data
h_mainGui = findobj('Tag','gui_main');
if ~isempty(h_mainGui)
    mainGui = guidata(h_mainGui);
    
    % set database path to the one in mainGui
    set(handles.edit_pathToDB,'String',get(mainGui.edit_pathToDB,'String'));
end;


% --- Outputs from this function are returned to the command line.
function varargout = databaseGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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
[filename, path] = uigetfile({'*.db'},'Select database file');
if path ~= 0
    fullPath = strcat(path,filename);
    set(handles.edit_pathToDB,'String',fullPath);
end;


% --- Executes on button press in pushbutton_updateCellID.
function pushbutton_updateCellID_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_updateCellID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Step 1: Get inputs
old_cellID = get(handles.edit_updatecellid_old,'String');
new_cellID = get(handles.edit_updatecellid_new,'String');
% ensure cell identifiers are non empty
if isempty(old_cellID)
    warndlg('The current cell identifier must be specified.','Cell identifier error');
    return;
end;
if isempty(new_cellID)
    warndlg('A new cell identifier must be specified.','Cell identifier error');
    return;
end;

% Step 2: Run UPDATE SQL commands
try
    pathToDB = get(handles.edit_pathToDB,'String');
    db = SQLiteDatabase(pathToDB);

    tables = getTables();
    for t = tables
        preparedStatement = ['UPDATE ' t{1} ' SET cellID=''' new_cellID ''' WHERE cellID=''' old_cellID ''''];
        db.prepareStatement(preparedStatement);
        db.query();
    end;

    db.close();
    msgbox('Update operation successfully completed.','Success');
catch ME
%     display(ME.message);
    msgbox('An error occured while updating the cell data. Operation aborted.', 'Cell update error','error');
end;


function edit_updatecellid_old_Callback(hObject, eventdata, handles)
% hObject    handle to edit_updatecellid_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_updatecellid_old as text
%        str2double(get(hObject,'String')) returns contents of edit_updatecellid_old as a double


% --- Executes during object creation, after setting all properties.
function edit_updatecellid_old_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_updatecellid_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_delete.
function pushbutton_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cellID = get(handles.edit_del_cellid,'String');
% ensure cell identifier is non empty
if isempty(cellID)
    warndlg('A cell identifier must be specified.','Cell identifier error');
    return;
end;

% design confirmation message base on whether ROI is specified or not
confirmationMessage = ['This operation is irreversible. Are you sure you want to delete all data pertaining to cell ''' cellID '''?'];
roi = get(handles.edit_del_roi,'String');
if ~isempty(roi)
    confirmationMessage = ['This operation is irreversible. Are you sure you want to delete all data pertaining to cell ''' cellID ''' and region of interest ''' roi '''?'];
end;

% open confirmation dialog box
choice = questdlg(confirmationMessage, ...
      'Delete operation', ...
      'Yes','No','No'); % last 'No' is the default value

if strcmp(choice,'Yes')
    % delete data 
    try
        pathToDB = get(handles.edit_pathToDB,'String');
        db = SQLiteDatabase(pathToDB);
        
        tables = getTables();
        for t = tables
            if ~isempty(roi)
                preparedStatement = ['DELETE FROM ' t{1} ' WHERE cellID=''' cellID ''' AND roi=''' roi ''''];
            else
                preparedStatement = ['DELETE FROM ' t{1} ' WHERE cellID=''' cellID ''''];
            end;
            db.prepareStatement(preparedStatement);
            db.query();
        end;
        
        db.close();
        msgbox('Deletion operation successfully completed.','Success');
    catch ME
%         display(ME.message);
        msgbox('An error occured while deleting the cell data. Operation aborted.', 'Cell deletion error','error');
    end;
end;


function edit_del_cellid_Callback(hObject, eventdata, handles)
% hObject    handle to edit_del_cellid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_del_cellid as text
%        str2double(get(hObject,'String')) returns contents of edit_del_cellid as a double


% --- Executes during object creation, after setting all properties.
function edit_del_cellid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_del_cellid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_del_roi_Callback(hObject, eventdata, handles)
% hObject    handle to edit_del_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_del_roi as text
%        str2double(get(hObject,'String')) returns contents of edit_del_roi as a double


% --- Executes during object creation, after setting all properties.
function edit_del_roi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_del_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_updateROI.
function pushbutton_updateROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_updateROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Step 1: Get inputs
cellID = get(handles.edit_updateroi_cellid,'String');
old_roi = get(handles.edit_updateroi_roi_old,'String');
new_roi = get(handles.edit_updateroi_roi_new,'String');

% ensure fields are non empty
if isempty(cellID)
    warndlg('A cell identifier must be specified.','Cell identifier error');
    return;
end;
if isempty(old_roi)
    warndlg('The current region of interest must be specified.','ROI error');
    return;
end;
if isempty(new_roi)
    warndlg('The current region of interest must be specified.','ROI error');
    return;
end;

% Step 2: Run UPDATE SQL commands
try
    pathToDB = get(handles.edit_pathToDB,'String');
    db = SQLiteDatabase(pathToDB);

    tables = getTables();
    for t = tables
        preparedStatement = ['UPDATE ' t{1} ' SET roi=''' new_roi ''' WHERE cellID=''' cellID ''' AND roi=''' old_roi ''''];
        display(preparedStatement);
        db.prepareStatement(preparedStatement);
        db.query();
    end;

    db.close();
    msgbox('Update operation successfully completed.','Success');
catch ME
%     display(ME.message);
    msgbox('An error occured while updating the cell data. Operation aborted.', 'Cell update error','error');
end;

function edit_updateroi_cellid_Callback(hObject, eventdata, handles)
% hObject    handle to edit_updateroi_cellid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_updateroi_cellid as text
%        str2double(get(hObject,'String')) returns contents of edit_updateroi_cellid as a double


% --- Executes during object creation, after setting all properties.
function edit_updateroi_cellid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_updateroi_cellid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_updateroi_roi_old_Callback(hObject, eventdata, handles)
% hObject    handle to edit_updateroi_roi_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_updateroi_roi_old as text
%        str2double(get(hObject,'String')) returns contents of edit_updateroi_roi_old as a double


% --- Executes during object creation, after setting all properties.
function edit_updateroi_roi_old_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_updateroi_roi_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_updateroi_roi_new_Callback(hObject, eventdata, handles)
% hObject    handle to edit_updateroi_roi_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_updateroi_roi_new as text
%        str2double(get(hObject,'String')) returns contents of edit_updateroi_roi_new as a double


% --- Executes during object creation, after setting all properties.
function edit_updateroi_roi_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_updateroi_roi_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_updatecellid_new_Callback(hObject, eventdata, handles)
% hObject    handle to edit_updatecellid_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_updatecellid_new as text
%        str2double(get(hObject,'String')) returns contents of edit_updatecellid_new as a double


% --- Executes during object creation, after setting all properties.
function edit_updatecellid_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_updatecellid_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_viewSQLCommands.
function pushbutton_viewSQLCommands_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_viewSQLCommands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winopen('doc/SQL_Commands.pdf')


function edit2_CreateFcn(hObject, eventdata, handles)
% bug fix



% ================================
% HELPER FUNCTIONS - BEGINS HERE
% ================================

function tables = getTables()
tables = {'deltagr','redAbsIntensity','greenAbsIntensity','photobleachingCorrection','statistics','parameters'};



% ================================
% HELPER FUNCTIONS - ENDS HERE
% ================================


% --- Executes on button press in pushbutton_reverse_cellids.
function pushbutton_reverse_cellids_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reverse_cellids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old_cellID = get(handles.edit_updatecellid_old,'String');
new_cellID = get(handles.edit_updatecellid_new,'String');
set(handles.edit_updatecellid_old,'String',new_cellID);
set(handles.edit_updatecellid_new,'String',old_cellID);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old_roi = get(handles.edit_updateroi_roi_old,'String');
new_roi = get(handles.edit_updateroi_roi_new,'String');
set(handles.edit_updateroi_roi_old,'String',new_roi);
set(handles.edit_updateroi_roi_new,'String',old_roi);


% --- Executes on button press in pushbutton_dbDriver.
function pushbutton_dbDriver_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dbDriver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile({'*.jar'},'Select database driver file');
if path ~= 0
    fullPath = strcat(path,filename);
    javaaddpath(fullPath);
    msgbox('Database driver file successfully updated.','Success');
end;

