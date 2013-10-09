clear

manual=0;
DIAG=0;

warning('off','MATLAB:loadobj');

% default_proc_folder is the folder where the processed files are
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

% this is the folder where the analysed c3d files are
% d3_default_folder='E:\Data Stage USA\analysed_c3d\';
if ispref('audioanalysischecker') && ispref('audioanalysischecker','d3_pname')...
    && exist(getpref('audioanalysischecker','d3_pname'),'dir')
  d3_default_folder=getpref('audioanalysischecker','d3_pname');
else
  d3_default_folder=[];
end
d3_folder=uigetdir(d3_default_folder,...
  'Select the folder where the d3_analysed files');
if isequal(d3_folder,0)
  return;
else
  setpref('audioanalysischecker','d3_pname',d3_folder);
end

processed_audio_files=dir([processed_audio_dir '\*processed.mat']);
processed_duration_files=dir([processed_audio_dir '\*_processed_duration.mat']);
processed_audio_fnames={processed_audio_files.name};
processed_duration_fnames={processed_duration_files.name};

d3_files = dir([d3_folder '\*.mat']);

for k=1:length(processed_audio_fnames)
  undr = strfind(processed_audio_fnames{k},'_');
  audio_fn = [processed_audio_fnames{k}(1:undr(end)-1) '.mat'];
  if ~isempty(audio_fn) || exist([processed_audio_dir audio_fn],'file')
    %check for processed duration file of same filename
    if isempty(find(strcmp(processed_audio_fnames{k}(1:undr(end)-1),...
        cellfun(@(c) c(1:undr(end)-1),processed_duration_fnames,'UniformOutput',false)), 1))
      load([processed_audio_dir '\' processed_audio_fnames{k}])
      if isfield(trial_data,'d3_start') && ~isempty(cell2mat(trial_data.d3_start))
        d3_start = trial_data.d3_start;
        d3_end = trial_data.d3_end;
      else
        d3_indx=get_d3_indx({d3_files.name},trial_data.trialcode);
        trial_data.d3_start = trial_data.voc_t(1);
        trial_data.d3_end = 0;
        for jj=1:length(d3_indx)
          load([d3_folder '\' d3_files(d3_indx(jj)).name]);
          trial_data.d3_start=...
            min(d3_analysed.startframe/d3_analysed.fvideo,trial_data.d3_start);
          trial_data.d3_end=...
            max(d3_analysed.endframe/d3_analysed.fvideo,trial_data.d3_end);
        end
      end
      
      if isfield(d3_analysed,'ignore_segs')
        full_indx=round(trial_data.d3_start*d3_analysed.fvideo):round(trial_data.d3_end*d3_analysed.fvideo);
        full_indx(d3_analysed.ignore_segs)=[];
%         sub_indx = setdiff(full_indx,d3_analysed.ignore_segs+d3_analysed.startframe-1);
        
        trial_data.d3_start = full_indx(1)/d3_analysed.fvideo;
        trial_data.d3_end = (full_indx(end))/d3_analysed.fvideo;
      end
      
      if isempty(trial_data.d3_start)||isempty(trial_data.d3_end)
        disp(['no video trial found for ' audio_fn]);
      else
        audio = load([processed_audio_dir '\' audio_fn]);
        
        Fs = audio.SR;
        pretrig_t=audio.pretrigger;
        if iscell(trial_data.voc_t)
          for kk=1:length(trial_data.voc_t)
            ch_voc_t=trial_data.voc_t{kk};
            ch=trial_data.ch(kk);
            waveform=audio.data(:,ch);
            
            trial_data.duration_data{kk}=extract_dur_each_file(waveform,ch_voc_t,...
              trial_data,d3_analysed.fvideo,Fs,manual,DIAG);
          end
        else
          if ~isfield(trial_data,'ch')
            trial_data.ch = 1;
          end
          waveform=audio.data(:,trial_data.ch);
          trial_data.duration_data=extract_dur_each_file(waveform,trial_data.voc_t,...
            trial_data,d3_analysed.fvideo,Fs,pretrig_t,manual,DIAG);
        end
        
        save([processed_audio_dir '\'...
          processed_audio_fnames{k}(1:end-4) '_duration.mat'],...
          'trial_data')
        disp(['File (' sprintf('%u%s%u',k,' of ',length(processed_audio_fnames)) ') saved: ' processed_audio_fnames{k}(1:end-4) '_duration.mat']);
      end
    end
  else
    msgbox (['Audio file not found for trial ' num2str(k) ' .'],'Error','warn')
  end
  
end

disp('All files completed');
warning('on','MATLAB:loadobj');
% end