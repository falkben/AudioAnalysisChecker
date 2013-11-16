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

[raw_audio_dir,audio_fnames]=find_raw_audio_files(processed_audio_dir,...
  processed_audio_fnames,duration_fnames);

options.WindowStyle='normal';
choice = questdlg('Would you like to select a starting file?');
switch choice
  case 'Yes'
    file = uigetfile([processed_audio_dir '\*_duration.mat']);
    start_indx = find(~cellfun(@isempty,strfind(audio_fnames,file(1:end-23))),1);
  case 'No'
    start_indx=1;
  case 'Cancel'
    return;
end

for k=start_indx:length(audio_fnames)
  audio_fn = audio_fnames{k};
  dur_fname_indx = find(~cellfun(@isempty,strfind(duration_fnames,...
    audio_fn(1:end-4))));
  if ~isempty(dur_fname_indx)
    load([processed_audio_dir '\' duration_fnames{dur_fname_indx}])
    if ~isfield(trial_data,'duration_data_audit')
      
      [waveforms,Fs,pretrig_t,waveform_y_range]=load_audio(raw_audio_dir,audio_fn);
      audio.data=waveforms;
      audio.SR=Fs;
      audio.pretrigger=pretrig_t;
      
      if iscell(trial_data.voc_t)
        mark_good_dur_mtlp_ch(processed_audio_dir,trial_data,audio,...
          duration_fnames{dur_fname_indx})
      else
        mark_good_dur_one_ch(processed_audio_dir,trial_data,audio,...
          duration_fnames{dur_fname_indx})
      end
      disp(['Finished file ' num2str(k) ' of ' num2str(length(audio_fnames))]);
      fprintf('<strong>Continue with next file?</strong>\n');
      disp('Press ESC to cancel, any other key to continue')
      reply = getkey;
      if isequal(reply, 27)
        disp('pressed ESC, quitting')
        break;
      end
    end
  end
end