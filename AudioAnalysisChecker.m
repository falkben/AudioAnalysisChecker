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

% Last Modified by GUIDE v2.5 25-Feb-2011 18:42:10

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

set(handles.load_audio_button,'enable','off');
set(handles.lock_range_checkbox,'Value',0);
handles.samples=round(str2double(get(handles.sample_edit,'string')));

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
if handles.samples/2/handles.Fs < ...
    (handles.DataArray(handles.current_voc,3)-handles.DataArray(handles.current_voc,1))
  return
end
handles.samples=round(handles.samples/2);
set(handles.sample_edit,'string',num2str(handles.samples));
update(handles);
guidata(hObject, handles);

% --- Executes on button press in zoomout_button.
function zoomout_button_Callback(hObject, eventdata, handles)
% hObject    handle to zoomout_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.samples=round(handles.samples*2);
set(handles.sample_edit,'string',num2str(handles.samples));
update(handles);
guidata(hObject, handles);


function sample_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sample_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sample_edit as text
%        str2double(get(hObject,'String')) returns contents of sample_edit as a double
handles.samples=round(str2double(get(hObject,'String')));
update(handles);
guidata(hObject, handles);


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
handles.current_voc = handles.current_voc - 1;
if handles.current_voc < 1
  handles.current_voc = length(handles.DataArray(:,1));
end
update(handles);
guidata(hObject, handles);

% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.current_voc = handles.current_voc + 1;
if handles.current_voc > length(handles.DataArray(:,1))
  handles.current_voc = 1;
end
update(handles);
guidata(hObject, handles);

% --- Executes on button press in first_call_button.
function first_call_button_Callback(hObject, eventdata, handles)
% hObject    handle to first_call_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.current_voc = 1;
update(handles);
guidata(hObject, handles);

% --- Executes on button press in final_call_button.
function final_call_button_Callback(hObject, eventdata, handles)
% hObject    handle to final_call_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.current_voc = length(handles.DataArray(:,1));
update(handles);
guidata(hObject, handles);

function voc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to voc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voc_edit as text
%        str2double(get(hObject,'String')) returns contents of voc_edit as a double
handles.current_voc = str2double(get(hObject,'string'));
if handles.current_voc > length(handles.DataArray(:,1))
  handles.current_voc = length(handles.DataArray(:,1));
elseif handles.current_voc < 1
  handles.current_voc = 1;
end
update(handles);
guidata(hObject, handles);

% --- Executes on button press in load_marked_vocs_button.
function load_marked_vocs_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_marked_vocs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'marked_voc_pname') && ...
    exist(handles.marked_voc_pname,'dir')
  DEFAULTNAME=handles.marked_voc_pname;
elseif ispref('audioanalysischecker','marked_voc_pname')
  DEFAULTNAME=getpref('audioanalysischecker','marked_voc_pname');
else
  DEFAULTNAME='';
end

[filename, pathname] = uigetfile('*c*.mat',...
  'Select an analyzed batgadget file',DEFAULTNAME);
if isequal(filename,0)
  return
else
  load([pathname filename]);
  set(handles.marked_file_text,'string',filename,'tooltip',pathname);
  setpref('audioanalysischecker','marked_voc_pname',pathname);

  %sorting by the first column
  [NA INDX] = sort(DataArray(:,1),'ascend');
  DataArray = (DataArray(INDX,:));
  
  handles.DataArray = DataArray;
  handles.marked_voc_fname = filename;
  handles.marked_voc_pname = pathname;
  
  set(handles.load_audio_button,'enable','on');
  
  handles.current_voc=1;
  
  handles=load_audio(handles);
  
  guidata(hObject, handles);
end

% --- Executes on button press in load_audio_button.
function load_audio_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_audio_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=load_audio(handles);
guidata(hObject, handles);

function handles=load_audio(handles)
if isfield(handles,'audio_pname') && ...
    exist(handles.audio_pname,'dir')
  STARTDIR=handles.audio_pname;
elseif ispref('audioanalysischecker','audio_pname')
  STARTDIR=getpref('audioanalysischecker','audio_pname');
else
  STARTDIR=handles.marked_voc_pname;
end

pathname = uigetdir(STARTDIR,...
  'Select folder where raw audio files are located');
if isequal(pathname,0)
  return
else
  setpref('audioanalysischecker','audio_pname',pathname);
  
  %determine which file it is from the marked filename
  files=dir([pathname '\' handles.marked_voc_fname(1:end-6) '.bin']);
  fnames={files.name};
  set(handles.audio_file_text,'string',fnames{1},'tooltip',pathname);
  
  [fd,h,c] = OpenIoTechBinFile([pathname '\' fnames{1}]);
  [waveforms] = ReadChnlsFromFile(fd,h,c,10*250000,1);
  Fs = h.preFreq;
  
  channel=str2num(handles.marked_voc_fname(end-4));
  
  handles.waveform=waveforms{channel};
  handles.Fs=Fs;
  
  handles.audio_pname=pathname;
  
  update(handles);
end


% --- Executes on button press in delete_button.
function delete_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.DataArray(handles.current_voc,:)=[];
if handles.current_voc > length(handles.DataArray(:,1))
  handles.current_voc=length(handles.DataArray(:,1));
end
update(handles);
guidata(hObject, handles);


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
% --- Executes during object creation, after setting all properties.


function voc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function low_dB_edit_Callback(hObject, eventdata, handles)
% hObject    handle to low_dB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of low_dB_edit as text
%        str2double(get(hObject,'String')) returns contents of low_dB_edit as a double
update(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function low_dB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_dB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in lock_range_checkbox.
function lock_range_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to lock_range_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lock_range_checkbox
update(handles);
guidata(hObject,handles);



function top_dB_edit_Callback(hObject, eventdata, handles)
% hObject    handle to top_dB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of top_dB_edit as text
%        str2double(get(hObject,'String')) returns contents of top_dB_edit as a double
update(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function top_dB_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to top_dB_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function update(handles)

set(handles.voc_edit,'string',num2str(handles.current_voc));

axes(handles.wave_axes);cla;

Fs = handles.Fs;

voc_start_time = handles.DataArray(handles.current_voc,1);
voc_end_time = handles.DataArray(handles.current_voc,3);
voc_start_freq = handles.DataArray(handles.current_voc,2);
voc_end_freq = handles.DataArray(handles.current_voc,4);
dur=voc_end_time-voc_start_time;

start_sample = round((voc_start_time + 8)*Fs);
end_sample = round((voc_end_time + 8)*Fs);

buffer=round((handles.samples-(end_sample-start_sample+1))/2);
if buffer<=0
  buffer=100;
end
sample_range=start_sample-buffer:end_sample+buffer;
X=handles.waveform(sample_range)-mean(handles.waveform(sample_range));

t=(sample_range)./Fs-8;
plot(t,X,'k');
axis tight;
a=axis;
axis([a(1:2) -5 5]);

%displaying markings:
all_start_times=handles.DataArray(:,1);
all_end_times=handles.DataArray(:,3);
time_range=sample_range([1 end])./Fs-8;

start_indx=all_start_times>=time_range(1)...
  & all_start_times<=time_range(2);
end_indx=all_end_times>=time_range(1)...
  & all_end_times<=time_range(2);

disp_start_times=all_start_times(start_indx);
disp_end_times=all_end_times(end_indx);

hold on;
plot([voc_start_time voc_start_time],[-5 5],'color','r');
plot([voc_end_time voc_end_time],[-5 5],'color','r');
hold off;
text(disp_start_times,zeros(length(disp_start_times),1),...
  'X','HorizontalAlignment','center','color','c','fontsize',14,'fontweight','bold');
text(disp_end_times,zeros(length(disp_end_times),1),...
  'X','HorizontalAlignment','center','color','b','fontsize',14,'fontweight','bold');

%plotting spectrogram:
axes(handles.spect_axes);cla;
[S,F,T,P] = spectrogram(X,128,120,256,Fs,'yaxis');
imagesc(T,F,10*log10(abs(P))); axis tight;
set(gca,'YDir','normal','ytick',(0:25:125).*1e3,'yticklabel',...
  num2str((0:25:125)'),'xticklabel','');

%worrying about the clim for the spectrogram:
max_db_str=num2str(round(max(max(10*log10(P)))));
min_db_str=num2str(round(min(min(10*log10(P)))));
set(handles.max_dB_text,'string',max_db_str);
set(handles.min_dB_text,'string',min_db_str);
if get(handles.lock_range_checkbox,'value') == 1
  low_clim=str2double(get(handles.low_dB_edit,'string'));
  top_clim=str2double(get(handles.top_dB_edit,'string'));
  set(gca,'clim',[low_clim top_clim]);
else
  set(handles.top_dB_edit,'string',max_db_str);
  set(handles.low_dB_edit,'string',min_db_str);
end

hold on;
plot(disp_start_times-voc_start_time+buffer/Fs,handles.DataArray(start_indx,2),...
  'xc','markersize',15,'linewidth',2.5);
plot(disp_end_times-voc_start_time+buffer/Fs,handles.DataArray(end_indx,4),...
  'xb','markersize',15,'linewidth',2.5);
hold off;
