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

% Last Modified by GUIDE v2.5 29-Nov-2012 15:19:48

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


function AudioAnalysisChecker_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

handles = initialize(handles);

% Update handles structure
guidata(hObject, handles);


function varargout = AudioAnalysisChecker_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function handles = initialize(handles)
set(handles.lock_range_checkbox,'Value',0);
handles.samples=round(str2double(get(handles.sample_edit,'string')));
axes(handles.wave_axes);cla;
axes(handles.spect_axes);cla;
handles.internal = [];


function handles=load_audio(handles)
if isfield(handles.internal,'audio_pname') && ...
    exist(handles.internal.audio_pname,'dir')
  pathname=handles.internal.audio_pname;
elseif ispref('audioanalysischecker','audio_pname')
  pathname=getpref('audioanalysischecker','audio_pname');
else
  STARTDIR='';
  pathname = uigetdir(STARTDIR,...
    'Select folder where raw audio files are located');
  if isequal(pathname,0)
    return
  end
  setpref('audioanalysischecker','audio_pname',pathname);
end

[filename pathname]=uigetfile({'*.mat;*.bin'},...
  'Load audio file',[pathname '\']);
if isequal(filename,0)
  return
end

handles.internal.audio_pname=pathname;
handles.internal.audio_fname=filename;

handles = load_marked_vocs(handles);

if isempty(handles.internal.DataArray)
  return;
end

%determine which file it is from the marked filename
if strcmp(filename(end-2:end),'mat') %loading from nidaq_matlab_tools
  warning('off','MATLAB:loadobj');
  audio=open([pathname '\' filename]);
  warning('on','MATLAB:loadobj');
  waveforms = audio.data;
  Fs = audio.SR;
elseif strcmp(filename(end-2:end),'bin') %loading from wavebook
  [fd,h,c] = OpenIoTechBinFile([pathname '\' filename]);
  [waveforms] = ReadChnlsFromFile(fd,h,c,10*250000,1);
  Fs = h.preFreq;
end

figure(1); clf;
for k=1:size(waveforms,2)
  subplot(size(waveforms,2),1,k)
  plot(waveforms(1:10:end,k));
  title(['Channel: ' num2str(k)]);
end
options.WindowStyle='normal';
channel = inputdlg('Which channel?','',1,{''},options);
close(1);

if isempty(channel)
  return;
end

handles.internal.waveform=waveforms(:,str2double(channel));
handles.internal.Fs=Fs;

handles.internal.current_voc=1;

set(gcf,'Name',['AudioAnalysisChecker: ' handles.internal.audio_fname]);

update(handles);


function handles = load_marked_vocs(handles)
if isfield(handles.internal,'marked_voc_pname') && ...
    exist(handles.internal.marked_voc_pname,'dir')
  DEFAULTNAME=handles.internal.marked_voc_pname;
elseif ispref('audioanalysischecker','marked_voc_pname')
  DEFAULTNAME=getpref('audioanalysischecker','marked_voc_pname');
else
  DEFAULTNAME='';
end

if ~exist([DEFAULTNAME 'sound_data.mat'],'file')
  [~, DEFAULTNAME] = uigetfile('sound_data.mat',...
    'Select processed sound data (sound_data.mat)',DEFAULTNAME);
  if isequal(DEFAULTNAME,0)
    return
  end
end

load([DEFAULTNAME 'sound_data.mat']);
setpref('audioanalysischecker','marked_voc_pname',DEFAULTNAME);

all_trialcodes={extracted_sound_data.trialcode};
trialcode = determine_vicon_trialcode([handles.internal.audio_pname handles.internal.audio_fname]);
indx=find(strcmp(all_trialcodes,trialcode));

if isempty(indx)
  handles.internal.DataArray=[];
  handles.internal.sound_data_indx=[];
  disp('Vicon trial absent.')
  return;
end
handles.internal.sound_data_indx = indx;
vicon_trigger_offset = (8*300 - length(extracted_sound_data(indx).centroid) + 1)/300;
handles.internal.net_crossings = extracted_sound_data(indx).net_crossings./300 - 8 + vicon_trigger_offset;
handles.internal.DataArray = extracted_sound_data(indx).voc_t + vicon_trigger_offset;




function update(handles)
set(handles.voc_edit,'string',num2str(handles.internal.current_voc));

axes(handles.wave_axes);cla;

Fs = handles.internal.Fs;

voc_time = handles.internal.DataArray(handles.internal.current_voc);

voc_sample = round((voc_time + 8)*Fs);

buffer=handles.samples/2;
sample_range=max(1,voc_sample-buffer):min(voc_sample+buffer,length(handles.internal.waveform));
X=handles.internal.waveform(sample_range);

t=(sample_range)./Fs-8;
plot(t(1:3:end),X(1:3:end),'k');
axis tight;
a=axis;
axis([a(1:2) -10 10]);

%displaying markings:
all_voc_times=handles.internal.DataArray;
time_range=t([1 end]);

voc_t_indx=all_voc_times>=time_range(1)...
  & all_voc_times<=time_range(2);

disp_voc_times=all_voc_times(voc_t_indx);
voc_nums=find(voc_t_indx);
hold on;
for k=1:length(disp_voc_times)
  plot([disp_voc_times(k) disp_voc_times(k)],[-10 10],'color','r');
end
text(disp_voc_times,-8*ones(length(voc_nums),1),num2str(voc_nums),...
  'horizontalalignment','center');
plot([voc_time voc_time],[-10 10],'color',[.6 .6 1]);
hold off;
text(disp_voc_times,zeros(length(disp_voc_times),1),...
  'X','HorizontalAlignment','center','color','c','fontsize',14,'fontweight','bold');

%displaying net crossings
hold on;
net_crossings = handles.internal.net_crossings;
plot([net_crossings(1) net_crossings(1)],[-5 5],'b','linewidth',2);
plot([net_crossings(2) net_crossings(2)],[-5 5],'b','linewidth',2);
hold off;

%plotting spectrogram:
axes(handles.spect_axes);cla;
if get(handles.plot_spectrogram_checkbox,'value')
  [S,F,T,P] = spectrogram(X,256,250,512,Fs,'yaxis');
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
  colormap('hot')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in zoomin_button.
function zoomin_button_Callback(hObject, eventdata, handles)
handles.samples=round(handles.samples/2);
set(handles.sample_edit,'string',num2str(handles.samples));
update(handles);
guidata(hObject, handles);

% --- Executes on button press in zoomout_button.
function zoomout_button_Callback(hObject, eventdata, handles)
handles.samples=round(handles.samples*2);
set(handles.sample_edit,'string',num2str(handles.samples));
update(handles);
guidata(hObject, handles);


function sample_edit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of sample_edit as text
%        str2double(get(hObject,'String')) returns contents of sample_edit as a double
handles.samples=round(str2double(get(hObject,'String')));
update(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sample_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prev_button.
function prev_button_Callback(hObject, eventdata, handles)
handles.internal.current_voc = handles.internal.current_voc - 1;
if handles.internal.current_voc < 1
  handles.internal.current_voc = 1;
end
update(handles);
guidata(hObject, handles);

% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
handles.internal.current_voc = handles.internal.current_voc + 1;
if handles.internal.current_voc > length(handles.internal.DataArray)
  handles.internal.current_voc = length(handles.internal.DataArray);
end
update(handles);
guidata(hObject, handles);

% --- Executes on button press in first_call_button.
function first_call_button_Callback(hObject, eventdata, handles)
handles.internal.current_voc = 1;
update(handles);
guidata(hObject, handles);

% --- Executes on button press in final_call_button.
function final_call_button_Callback(hObject, eventdata, handles)
handles.internal.current_voc = length(handles.internal.DataArray);
update(handles);
guidata(hObject, handles);

function voc_edit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of voc_edit as text
%        str2double(get(hObject,'String')) returns contents of voc_edit as a double
handles.internal.current_voc = str2double(get(hObject,'string'));
if handles.internal.current_voc > length(handles.internal.DataArray)
  handles.internal.current_voc = length(handles.internal.DataArray);
elseif handles.internal.current_voc < 1
  handles.internal.current_voc = 1;
end
update(handles);
guidata(hObject, handles);

% --- Executes on button press in delete_button.
function delete_button_Callback(hObject, eventdata, handles)
handles.internal.DataArray(handles.internal.current_voc)=[];
if handles.internal.current_voc > length(handles.internal.DataArray)
  handles.internal.current_voc=length(handles.internal.DataArray);
end
guidata(hObject, handles);
update(handles);


% --- Executes on button press in new_button.
function new_button_Callback(hObject, eventdata, handles)
axes(handles.wave_axes);
[x,y] = ginput(1);
handles.internal.DataArray(end+1)=x;
handles.internal.DataArray = sort(handles.internal.DataArray);
guidata(hObject, handles);
update(handles);


function voc_edit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function low_dB_edit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of low_dB_edit as text
%        str2double(get(hObject,'String')) returns contents of low_dB_edit as a double
update(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function low_dB_edit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in lock_range_checkbox.
function lock_range_checkbox_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of lock_range_checkbox
update(handles);
guidata(hObject,handles);



function top_dB_edit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of top_dB_edit as text
%        str2double(get(hObject,'String')) returns contents of top_dB_edit as a double
update(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function top_dB_edit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function wave_axes_ButtonDownFcn(hObject, eventdata, handles)
disp('button_pressed')


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function open_menu_Callback(hObject, eventdata, handles)
handles=initialize(handles);
handles=load_audio(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function save_menu_Callback(hObject, eventdata, handles)
if isfield(handles.internal,'marked_voc_pname') && ...
    exist(handles.internal.marked_voc_pname,'dir')
  DEFAULTNAME=handles.internal.marked_voc_pname;
elseif ispref('audioanalysischecker','marked_voc_pname')
  DEFAULTNAME=getpref('audioanalysischecker','marked_voc_pname');
else
  DEFAULTNAME='';
end

if ~exist([DEFAULTNAME 'sound_data.mat'],'file')
  [~, DEFAULTNAME] = uigetfile('sound_data.mat',...
    'Select processed sound data (sound_data.mat)',DEFAULTNAME);
  if isequal(DEFAULTNAME,0)
    return
  end
end

load([DEFAULTNAME 'sound_data.mat']);
setpref('audioanalysischecker','marked_voc_pname',DEFAULTNAME);

indx=handles.internal.sound_data_indx;
vicon_trigger_offset = (8*300 - length(extracted_sound_data(indx).centroid) + 1)/300;


if strcmp(extracted_sound_data(indx).trialcode,determine_vicon_trialcode([handles.internal.audio_pname handles.internal.audio_fname]))
  extracted_sound_data(indx).voc_t=handles.internal.DataArray - vicon_trigger_offset;
  extracted_sound_data(indx).voc_checked=1;
  extracted_sound_data(indx).voc_checked_time=datevec(now);

  save([DEFAULTNAME 'sound_data.mat'],'extracted_sound_data');
  disp(['Saved ' handles.internal.audio_fname ' at ' datestr(now,'HH:MM PM')]);
else
  disp('Error in saving');
end

% --------------------------------------------------------------------
function close_menu_Callback(hObject, eventdata, handles)
delete(handles.figure1);

function plot_spectrogram_checkbox_Callback(hObject, eventdata, handles)
update(handles);


function previous_10_button_Callback(hObject, eventdata, handles)
handles.internal.current_voc = handles.internal.current_voc - 10;
if handles.internal.current_voc < 1
  handles.internal.current_voc = 1;
end
update(handles);
guidata(hObject, handles);

function next_10_button_Callback(hObject, eventdata, handles)
handles.internal.current_voc = handles.internal.current_voc + 10;
if handles.internal.current_voc > length(handles.internal.DataArray)
  handles.internal.current_voc = length(handles.internal.DataArray);
end
update(handles);
guidata(hObject, handles);
