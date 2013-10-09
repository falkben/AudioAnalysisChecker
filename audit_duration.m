clear;

warning('off','MATLAB:loadobj');

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

files=dir([processed_audio_dir '\*.mat']);
audio_fnames = setdiff({files.name},[processed_audio_fnames; duration_fnames]);

for k=1:length(audio_fnames)
  audio_fn = audio_fnames{k};
  dur_fname_indx = find(~cellfun(@isempty,strfind(duration_fnames,...
    audio_fn(1:end-4))));
  if ~isempty(dur_fname_indx)
    load([processed_audio_dir '\' duration_fnames{dur_fname_indx}])
    
    audio= load([processed_audio_dir '\' audio_fn]);
    Fs = audio.SR;
    pretrig_t = audio.pretrigger;
    
    if (~isfield(trial_data,'manual_additions')...
        || trial_data.manual_additions ~= 1)
      if iscell(trial_data.voc_t)
        audit_multp_ch(trial_data,processed_audio_dir,duration_fnames,...
          dur_fname_indx)
      else
        audit_single_channel(audio,trial_data,processed_audio_dir,...
          duration_fnames{dur_fname_indx})
      end
    end
  end
  disp(['Finished file ' num2str(k) ' of ' num2str(length(audio_fnames))]);
  disp('Continue? Press ESC to cancel, any other key to continue')
  reply = getkey;
  if isequal(reply, 27)
    break;
  end
end

warning('on','MATLAB:loadobj');
