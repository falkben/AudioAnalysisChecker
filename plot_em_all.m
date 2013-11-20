clear;

% default_proc_folder = 'E:\Data Stage USA\Floor_mics\Base_line_data_Empty_room\R14\';
if ispref('audioanalysischecker') && ispref('audioanalysischecker','audio_pname')...
    && exist(getpref('audioanalysischecker','audio_pname'),'dir')
  default_proc_folder=getpref('audioanalysischecker','audio_pname');
else
  default_proc_folder=[];
end
processed_audio_dir=uigetdir(default_proc_folder,...
  'Select the folder for the _processed.mat audio files');
if isequal(processed_audio_dir,0)
  return;
else
  setpref('audioanalysischecker','audio_pname',processed_audio_dir);
end

processed_duration_files=dir([processed_audio_dir '\*_duration.mat']);
duration_fnames={processed_duration_files.name};

processed_audio_files=dir([processed_audio_dir '\*_processed.mat']);
processed_audio_fnames={processed_audio_files.name};

[raw_audio_dir,audio_fnames]=find_raw_audio_files(processed_audio_dir,processed_audio_fnames,duration_fnames);

options.WindowStyle='normal';
choice = questdlg('Would you like to select a starting file?');
switch choice
  case 'Yes'
    file = uigetfile([processed_audio_dir '\*_duration.mat']);
    if isequal(file,0)
      disp('cancelled starting file, starting from the first file');
      start_indx=1;
    else
      start_indx = find(~cellfun(@isempty,strfind(audio_fnames,file(1:end-23))),1);
    end
  case 'No'
    start_indx=1;
  case 'Cancel'
    return;
end

for k=start_indx:length(audio_fnames)
  disp(['Getting File: ' audio_fnames{k}])
  audio_fn = audio_fnames{k};
  dur_fname_indx = find(~cellfun(@isempty,strfind(duration_fnames,...
    audio_fn(1:end-4))));
  if ~isempty(dur_fname_indx)
    load([processed_audio_dir '\' duration_fnames{dur_fname_indx}])
    
    [waveforms,Fs,pretrig_t,waveform_y_range]=load_audio(raw_audio_dir,audio_fn);
    
    waveform=waveforms(:,trial_data.ch);
    vocs = trial_data.duration_data(isfinite(trial_data.duration_data(:,2)),:);
    
    buffer_s = round((10e-3).*Fs);
    buffer_e = round((14e-3).*Fs);
    for vv=1:length(vocs)
      voc_time = vocs(vv,2);
      voc_samp = round((voc_time + pretrig_t)*Fs);
      voc=waveform(max(1,voc_samp-buffer_s):min(voc_samp+buffer_e,length(waveform)));
      
      clf;
      
      hh(1)=subplot(2,1,1); cla;
      plot((1:length(voc))./Fs,voc);
      hold on;
      plot(buffer_s/Fs,0,'*g');
      axis tight;
      aa=axis;
      hold off;
      
      hh(2)=subplot(2,1,2); cla;
      [~,F,T,P] = spectrogram(voc,128,120,512,Fs);
      imagesc(T,F,10*log10(P)); set(gca,'YDir','normal');
      set(gca,'clim',[-95 -30]);
      hold on;
      axis tight;
      aaa=axis;
      
      axis([aa(1:2) aaa(3:4)]);
      hold off;
      
      linkaxes(hh,'x');
      pause();
    end
    pause;
  end
end
