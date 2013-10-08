clear

warning('off','MATLAB:loadobj');

% default_proc_folder is the folder where the processed files are
% default_proc_folder = 'E:\Data Stage USA\Floor_mics\Base_line_data_Empty_room\R14\';
if ispref('audioanalysischecker') && ispref('audioanalysischecker','audio_pname')...
    && exist(getpref('audioanalysischecker','audio_pname'),'dir')
  proc_folder_default=getpref('audioanalysischecker','audio_pname');
else
  proc_folder_default=[];
end
proc_folder=uigetdir(proc_folder_default,...
  'Select the folder for the _processed.mat audio files');
if isequal(proc_folder,0)
  return;
else
  setpref('audioanalysischecker','audio_pname',proc_folder);
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

processed_audio_files=dir([proc_folder '\*processed.mat']);
processed_duration_files=dir([proc_folder '\*_processed_duration.mat']);
processed_audio_fnames={processed_audio_files.name};
processed_duration_fnames={processed_duration_files.name};

d3_files = dir([d3_folder '\*.mat']);

for k=1:length(processed_audio_fnames)
  undr = strfind(processed_audio_fnames{k},'_');
  audio_fn = [processed_audio_fnames{k}(1:undr(end)-1) '.mat'];
  if ~isempty(audio_fn) || exist([proc_folder audio_fn],'file')
    %check for processed duration file of same filename
    if isempty(find(strcmp(processed_audio_fnames{k}(1:undr(end)-1),...
        cellfun(@(c) c(1:undr(end)-1),processed_duration_fnames,'UniformOutput',false)), 1))
      load([proc_folder '\' processed_audio_fnames{k}])
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
        sub_indx = setdiff(full_indx,d3_analysed.ignore_segs+d3_analysed.startframe-1);
        
        trial_data.d3_start = sub_indx(1)/d3_analysed.fvideo;
        trial_data.d3_end = sub_indx(end)/d3_analysed.fvideo;
      end
      
      if isempty(trial_data.d3_start)||isempty(trial_data.d3_end)
        disp(['no video trial found for ' audio_fn]);
      else
        audio = load([proc_folder '\' audio_fn]);
        Fs = audio.SR;
        manual= [];
        DIAG=[];
        if iscell(trial_data.voc_t)
          for kk=1:length(trial_data.voc_t)
            ch_voc_t=trial_data.voc_t{kk};
            ch=trial_data.ch(kk);
            waveform=audio.data(:,ch);
            pretrig_t=audio.pretrigger;
            
            trial_start = max(-8,trial_data.d3_start);
            trial_end = min(0,trial_data.d3_end);
            
            b2mD_comb=nan(length(trial_data.voc_t{kk}),1);
            
            if isdir(['E:\Data Stage USA\Vicon\Position floor microphones\' d3_analysed.trialcode(3:10) '\'])
              mic_obj = get_mic_obj([processed_audio_dir ...
                processed_audio_fnames{k}],...
                d3_analysed.object);
              
              bat_frame = ...
                mictime2frame(ch_voc_t,bat,mic_obj.video(1,:),...
                d3_analysed.fvideo,d3_analysed.startframe);
              b2mD=distance2(bat,mic_obj.video(1:length(bat),:));
              bat_indx_comb=bat_frame-d3_analysed.startframe+1;
              b2mD_comb(~isnan(bat_indx_comb)) = ...
                b2mD(bat_indx_comb(~isnan(bat_indx_comb)));
            else
              b2mD=[];
            end
            
            [onsets, offsets, voc_t] = extract_dur(waveform,Fs,...
              ch_voc_t,trial_start,trial_end,pretrig_t,b2mD_comb,manual,DIAG);
            trial_data.duration_data{kk} = [voc_t, onsets, offsets];
          end
          
        else
          if ~isfield(trial_data,'ch')
            trial_data.ch = 1;
          end
          waveform=audio.data(:,trial_data.ch);
          pretrig_t=audio.pretrigger;
          
          trial_start = max(-8,trial_data.d3_start);
          trial_end = min(0,trial_data.d3_end);
                    
          [onsets, offsets, voc_t] = extract_dur(waveform,Fs,...
            trial_data.voc_t,trial_start,trial_end,pretrig_t,[],manual,DIAG);
          trial_data.duration_data = [voc_t, onsets, offsets];
        end
        
        save([proc_folder '\'...
          processed_audio_fnames{k}(1:end-4) '_duration.mat'],...
          'trial_data')
        disp(['File saved : ' processed_audio_fnames{k}(1:end-4) '_duration.mat']);
        
      end
    end
  else
    msgbox (['Audio file not found for trial ' num2str(k) ' .'],'Error','warn')
  end
  
end

disp('All files completed');
warning('on','MATLAB:loadobj');
% end