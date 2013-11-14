clear;

if ispref('audioanalysischecker') && ispref('audioanalysischecker','sound_data_pname')
    sound_data_dir = getpref('audioanalysischecker','sound_data_pname');
else
    sound_data_dir = '';
end

bat_band='BK53';
% BK59 OR40 BK52 BK57 BK53 OR44 P72 W50
data_year=2008;

base_path=[sound_data_dir 'lasse_forest_exploration\'];
orig_dir = pwd;
cd(base_path)
[d3_fnames, d3_path, ~, ~, ~, ~, ~, ~, ~, data_year, ...
  wavebook_path, wavebook_naming]...
  =return_processed_file_names(bat_band,data_year);
cd(orig_dir);

d=dir([base_path wavebook_path]);
isub = [d(:).isdir];
audio_dir = {d(isub).name}';
audio_dir(ismember(audio_dir,{'.','..'})) = [];
if isempty(audio_dir)
  audio_dir{1}='';
end

if exist([sound_data_dir 'sound_data.mat'],'file')
  load([sound_data_dir 'sound_data.mat'])
  trialcodes={extracted_sound_data.trialcode};
  if ~isfield(extracted_sound_data,'d3_start')
    extracted_sound_data().d3_start=nan;
  end
  if ~isfield(extracted_sound_data,'d3_end')
    extracted_sound_data().d3_end=nan;
  end
else
  extracted_sound_data=struct('voc_t',{},'trialcode',{},'bat',{},...
    'voc_checked',{},'voc_checked_time',{},'d3_start',{},'d3_end',{});
  trialcodes={};
end

for dd=3:length(audio_dir)
  
  pathname=[base_path wavebook_path audio_dir{dd}];
  % pathname=[base_path wavebook_path];
  files=dir([pathname '\*.bin']);
  
  for k=1:length(files)
    filename=files(k).name;
    %     trialcode= [bat_band '.20' filename(1:2) filename(3:4) filename(5:6) '.' ...
    %       filename(7:8)];
    trialcode=[bat_band '.20' filename([5 6 3 4 1 2]) '.' ...
      filename(7:8)];
    
    [fd,h,c] = OpenIoTechBinFile([pathname '\' filename]);
    Fs = h.preFreq;
    length_t=h.PreCount/Fs;
    waveforms = ReadChnlsFromFile(fd,h,c,length_t*Fs,1);
    
    cd(base_path);
    d3_indx = match_WB_fname_d3_fnames(filename,d3_fnames,wavebook_naming);
    cd(orig_dir);
    d3_end=nan; d3_start=nan;
    for jj=1:length(d3_indx)
      load([base_path d3_path d3_fnames{d3_indx(jj)}]);
      d3_start = min(d3_start,d3_analysed.startframe/d3_analysed.fvideo);
      d3_end = max(d3_end,d3_analysed.endframe/d3_analysed.fvideo);
    end
    trt_data.d3_start = d3_start;
    trt_data.d3_end = d3_end;
    
    figure(1); clf;
    hh=[];
    for g=1:size(waveforms,2)
      hh(g)=subplot(size(waveforms,2),1,g);
      plot(waveforms{g}(1:10:end));
      hold on;
      rangey=[min(waveforms{g}) max(waveforms{g})];
      plot((length_t+d3_start)*Fs*ones(2,1)/10,rangey,'g')
      plot((length_t+d3_end)*Fs*ones(2,1)/10,rangey,'r')
      title(['Channel: ' num2str(g)]);
      axis tight;
    end
    linkaxes(hh,'x');
    options.WindowStyle='normal';
    if size(waveforms,2)>1
      channel = inputdlg('Which channel?','',1,{''},options);
    else
      channel = {'1'};
    end
    
    if ~isempty(channel)
      ch=str2double(channel);
      waveform=waveforms{ch};
      
      locs = extract_vocs(waveform,Fs,2,.005,2,0);
      
      trt_data.voc_t=locs./Fs - length_t;
      trt_data.trialcode=trialcode;
      trt_data.bat=bat_band;
      trt_data.voc_checked=[];
      trt_data.voc_checked_time=[];
      trt_data.ch = ch;
      
      indx=find(strcmp(trialcodes,trt_data.trialcode));
      trt_data=orderfields(trt_data, extracted_sound_data);
      if ~isempty(indx)
        extracted_sound_data(indx) = trt_data;
      else
        extracted_sound_data(end+1) = trt_data;
      end
      save([sound_data_dir 'sound_data.mat'],'extracted_sound_data');
    end
    disp(['File ' num2str(k) ' of ' num2str(length(files)) ...
      ' dir ' num2str(dd) ' of ' num2str(length(audio_dir))]);
  end
end
