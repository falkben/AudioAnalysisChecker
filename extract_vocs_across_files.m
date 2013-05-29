clear;

sound_data_dir = 'F:\eptesicus_forest_collab\';

bat_band='BK52';
% BK59 OR40 B52 B57 P72 W50
data_year=2009;

[~, ~, BG_fnames, batgadget_path, ~, ~, ~, ~, dates, data_year, wavebook_path]...
  =return_processed_file_names(bat_band,data_year);

base_path='F:\eptesicus_forest_collab\lasse_forest_exploration\';

% d=dir([base_path wavebook_path]);
% isub = [d(:).isdir];
% audio_dir = {d(isub).name}';
% audio_dir(ismember(audio_dir,{'.','..'})) = [];

% for dd=1:length(audio_dir)

%   pathname=['wavebook\' audio_dir{dd}];
pathname=[base_path wavebook_path];
files=dir([pathname '\*.bin']);

buff_before_trig=8;

if exist([sound_data_dir 'sound_data.mat'],'file')
  load([sound_data_dir 'sound_data.mat'])
  trialcodes={extracted_sound_data.trialcode};
else
  extracted_sound_data=struct('voc_t',{},'trialcode',{},'bat',{},...
    'voc_checked',{},'voc_checked_time',{});
  trialcodes={};
end

for k=1:length(files)
  filename=files(k).name;
  %     trialcode= [bat_band '.20' filename(1:2) filename(3:4) filename(5:6) '.' ...
  %       filename(7:8)];
  trialcode=[bat_band '.20' filename([5 6 3 4 1 2]) '.' ...
    filename(7:8)];
  [fd,h,c] = OpenIoTechBinFile([pathname '\' filename]);
  waveforms = ReadChnlsFromFile(fd,h,c,10*250000,1);
  Fs = h.preFreq;
  
  figure(1); clf;
  hh=[];
  for g=1:size(waveforms,2)
    hh(g)=subplot(size(waveforms,2),1,g);
    plot(waveforms{g}(1:10:end));
    title(['Channel: ' num2str(g)]);
    axis tight;
  end
  linkaxes(hh,'x');
  options.WindowStyle='normal';
  channel = inputdlg('Which channel?','',1,{''},options);
  %     close(1);
  
  if ~isempty(channel)
    ch=str2double(channel);
    waveform=waveforms{ch};
    
    %extract audio from during, before, after net climb
    locs = extract_vocs(waveform,Fs,2.5,.006,1);
    
    trt_data.voc_t=locs./Fs - buff_before_trig;
    trt_data.trialcode=trialcode;
    trt_data.bat=bat_band;
    trt_data.voc_checked=[];
    trt_data.voc_checked_time=[];
    trt_data.ch = ch;
    indx=find(strcmp(trialcodes,trt_data.trialcode));
    if ~isempty(indx) && ~isequal(extracted_sound_data(indx),trt_data)
      extracted_sound_data(indx) = trt_data;
    else
      extracted_sound_data(end+1) = trt_data;
    end
  end
  save([sound_data_dir 'sound_data.mat'],'extracted_sound_data');
end

