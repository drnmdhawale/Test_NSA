function varargout = NSA_APP_beta_v0_1(varargin)
% NSA_APP_BETA_V0_1 MATLAB code for NSA_APP_beta_v0_1.fig
%      NSA_APP_BETA_V0_1, by itself, creates a new NSA_APP_BETA_V0_1 or raises the existing
%      singleton*.
%
%      H = NSA_APP_BETA_V0_1 returns the handle to a new NSA_APP_BETA_V0_1 or the handle to
%      the existing singleton*.
%
%      NSA_APP_BETA_V0_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NSA_APP_BETA_V0_1.M with the given input arguments.
%
%      NSA_APP_BETA_V0_1('Property','Value',...) creates a new NSA_APP_BETA_V0_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NSA_APP_beta_v0_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NSA_APP_beta_v0_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NSA_APP_beta_v0_1

% Last Modified by GUIDE v2.5 08-May-2016 16:44:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NSA_APP_beta_v0_1_OpeningFcn, ...
                   'gui_OutputFcn',  @NSA_APP_beta_v0_1_OutputFcn, ...
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

% --- Executes just before NSA_APP_beta_v0_1 is made visible.
function NSA_APP_beta_v0_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NSA_APP_beta_v0_1 (see VARARGIN)

% Choose default command line output for NSA_APP_beta_v0_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NSA_APP_beta_v0_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = NSA_APP_beta_v0_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
try
set(handles.text7,'String','BUSY'); pause(0.000001)
DIALOG_NAME = 'Select a PSS Datafile';
DEFAULT_FILE = 'Example_Data_File.txt';
FLT = '*.txt';
FILENAME = uigetfile (FLT, DIALOG_NAME, DEFAULT_FILE);
if FILENAME == 0;
FILENAME = 'Example_Data_File.txt';
end
    if get(handles.checkbox2,'Value')==1
        cla; pause(0.000001)
        NSA_DATA_import_v1(FILENAME)
        msgbox('Data Select Operation Completed','Success');
        set(handles.text7,'String','Waiting');
   else
       msgbox('Please review the checkbox', 'Error','error');
       set(handles.text7,'String','Waiting');
   end
catch
  set(handles.text7,'String','Waiting');
  msgbox('Operation Cannot Be Completed','error');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
try
 set(handles.text7,'String','BUSY'); pause(0.000001)
 if get(handles.checkbox2,'Value')==1
      cla; pause(0.000001)
      NSA_v12(handles)
      set(handles.text7,'String','Waiting');
 else
     msgbox('Please review the checkbox', 'Error','error');
     set(handles.text7,'String','Waiting');
 end
catch
  msgbox('Please First Press Button "Select Data/File" ', 'Error','error');
  set(handles.text7,'String','Waiting');
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
try
 set(handles.text7,'String','BUSY'); pause(0.000001)
 if get(handles.checkbox2,'Value')==1
      NSA_DATA_export_v1
      set(handles.text7,'String','Waiting');
 else
     msgbox('Please review the checkbox', 'Error','error');
     set(handles.text7,'String','Waiting');
 end
catch
  msgbox('First - Press Button "Run Algorithm" ', 'Error','error');
  set(handles.text7,'String','Waiting');
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
try
 set(handles.text7,'String','BUSY'); pause(0.000001)
 if get(handles.checkbox2,'Value')==1
      %cla; pause(0.000001)
      GET_ZONE_COI_v12(handles)
      set(handles.text7,'String','Waiting');
 else
     msgbox('Please review the checkbox', 'Error','error');
     set(handles.text7,'String','Waiting')
 end
catch
  msgbox('First - Press Button "Save Data" ', 'Error','error');
  set(handles.text7,'String','Waiting')
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
