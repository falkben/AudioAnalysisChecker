function varargout = AudioAnalysisChecker(varargin)
% AUDIOANALYSISCHECKER M-file for AudioAnalysisChecker.fig
%      AUDIOANALYSISCHECKER, by itself, creates a new AUDIOANALYSISCHECKER or raises the existing
%      singleton*.
%
%      H = AUDIOANALYSISCHECKER returns the handle to a new AUDIOANALYSISCHECKER or the handle to
%      the existing singleton*.
%
%      AUDIOANALYSISCHECKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUDIOANALYSISCHECKER.M with the given input arguments.
%
%      AUDIOANALYSISCHECKER('Property','Value',...) creates a new AUDIOANALYSISCHECKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AudioAnalysisChecker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AudioAnalysisChecker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AudioAnalysisChecker

% Last Modified by GUIDE v2.5 24-Feb-2011 10:27:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AudioAnalysisChecker_OpeningFcn, ...
                   'gui_OutputFcn',  @AudioAnalysisChecker_OutputFcn, ...
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


% --- Executes just before AudioAnalysisChecker is made visible.
function AudioAnalysisChecker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AudioAnalysisChecker (see VARARGIN)

% Choose default command line output for AudioAnalysisChecker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AudioAnalysisChecker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AudioAnalysisChecker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in zoomin_button.
function zoomin_button_Callback(hObject, eventdata, handles)
% hObject    handle to zoomin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoomout_button.
function zoomout_button_Callback(hObject, eventdata, handles)
% hObject    handle to zoomout_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function sample_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sample_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sample_edit as text
%        str2double(get(hObject,'String')) returns contents of sample_edit as a double


% --- Executes during object creation, after setting all properties.
function sample_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sample_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prev_button.
function prev_button_Callback(hObject, eventdata, handles)
% hObject    handle to prev_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in delete_button.
function delete_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in load_audio_button.
function load_audio_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_audio_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname = uigetdir(handles.marked_voc_pname,'Select folder where raw audio files are located');
if isequal(pathname,0)
  return
else
  %determine which file it is from the marked filename
  files=dir([pathname '\' handles.marked_voc_fname(1:end-6) '.bin']);
  fnames={files.name};
  
  [fd,h,c] = OpenIoTechBinFile([pathname '\' fnames{1}]);
  [waveforms] = ReadChnlsFromFile(fd,h,c,10*250000,1);
  Fs = h.preFreq;
end

% --- Executes on button press in load_marked_vocs_button.
function load_marked_vocs_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_marked_vocs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*c*.mat', 'Select an analyzed batgadget file');
if isequal(filename,0)
  return
else
  load([pathname filename]);

  %sorting by the first column
  [NA INDX] = sort(DataArray(:,1),'ascend');
  DataArray = (DataArray(INDX,:));
  
  handles.DataArray = DataArray;
  handles.marked_voc_fname = filename;
  handles.marked_voc_pname = pathname;
  
  guidata(hObject, handles);
end



% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in new_button.
function new_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
