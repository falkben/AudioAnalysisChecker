clear;

warning off;

default_proc_folder = 'E:\Data Stage USA\Floor_mics\Base_line_data_Empty_room\R14\';
processed_audio_dir= [uigetdir(default_proc_folder,...
  ['Select the folder where the processed audio files are. The current folder is' default_proc_folder]) '\'];

processed_audio_files=dir([processed_audio_dir '*_duration.mat']);
processed_audio_fnames={processed_audio_files.name};

files = length(dir([processed_audio_dir '*.mat']));
fnames=dir([processed_audio_dir '*.mat']);
audio_files_indx=[];
audio_files={};

for ii = 1 : files
  h=strfind(fnames(ii).name,'_processed');
  if isempty(h)
    audio_files_indx(end+1)=ii;
  end
end

for jj=1:length(audio_files_indx)
  
  audio_files{end+1} = fnames(audio_files_indx(jj));
  
end


for k=1:length(audio_files)
  audio_fn = audio_files{k}.name;
  proc_fname_indx = find(~cellfun(@isempty,strfind(processed_audio_fnames,...
    audio_fn(1:end-4))));
  if ~isempty(proc_fname_indx)
    load([processed_audio_dir processed_audio_fnames{proc_fname_indx}])
    
    audio= load([processed_audio_dir audio_fn]);
    Fs = audio.SR;
    pretrig_t = audio.pretrigger;
    manual= [];
    DIAG=[];
    
    if (~isfield(trial_data,'manual_additions')...
        || trial_data.manual_additions ~= 1)
      
      if iscell(trial_data.voc_t)
        
        audit_multp_ch(trial_data,processed_audio_dir,processed_audio_fnames,proc_fname_indx)
        
      else
        
        audit_single_channel(audio_fn,trial_data,processed_audio_dir,processed_audio_fnames,proc_fname_indx)
        
      end
    end
  end
end
  
  