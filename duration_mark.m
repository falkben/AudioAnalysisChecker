function varargout = duration_mark(varargin)
% DURATION_MARK MATLAB code for duration_mark.fig
%      DURATION_MARK, by itself, creates a new DURATION_MARK or raises the existing
%      singleton*.
%
%      H = DURATION_MARK returns the handle to a new DURATION_MARK or the handle to
%      the existing singleton*.
%
%      DURATION_MARK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DURATION_MARK.M with the given input arguments.
%
%      DURATION_MARK('Property','Value',...) creates a new DURATION_MARK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before duration_mark_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to duration_mark_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help duration_mark

% Last Modified by GUIDE v2.5 29-Oct-2015 15:56:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @duration_mark_OpeningFcn, ...
                   'gui_OutputFcn',  @duration_mark_OutputFcn, ...
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






function update(handles)







% --- Executes just before duration_mark is made visible.
function duration_mark_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to duration_mark (see VARARGIN)

% Choose default command line output for duration_mark
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes duration_mark wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = duration_mark_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function noise_freq_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_freq_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_freq_edit as a double


% --- Executes during object creation, after setting all properties.
function noise_freq_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function start_freq_edit_Callback(hObject, eventdata, handles)
% hObject    handle to start_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start_freq_edit as text
%        str2double(get(hObject,'String')) returns contents of start_freq_edit as a double


% --- Executes during object creation, after setting all properties.
function start_freq_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_freq_edit_Callback(hObject, eventdata, handles)
% hObject    handle to end_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of end_freq_edit as text
%        str2double(get(hObject,'String')) returns contents of end_freq_edit as a double


% --- Executes during object creation, after setting all properties.
function end_freq_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to end_freq_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nav_next_button.
function nav_next_button_Callback(hObject, eventdata, handles)
% hObject    handle to nav_next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nav_prev_button.
function nav_prev_button_Callback(hObject, eventdata, handles)
% hObject    handle to nav_prev_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nav_start_button.
function nav_start_button_Callback(hObject, eventdata, handles)
% hObject    handle to nav_start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nav_last_button.
function nav_last_button_Callback(hObject, eventdata, handles)
% hObject    handle to nav_last_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in del_button.
function del_button_Callback(hObject, eventdata, handles)
% hObject    handle to del_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mark_button.
function mark_button_Callback(hObject, eventdata, handles)
% hObject    handle to mark_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function filemenu_Callback(hObject, eventdata, handles)
% hObject    handle to filemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%determine the type of file (wu-jung's mic_data_detect or my _processed file)
if ispref('duration_mark_gui') && ispref('duration_mark_gui','micrecpath')
  pname=getpref('duration_mark_gui','micrecpath');
else
  pname='';
end
[fname,pname]=uigetfile({'*mic_data_detect.mat','Wu-Jung''s format';...
  '*_processed.mat','Ben''s format';...
  '*.mat','Mat files'},[],pname);
if isequal(fname,0)
  return;
end
fn=[pname,fname];
setpref('duration_mark_gui','micrecpath',pname)

handles.data.proc=load(fn);

noise_freq=str2double(get(handles.noise_freq_edit,'String'))*1e3;
end_freq=str2double(get(handles.end_freq_edit,'String'))*1e3;
start_freq=str2double(get(handles.start_freq_edit,'String'))*1e3;

%wu_jung_format
if strfind(fn,'mic_data_detect')
  A=strsplit(fn,'_detect');
  data_fname=A{1};
  handles.data.wav=load([data_fname '.mat']);
  
  Fs=handles.data.wav.fs;
  
  ch_marked=unique([handles.data.proc.call(:).channel_marked]);
  [handles.data.filt_wav_noise,handles.data.filt_wav_start,...
    handles.data.filt_wav_start,handles.data.noise_high,...
    handles.data.noise_low,handles.data.data_square,...
    handles.data.data_square_high,handles.data.data_square_diff_high,...
    handles.data.data_square_low,handles.data.data_square_diff_low]=...
    deal(cell(handles.data.proc.num_ch_in_file,1));
  
  %doing filtering once on each channel, as opposed to repeatedly doing it
  %for each call
  for cc=ch_marked
    waveform=handles.data.wav.sig(:,cc);
    
    %remove extraneous sounds below noise_freq
    [b,a] = butter(6,noise_freq/(Fs/2),'high');
    ddf=filtfilt(b,a,waveform); %freqz(b,a,SR/2,SR);
    data_square = smooth((ddf.^2),100);
    
    %for marking the end time 
    %we assume it's below 30k, removes some energy from echoes
    [low_b, low_a]=butter(6,end_freq/(Fs/2),'low'); 
    waveform_low=filtfilt(low_b,low_a,ddf); %using the previously high passed data
    data_square_low=smooth((waveform_low.^2),100);

    %for marking the start time
    %we assume it's above 30k, removes some energy from previous vocs
    [high_b, high_a]=butter(6,start_freq/(Fs/2),'high'); 
    waveform_high=filtfilt(high_b,high_a,waveform); %just high pass it once time
    data_square_high=smooth((waveform_high.^2),100);

    noise_length = .001*Fs; %length of data for estimating noise (1ms)

    data_square_diff_high = abs(smooth(diff(data_square_high),50));
    noise_diff_high=...
      median(max(reshape(data_square_diff_high(1:floor(length(data_square_diff_high)...
      /noise_length)*noise_length),noise_length,[])));
    data_square_diff_low = abs(smooth(diff(data_square_low),50));
    noise_diff_low=...
      median(max(reshape(data_square_diff_low(1:floor(length(data_square_diff_low)...
      /noise_length)*noise_length),noise_length,[])));
    
    handles.data.filt_wav_noise{cc}=ddf;
    handles.data.data_square{cc}=data_square;
    
    handles.data.filt_wav_start{cc}=waveform_high;
    handles.data.data_square_high{cc}=data_square_high;
    handles.data.data_square_diff_high{cc}=data_square_diff_high;
    
    handles.data.filt_wav_end{cc}=waveform_low;
    handles.data.data_square_low{cc}=data_square_low;
    handles.data.data_square_diff_low{cc}=data_square_diff_low;
    
    handles.data.noise_high{cc}=noise_diff_high;
    handles.data.noise_low{cc}=noise_diff_low;
  end
  %if durations haven't been marked already, run the automated duration
  %marking code
  if ~isfield(handles.data.proc.call,'auto_mark')
    used_vocs = find([1, diff([handles.data.proc.call(:).locs]./Fs)>10e-3]);
    
    for vv=used_vocs
      loc=handles.data.proc.call(vv).locs;
      cc=handles.data.proc.call(vv).channel_marked;
      
      [handles.data.proc.call(vv).call_onset,handles.data.proc.call(vv).call_offset]=...
        extract_dur_on_call(loc,Fs,...
        handles.data.filt_wav_noise{cc},handles.data.filt_wav_start{cc},...
        handles.data.filt_wav_end{cc},handles.data.noise_high{cc},...
        handles.data.noise_low{cc},handles.data.data_square{cc},...
        handles.data.data_square_high{cc},handles.data.data_square_diff_high{cc},...
        handles.data.data_square_low{cc},handles.data.data_square_diff_low{cc},0,0);
    end
  end
  
elseif strfind(fn,'mic_data_detect') %ben's format
  %load in different types of the raw audio files
end

%initialize

update(handles)



% --------------------------------------------------------------------
function savefile_Callback(hObject, eventdata, handles)
% hObject    handle to savefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save in the correct format

% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%test whether we need to save
%ask user to save if there are changes
%close the figure
close(handles.figure1)
