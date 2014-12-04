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

% Last Modified by GUIDE v2.5 03-Dec-2014 14:10:39

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
handles.samples=round(str2double(get(handles.sample_edit,'string')));
axes(handles.wave_axes);cla;
axes(handles.spect_axes);cla;
axes(handles.PI_axes);cla;
handles.internal = [];
set(handles.processed_checkbox,'value',0);
set(handles.save_menu,'enable','off');
set(handles.save_open_next,'enable','off');
set(handles.wave_axes_switch,'enable','off');
set_sound_data_path(handles);

function set_sound_data_path(handles)
if ispref('audioanalysischecker','sound_data_pname')
  set(handles.sound_data_path_edit,'String',getpref('audioanalysischecker','sound_data_pname'))
  set(handles.sound_data_path_edit,'TooltipString',getpref('audioanalysischecker','sound_data_pname'))
  set(handles.clear_sound_data_path_pushbutton,'Enable','On');
end

function handles=load_file(handles,pathname,filename)
if nargin == 1
  if isfield(handles.internal,'audio_pname') && ...
      exist(handles.internal.audio_pname,'dir')
    pathname=handles.internal.audio_pname;
  elseif ispref('audioanalysischecker','audio_pname') && ...
      exist(getpref('audioanalysischecker','audio_pname'),'dir')
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
  
  [filename, pathname]=uigetfile({'*.mat;*.bin'},...
    'Load audio file',[pathname '\']);
  if isequal(filename,0)
    return
  end
end
setpref('audioanalysischecker','audio_pname',pathname);

handles.internal.audio_pname=pathname;
handles.internal.audio_fname=filename;
handles=load_waveform(handles);

handles = load_marked_vocs(handles);
if ~isfield(handles.internal,'DataArray') ||...
    ~isempty(find(isnan(handles.internal.DataArray),1))
  return;
end

if ~isfield(handles.internal,'ch')
  disp('no channel specified... assuming channel 1');
  handles.internal.ch=1;
end
handles.internal.waveform=handles.internal.waveforms(:,handles.internal.ch);

if ~isempty(handles.internal.DataArray)
  handles.internal.current_voc=1;
else
  handles.internal.current_voc=[];
end
display_text = ['Opened file: ' handles.internal.audio_fname];
disp(display_text)
add_text(handles,display_text);

set(gcf,'Name',['AudioAnalysisChecker: ' handles.internal.audio_fname]);
set(handles.save_open_next,'enable','on');
set(handles.save_menu,'enable','on');
set(handles.wave_axes_switch,'enable','on');
update(handles);
guidata(gcbo, handles);

function handles=load_waveform(handles)
pathname=handles.internal.audio_pname;
filename=handles.internal.audio_fname;

[waveforms,Fs,length_t,waveform_y_range]=load_audio(pathname,filename);

handles.internal.waveforms=waveforms;
handles.internal.Fs=Fs;
handles.internal.length_t = length_t;
handles.internal.waveform_y_range = waveform_y_range;

function handles = load_marked_vocs(handles)
[fn,pn] = gen_processed_fname(handles);
if exist([pn fn],'file')
  load([pn fn]);
  set(handles.processed_checkbox,'value',1);
  if ~isfield(trial_data,'ch')
    trial_data.ch=1;
  end
  display_text = ['Processed file found. Channels processed: ' num2str(trial_data.ch')];
  disp(display_text)
  add_text(handles,display_text);
  
  handles.internal.ch=determine_channel(handles);
  ii=ismember(trial_data.ch,handles.internal.ch);
  if find(ii,1)
    if ~iscell(trial_data.voc_t)
      handles.internal.DataArray = trial_data.voc_t;
    else
      handles.internal.DataArray = trial_data.voc_t{ii};
    end
    handles.internal.extracted_sound_data = trial_data;
    
    if isfield(trial_data,'net_crossings')
      handles.internal.net_crossings = (trial_data.net_crossings-length(trial_data.centroid))/300;
    end
  else
    handles = load_sound_data(handles);
    if isempty(handles.internal.DataArray)
      return;
    end
  end
else
  handles = load_sound_data(handles);
  if ~isempty(find(isnan(handles.internal.DataArray),1))
    return;
  end
end


function handles = load_sound_data(handles)
if ispref('audioanalysischecker','sound_data_pname')
  DEFAULTNAME=getpref('audioanalysischecker','sound_data_pname');
else
  DEFAULTNAME='';
end

if exist([DEFAULTNAME 'sound_data.mat'],'file')
  handles = load_sound_data_mat(handles,DEFAULTNAME);
else
  [~, sound_data_pname] = uigetfile('sound_data.mat',...
    'Select sound_data.mat (pre-processed data for multiple files), cancel if not preprocessed',DEFAULTNAME);
  if ~isequal(sound_data_pname,0)
    setpref('audioanalysischecker','sound_data_pname',sound_data_pname);
    set_sound_data_path(handles);
    handles = load_sound_data_mat(handles,sound_data_pname);
  else
    handles=deal_with_no_sound_data(handles);
  end
end

function ch=determine_channel(handles)
ch=0;
options.WindowStyle='normal';
channel = inputdlg(['Which channel? (there are ' ...
  num2str(size(handles.internal.waveforms,2)) ')' char(10) 'last channel might be trigger...'],'',1,{''},options);
if ~isempty(channel)
  ch=str2double(channel);
end

%loads pre processed data from multiple trials and extracts the current
%trial data
function handles = load_sound_data_mat(handles,sound_data_pname)
handles.sound_data_file = [sound_data_pname 'sound_data.mat'];
%compare checksum to checksum in handles if it exists
%saves time loading sound_data.mat if you're doing multiple trials
[status, result] = system(['md5\md5.exe ' '"' handles.sound_data_file '"']);
if status == 0
  space_indx=strfind(result,' ');
  checksum = result(1:space_indx(1));
end
if isfield(handles,'sound_data') && strcmp(checksum,handles.sound_data_checksum)
  extracted_sound_data = handles.sound_data;
else
  load(handles.sound_data_file);
  handles.sound_data = extracted_sound_data;
  handles.sound_data_checksum = checksum;
end

all_trialcodes={extracted_sound_data.trialcode};
trialcode = determine_video_trialcode([handles.internal.audio_pname ...
  handles.internal.audio_fname]);
if trialcode==0
  display_text = ['video trial not found: ' handles.internal.audio_fname];
  disp(display_text)
  add_text(handles,display_text);
  trialcode=handles.internal.audio_fname(1:end-4);
end
indx=find(strcmp(all_trialcodes,trialcode));

if length(indx)>1
  if ~isfield(handles.internal,'ch')
    ch=determine_channel(handles);
  else
    ch=handles.internal.ch;
  end
  if isequal(ch,0)
    indx=[];
  end
  [~,ia]=intersect([extracted_sound_data(indx).ch],ch);
  indx=indx(ia);
end

if isempty(indx)
  handles.internal.DataArray=nan;
  display_text = ['trial: ' trialcode ' absent.'];
  disp(display_text)
  add_text(handles,display_text);
  [handles,loaded]=deal_with_no_sound_data(handles);
  if ~loaded
    return;
  end
  indx=length(handles.sound_data);
  extracted_sound_data=handles.sound_data;
end

if isfield(extracted_sound_data(indx),'net_crossings')
  handles.internal.net_crossings = (extracted_sound_data(indx).net_crossings-length(extracted_sound_data(indx).centroid))/300;
end

handles.internal.DataArray = extracted_sound_data(indx).voc_t;
handles.internal.extracted_sound_data = extracted_sound_data(indx);
if isfield(handles.internal.extracted_sound_data,'ch')
  handles.internal.ch = handles.internal.extracted_sound_data.ch;
end
handles.internal.changed=0;


function [handles,loaded]=deal_with_no_sound_data(handles)
loaded=0;
% dialog box to ask if you want to generate processed file
button = questdlg('Generate pre-processed data?','Preprocess sound data?');
switch button
  case 'Cancel'
    return
  case 'Yes'
    [trt_data,handles]=preprocess_sound_data(handles);
    if isempty(trt_data)
      return;
    end
    
    handles.sound_data(end+1)=orderfields(trt_data,handles.sound_data);
    handles.sound_data_checksum=[];
    loaded=1;
  case 'No'
    ch=decide_channel(handles.internal.waveforms);
    if isempty(ch)
      return;
    end
    %load the audio data and display it
    trt_data=[];
    trt_data.voc_t=[];
    trt_data.trialcode=handles.internal.audio_fname(1 : end -4);
    trt_data.bat='';
    trt_data.voc_checked=[];
    trt_data.voc_checked_time=[];
    if isfield(handles.sound_data,'ch')
      trt_data.ch = ch;
    end
    if isfield(handles.sound_data,'d3_start')
      trt_data.d3_start =[];
      trt_data.d3_end=[];
    end
    if isfield(handles.sound_data,'net_crossings')
      trt_data.net_crossings=[];
      trt_data.centroid=[];
      trt_data.sm_centroid=[];
      trt_data.speed=[];
      trt_data.treatment_type='';
    end
    
    handles.sound_data(end+1)=orderfields(trt_data,handles.sound_data);
    handles.sound_data_checksum=[];
    loaded=1;
end

function ch=decide_channel(data)
if size(data,2)>1
  figure(1); clf; set(gcf,'position',[8 50 400 700])
  for ch=1:size(data,2)
    hh(ch)=subplot(size(data,2),1,ch);
    plot(data(1:3:end,ch));
    axis tight;
    title(['channel ' num2str(ch)])
  end
  linkaxes(hh);
  
  %which channel
  options.WindowStyle='normal';
  ch = inputdlg('Channel?','',1,{''},options);
  if isempty(ch)
    return;
  else
    ch=str2double(ch{1});
  end
  close(1);
end

function [trt_data,handles]=preprocess_sound_data(handles)
%preprocess sound data
trt_data=[];
data=handles.internal.waveforms;
Fs=handles.internal.Fs;
length_t=handles.internal.length_t;
fname=handles.internal.audio_fname;
trialcode = fname(1 : end -4);

ch=decide_channel(data);
if isempty(ch)
  return;
end

locs=extract_vocs(data(:,ch),Fs,2,.005,2,0);

trt_data.voc_t=locs./Fs - length_t;
trt_data.trialcode=trialcode;
trt_data.bat='';
trt_data.voc_checked=[];
trt_data.voc_checked_time=[];
if isfield(handles.sound_data,'ch')
  trt_data.ch = ch;
else
  handles.internal.ch=ch;
end
if isfield(handles.sound_data,'d3_start')
  trt_data.d3_start =[];
  trt_data.d3_end=[];
end
if isfield(handles.sound_data,'net_crossings')
  trt_data.net_crossings=[];
  trt_data.centroid=[];
  trt_data.sm_centroid=[];
  trt_data.speed=[];
  trt_data.treatment_type='';
end


function add_text(handles,text)
current_text = get(handles.text_output_listbox,'String');
new_text = [current_text; {text}];
set(handles.text_output_listbox,'String',new_text);
addpath('findjobj');
jhEdit = findjobj(handles.text_output_listbox);
jEdit = jhEdit.getComponent(0).getComponent(0);
jEdit.setCaretPosition(jEdit.getDocument.getLength);


function update(handles)
set(handles.voc_edit,'string',num2str(handles.internal.current_voc));

Fs = handles.internal.Fs;
voc_time = handles.internal.DataArray(handles.internal.current_voc);
voc_sample = round((voc_time + handles.internal.length_t)*Fs);

%plot_wave_axes
axes(handles.wave_axes);cla;

contents = cellstr(get(handles.wave_axes_switch,'String')); %returns wave_axes_switch contents as cell array
selected_wave_axes = contents{get(handles.wave_axes_switch,'Value')}; %returns selected item from wave_axes_switch

buffer=round(handles.samples/2);
sample_range=max(1,voc_sample-buffer):min(voc_sample+buffer,length(handles.internal.waveform));
if isempty(sample_range)
  sample_range=1:handles.samples;
end
X=handles.internal.waveform(sample_range);
t=(sample_range)./Fs-handles.internal.length_t;

if strcmp(selected_wave_axes,'Waveform')
  plot(t,X,'k');
  axis tight;
  a=axis;
  axis([a(1:2) handles.internal.waveform_y_range]);
elseif strcmp(selected_wave_axes,'Smoothed, rectified')
  %from extract_vocs.m (in net_hole_climb_collab/analysis_ben/)
  if ~isfield(handles.internal,'filter_prop')
    [handles.internal.filter_prop.b handles.internal.filter_prop.a] = ...
      butter(6,30e3/(Fs/2),'high');
    guidata(gcbo,handles);
  end
  b = handles.internal.filter_prop.b;
  a = handles.internal.filter_prop.a;
  ddf=filtfilt(b,a,X);
  data_square=smooth(ddf.^2,200);
  plot(t,data_square,'k','linewidth',2);
  axis tight;
end

a=axis; %for plotting markings, net crosses

%displaying markings:
all_voc_times=handles.internal.DataArray;
time_range=t([1 end]);

voc_t_indx=all_voc_times>=time_range(1)...
  & all_voc_times<=time_range(2);

disp_voc_times=all_voc_times(voc_t_indx);
voc_nums=find(voc_t_indx);
if ~isempty(disp_voc_times)
  hold on;
  plot([disp_voc_times disp_voc_times]',[a(3) a(4)],'color','r');
  text(disp_voc_times,(a(4)-.1*(a(4)-a(3)))*ones(length(voc_nums),1),num2str(voc_nums),...
    'horizontalalignment','center');
  plot([voc_time voc_time],[a(3) a(4)],'color',[.6 .6 1]);
  hold off;
end
% text(disp_voc_times,zeros(length(disp_voc_times),1),...
%   'X','HorizontalAlignment','center','color','c','fontsize',14,'fontweight','bold');

if isfield(handles.internal.extracted_sound_data,'d3_start') && ...
    ~isempty(handles.internal.extracted_sound_data.d3_start)
  d3_start = handles.internal.extracted_sound_data.d3_start;
  d3_end = handles.internal.extracted_sound_data.d3_end;
  if a(1)<d3_start && a(2) > d3_start
    hold on;
    plot([d3_start d3_start],a(3:4)./2,'g','linewidth',2);
    hold off;
  end
  if a(1)<d3_end && a(2) > d3_end
    hold on;
    plot([d3_end d3_end],a(3:4)./2,'g','linewidth',2);
    hold off;
  end
end

%displaying net crossings if visible
if isfield(handles.internal,'net_crossings') && ~isempty(handles.internal.net_crossings)
  hold on;
  net_crossings = handles.internal.net_crossings;
  
  if a(1)<net_crossings(1)
    plot([net_crossings(1) net_crossings(1)],[a(3) a(4)]./2,'b','linewidth',2);
  end
  if a(2)>net_crossings(2)
    plot([net_crossings(2) net_crossings(2)],[a(3) a(4)]./2,'b','linewidth',2);
  end
  
  %plotting start and stop of the processed file if visible
  if a(1)<net_crossings(1)-.5
    plot((net_crossings(1)-.5)*ones(2,1),[a(3) a(4)]./2,'m','linewidth',2);
  end
  if a(2)>net_crossings(2)+1
    plot((net_crossings(2)+1)*ones(2,1),[a(3) a(4)]./2,'g','linewidth',2);
  end
  hold off;
end

%plotting spectrogram:
axes(handles.spect_axes);cla;
if get(handles.plot_spectrogram_checkbox,'value')
  %we do the spectrogram over all the frequencies and then just set the axis limit to 125khz
%   [~,F,T,P] = spectrogram(X,256,230,linspace(0,125e3,60),Fs); %slower alg.
  [~,F,T,P] = spectrogram(X,256,230,[],Fs);
  
  %worrying about the clim for the spectrogram:
  max_db_str=num2str(round(max(max(10*log10(P)))));
  min_db_str=num2str(round(min(min(10*log10(P)))));
  set(handles.max_dB_text,'string',max_db_str);
  set(handles.min_dB_text,'string',min_db_str);
  if get(handles.lock_range_checkbox,'value') == 1
    low_clim=str2double(get(handles.low_dB_edit,'string'));
    top_clim=str2double(get(handles.top_dB_edit,'string'));
%     set(gca,'clim',[low_clim top_clim]);
  else
    set(handles.top_dB_edit,'string',max_db_str);
    set(handles.low_dB_edit,'string',min_db_str);
  end
  
  imagesc(T,F,10*log10(abs(P)),[low_clim top_clim]);
  axis tight;
  a=axis;
  axis([a(1:2) 0 125e3]);
  set(gca,'YDir','normal','ytick',(0:25:125).*1e3,'yticklabel',...
    num2str((0:25:125)'),'xticklabel','');
  colormap('hot')
end


%plotting PI:
axes(handles.PI_axes);cla;
if get(handles.plot_PI_checkbox,'value')
  plot_PI(handles);
end


function plot_PI(handles)
PI=diff(handles.internal.DataArray)*1e3;
t=handles.internal.DataArray(2:end);

plot(t,PI,'.-k');
axis tight;
a=axis;
axis([a(1:2) 0 a(4)]);
hold on;
if handles.internal.current_voc > 1
  plot(t(handles.internal.current_voc-1),PI(handles.internal.current_voc-1),...
    'o','linewidth',2,'color',[.6 .6 1]);
end
if isfield(handles.internal,'net_crossings') && ~isempty(handles.internal.net_crossings)
  for k=1:length(handles.internal.net_crossings)
    plot(handles.internal.net_crossings(k)*ones(2,1),[0 a(4)],...
      'b','linewidth',2);
  end
  plot((handles.internal.net_crossings(1)-.5)*ones(2,1),[0 a(4)],'m','linewidth',2);
  plot((handles.internal.net_crossings(2)+1)*ones(2,1),[0 a(4)],'g','linewidth',2);
end

if isfield(handles.internal.extracted_sound_data,'d3_start') && ...
    ~isempty(handles.internal.extracted_sound_data.d3_start)
  d3_start = handles.internal.extracted_sound_data.d3_start;
  d3_end = handles.internal.extracted_sound_data.d3_end;
  plot([d3_start d3_start],a(3:4),'g','linewidth',2);
  plot([d3_end d3_end],a(3:4),'g','linewidth',2);
end

hold off; axis tight;
title('Pulse Interval (ms)','fontsize',8)


function [fn pn] = gen_processed_fname(handles)
fn=[handles.internal.audio_fname(1:end-4) '_processed.mat'];
pn=handles.internal.audio_pname;

function static = load_static(handles)
static = [];
if ispref('audio_analysis_checker','static_trials')
  fullpath = getpref('audio_analysis_checker','static_trials');
else
  [file path] = uigetfile('static_trials.mat','Load static file (static_trials.mat)');
  if isequal(file,0)
    display_text = 'No static file chosen, exiting';
    disp(display_text);
    add_text(handles,display_text);
    return;
  end
  fullpath = [path file];
  setpref('audio_analysis_checker','static_trials',[path file]);
end
load(fullpath);

function mic = get_microphone_position(static,handles)
mic=0;
trialcode = handles.internal.extracted_sound_data.trialcode;
dots = strfind(trialcode,'.');
static_day = static(~cellfun(@(c) isempty(c),...
  strfind({static.date},trialcode(dots(1)+1:dots(2)-1))));
if ~isempty(static_day)
  mic_indx = ~cellfun(@isempty,...
    strfind({static_day.markers.name},'MealwormMicrophone'));
  mic = static_day.markers(mic_indx).point;
end

function save_trial(handles)
trial_data=handles.internal.extracted_sound_data;
trial_data.voc_t=handles.internal.DataArray;
trial_data.ch=handles.internal.ch;

%loading static trial for calc. emission time not necessarily limited to net crossing data set but in actuality the only one where we do this
if isfield(trial_data,'net_crossings') 
  %calculating emission times
  static = load_static(handles);
  if isempty(static)
    display_text = 'Couldn''t load static trial for determining emission time, emission times not calculated';
    disp(display_text);
    add_text(handles,display_text);
  elseif isfield(trial_data,'net_crossings') && ~isempty(trial_data.net_crossings)
    NC=trial_data.net_crossings;
    frames=max(1,NC(1)-300):min(NC(2)+500,length(trial_data.sm_centroid));
    mic = get_microphone_position(static,handles);
    D=distance(trial_data.sm_centroid(frames,:),mic);
    t=frames/300-length(trial_data.centroid)/300;
    trial_data.emission_t = calc_emission_times(D,t,trial_data.voc_t);
  end
end

trial_data.voc_checked=1;
trial_data.voc_checked_time=datevec(now);

[fn, pn]=gen_processed_fname(handles);
%if the previous processed_file has a different processed channel, don't
%overwrite it but add it to the trial data
if exist([pn fn],'file')
  prev_file=load([pn fn]);
  if ~isfield(prev_file.trial_data,'ch')
    %assume ch 1
    prev_file.trial_data.ch = 1;
  end
  ii=ismember(prev_file.trial_data.ch,trial_data.ch);
  if length(ii) > 1 || isempty(find(ii,1))
    if find(ii,1) %then the processed file has data from your channel, and we overwrite that channel
      prev_file.trial_data.voc_t{ii}=trial_data.voc_t;
      trial_data.ch=prev_file.trial_data.ch;
      trial_data.voc_t=prev_file.trial_data.voc_t;
    else %the processed file does not have data from your channel and you should add to it
      trial_data.voc_t = {prev_file.trial_data.voc_t; trial_data.voc_t};
      trial_data.ch = [prev_file.trial_data.ch; trial_data.ch];
    end
  end
end
save([pn fn],'trial_data');
handles.internal.changed = 0;
display_text = ['Saved ' handles.internal.audio_fname ' at ' datestr(now,'HH:MM PM')];
disp(display_text);
add_text(handles,display_text);
guidata(handles.save_menu,handles);


function canceled = save_before_discard(handles)
canceled = 0;
if isfield(handles,'internal') && isfield(handles.internal,'changed') && handles.internal.changed
  f=gcf;
  choice = questdlg('Edits detected, save first?', ...
    'Save?', ...
    'Yes','No','Cancel','Yes');
  % Handle response
  switch choice
    case 'Yes'
      save_trial(handles);
    case 'Cancel'
      canceled = 1;
  end
  figure(f);
end

function close_GUI(handles)
if save_before_discard(handles)
  return
end
if isfield(handles,'figure1');
  delete(handles.figure1);
else
  delete(gcf);
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
handles.internal.changed=1;
if handles.internal.current_voc > length(handles.internal.DataArray)
  handles.internal.current_voc=length(handles.internal.DataArray);
end
update(handles);
guidata(hObject, handles);


% --- Executes on button press in new_button.
function new_button_Callback(hObject, eventdata, handles)
axes(handles.wave_axes);
[x,y] = ginput(1);
voc_time = handles.internal.DataArray(handles.internal.current_voc);
buffer=handles.samples/2/handles.internal.Fs;
if isempty(handles.internal.current_voc)
  voc_time=-handles.internal.length_t; %assuming you are at the start of the file
  handles.internal.current_voc=1;
end
if x > voc_time - buffer && x < voc_time + buffer
  handles.internal.DataArray(end+1,1)=x;
  handles.internal.DataArray = sort(handles.internal.DataArray);
  handles.internal.changed=1;
  update(handles);
  guidata(hObject, handles);
else
  disp('Outside displayed range');
  add_text(handles,'Outside displayed range');
end


function voc_edit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end



function low_dB_edit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of low_dB_edit as text
%        str2double(get(hObject,'String')) returns contents of low_dB_edit as a double
set(handles.lock_range_checkbox,'value',1);
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
set(handles.lock_range_checkbox,'value',1);
update(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function top_dB_edit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function key_press_handler(hObject, eventdata, handles)
key=get(handles.figure1,'CurrentKey');

switch key
  case {'numpad6','rightarrow'}
    next_button_Callback(handles.next_button, eventdata, handles);
  case {'numpad4','leftarrow'}
    prev_button_Callback(handles.prev_button, eventdata, handles);
  case {'period','decimal'}
    new_button_Callback(handles.new_button, eventdata, handles);
  case {'subtract','hyphen','delete'}
    delete_button_Callback(handles.delete_button, eventdata, handles);
end



% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function open_menu_Callback(hObject, eventdata, handles)
if save_before_discard(handles)
  return
end
handles=initialize(handles);
handles=load_file(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function save_menu_Callback(hObject, eventdata, handles)
save_trial(handles);

% --------------------------------------------------------------------
function save_open_next_Callback(hObject, eventdata, handles)
save_trial(handles);

fname=handles.internal.audio_fname;
pname=handles.internal.audio_pname;

all_files=dir([pname '*.mat']);
processed_files=dir([pname '*processed.mat']);
fnames_unsort=setdiff({all_files.name},{processed_files.name});
if isempty(fnames_unsort)
  all_files=dir([pname '*.bin']);
  fnames={all_files.name};
else
  %   fname_dates = cellfun(@(f) datenum(f(1:10),'yyyy.mm.dd'),fnames_unsort);
  %   [~, ia] = sort(fname_dates);
  %   fname_tcodes = cellfun(@(f) str2double(f(12:end-3)),fnames_unsort);
  %   [~, ib] = sort(fname_tcodes);
  %   ia_order = 1:length(ia);
  %   A=[ia_order', ia_order(ib)'];
  %   [~, index]=sortrows(A,[1 2]);
  %   fnames = fnames_unsort(ia(index))';
  fnames=fnames_unsort;
end

handles=initialize(handles);

i=find(~cellfun(@isempty,strfind(fnames,fname)),1);
while ~isfield(handles.internal,'DataArray') || isempty(handles.internal.DataArray)
  i=i+1;
  if i <= length(fnames)
    handles=load_file(handles,pname,fnames{i});
  else
    disp('Reached end');
    break
  end
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function close_menu_Callback(hObject, eventdata, handles)
close_GUI(handles)

function plot_spectrogram_checkbox_Callback(hObject, eventdata, handles)
update(handles);
guidata(hObject, handles);


function plot_PI_checkbox_Callback(hObject, eventdata, handles)
update(handles);
guidata(hObject, handles);

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


function playbutton_Callback(hObject, eventdata, handles)

voc_time = handles.internal.DataArray(handles.internal.current_voc);

voc_sample = round((voc_time + handles.internal.length_t)*handles.internal.Fs);

buffer=handles.samples/2;
sample_range=max(1,voc_sample-buffer):min(voc_sample+buffer,length(handles.internal.waveform));
X=handles.internal.waveform(sample_range);

slowdown_factor = str2double(get(handles.playback_slowdown_factor,'string'));

soundsc(X,handles.internal.Fs/slowdown_factor);


function processed_checkbox_Callback(hObject, eventdata, handles)

function new_window_PI_button_Callback(hObject, eventdata, handles)
figure(1); clf;
plot_PI(handles)

function text_output_listbox_CreateFcn(hObject, eventdata, handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
close_GUI(handles);



function text_output_listbox_Callback(hObject, eventdata, handles)




function playback_slowdown_factor_Callback(hObject, eventdata, handles)
set_value = str2double(get(hObject,'String'));
devinfo=audiodevinfo;
inputs = audiodevinfo(1);
names={devinfo.output.Name};
indx=find(~cellfun(@isempty,strfind(names,'Primary Sound Driver'))) + inputs;
if ~audiodevinfo(0, indx, handles.internal.Fs/set_value, 16, 1)
  set(hObject,'String','20');
  disp_text='Sample rate not supported';
  add_text(handles,disp_text);
  disp(disp_text);
end

% --- Executes during object creation, after setting all properties.
function playback_slowdown_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playback_slowdown_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function wave_axes_switch_Callback(hObject, eventdata, handles)
update(handles);
guidata(hObject, handles);

function wave_axes_switch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end



function sound_data_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sound_data_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sound_data_path_edit as text
%        str2double(get(hObject,'String')) returns contents of sound_data_path_edit as a double


% --- Executes during object creation, after setting all properties.
function sound_data_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sound_data_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function sound_data_path_pushbutton_Callback(hObject, eventdata, handles)
if ispref('audioanalysischecker','sound_data_pname')
  DEFAULTNAME=getpref('audioanalysischecker','sound_data_pname');
else
  DEFAULTNAME='';
end
[~, sound_data_pname] = uigetfile('sound_data.mat',...
  'Select sound_data.mat (pre-processed data for multiple files), cancel if not preprocessed',DEFAULTNAME);
if ~isequal(sound_data_pname,0)
  setpref('audioanalysischecker','sound_data_pname',sound_data_pname);
  set_sound_data_path(handles);
end

function clear_sound_data_path_pushbutton_Callback(hObject, eventdata, handles)
setpref('audioanalysischecker','sound_data_pname','');
set_sound_data_path(handles);


% --------------------------------------------------------------------
function export_wav_Callback(hObject, eventdata, handles)

options.WindowStyle='normal';
Fs=handles.internal.Fs;

wavFs = inputdlg('Set desired sample rate for wav file',...
  '',1,{num2str(Fs)},options);
if isempty(wavFs)
  return;
else
  wavFs=round(str2double(wavFs));
end

%for cropping to current view and zeroing out non vocs
voc_time = handles.internal.DataArray(handles.internal.current_voc);
voc_sample = round((voc_time + handles.internal.length_t)*Fs);
buffer=round(handles.samples/2);
sample_range=max(1,voc_sample-buffer):min(voc_sample+buffer,...
  length(handles.internal.waveform));


outchoice = questdlg('Entire File or Current View?', ...
  'Output Size', ...
  'Entire File','Crop to current view','Cancel','Crop to current view');
switch outchoice
  case 'Entire File'
    data=handles.internal.waveform;
  case 'Crop to current view'
    data=handles.internal.waveform(sample_range);
  case 'Cancel'
    return;
end

zerochoice = questdlg('Zero out non voc sections?', ...
  'Zeroing', ...
  'Yes','No','Cancel','Yes');
switch zerochoice
  case 'Yes'
    all_voc_times=handles.internal.DataArray;
    t=(sample_range)./Fs-handles.internal.length_t;
    time_range=t([1 end]);
    voc_t_indx=all_voc_times>=time_range(1)...
      & all_voc_times<=time_range(2);
    
    disp_voc_times=all_voc_times(voc_t_indx);
    voc_nums=find(voc_t_indx);
    
    ii=nan(length(disp_voc_times),1);
    for k=1:length(disp_voc_times)
      [~,ii(k)]=min(abs(t-disp_voc_times(k)));
    end
    voc_buffer=.0025*Fs; %adjust this as needed (5ms call max here 2.5 on either side)
    incl_samps=cell2mat(arrayfun(@(c) (c-voc_buffer:c+voc_buffer),ii,...
      'uniformoutput',0));
    zero_samps=setdiff(1:length(data),incl_samps);
    data(zero_samps)=0;
  case 'No'
  case 'Cancel'
    return;
end

fn=[handles.internal.audio_fname(1:end-3) 'wav'];
[file,path] = uiputfile([handles.internal.audio_pname fn],'Save as');

if isequal(file,0)
  return
end

audiowrite([path file],data./(max(abs(data))+.01),wavFs);
