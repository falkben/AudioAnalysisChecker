clear

warning('off','MATLAB:loadobj');

% default_proc_folder is the folder where the processed files are
% default_proc_folder = 'E:\Data Stage USA\Floor_mics\Base_line_data_Empty_room\R14\';
if ispref('audioanalysischecker') && ispref('audioanalysischecker','audio_pname')...
    && exist(getpref('audioanalysischecker','audio_pname'),'dir')
  d3_default_folder=getpref('audioanalysischecker','audio_pname');
else
  d3_default_folder=[];
end
proc_folder=uigetdir(d3_default_folder,...
  'Select the folder for the _processed.mat audio files');
if isequal(proc_folder,0)
  return;
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


for k=3:length(processed_audio_files)
    undr = strfind(processed_audio_files(k).name,'_');
    audio_fn = [processed_audio_files(k).name(1:undr(2)-1) '.mat'];
    if ~isempty(audio_fn)
        proc_fname_indx = find(~cellfun(@isempty,strfind(processed_audio_fnames,...
            audio_fn(1:end-4))));
        if ~isempty(proc_fname_indx) && ...
                isempty(find(strcmp(processed_audio_fnames{proc_fname_indx}(1:undr(2)-1),...
                cellfun(@(c) c(1:undr(2)-1),processed_duration_fnames,'UniformOutput',false)), 1))
            load([proc_folder ...
                processed_audio_fnames{proc_fname_indx}])
            if isfield(trial_data,'d3_start') && ~isempty(cell2mat(trial_data.d3_start))
                d3_start = trial_data.d3_start;
                d3_end = trial_data.d3_end;
            else
                d3_indx = get_d3_indx(processed_audio_files,d3_files);
                d3_indx=d3_indx';
                %                 d3_end=nan; d3_start=nan;
                for jj=1:length(d3_indx)
                    load([d3_folder d3_files(d3_indx(jj)).name]);
                    d3_dots=strfind(d3_analysed.trialcode,'.');
                    if d3_analysed.trialcode(d3_dots(2)+1:d3_dots(3)-1)==trial_data.trialcode(end-1:end)
                        trial_data.d3_start =d3_analysed.startframe/d3_analysed.fvideo;
                        trial_data.d3_end=d3_analysed.endframe/d3_analysed.fvideo;
                    end
                end
            end
            
            if isfield(d3_analysed,'ignore_segs')
                for ii=1:size(d3_analysed.ignore_segs,1)
                    bat(d3_analysed.ignore_segs(ii,1):...
                        d3_analysed.ignore_segs(ii,2),:)=nan;
                end
            end
            
            if isempty(trial_data.d3_start)||isempty(trial_data.d3_end)
                
                disp(['no video trial found for ' audio_fn]);
                
            else
                audio = load([proc_folder audio_fn]);
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
                                processed_audio_fnames{proc_fname_indx}],...
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
                    waveform=audio.data(:,trial_data.ch);
                    pretrig_t=audio.pretrigger;
                    
                    trial_start = max(-8,trial_data.d3_start);
                    trial_end = min(0,trial_data.d3_end);
                    
                    b2mD_comb=nan(length(trial_data.voc_t),1);
                    
                    if isdir(['E:\Data Stage USA\Vicon\Position floor microphones\' d3_analysed.trialcode(3:10) '\'])
                        mic_obj = get_mic_obj([processed_audio_dir ...
                            processed_audio_fnames{proc_fname_indx}],...
                            d3_analysed.object);
                        
                        bat_frame = ...
                            mictime2frame(trial_data.voc_t,bat,mic_obj.video(1,:),...
                            d3_analysed.fvideo,d3_analysed.startframe);
                        b2mD=distance2(bat,mic_obj.video(1:length(bat),:));
                        bat_indx_comb=bat_frame-d3_analysed.startframe+1;
                        b2mD_comb(~isnan(bat_indx_comb)) = ...
                            b2mD(bat_indx_comb(~isnan(bat_indx_comb)));
                    else
                        b2mD=[];
                    end
                    
                    ch_voc_t=trial_data.voc_t;
                    
                    
                    [onsets, offsets, voc_t] = extract_dur(waveform,Fs,...
                        ch_voc_t,trial_start,trial_end,pretrig_t,b2mD_comb,manual,DIAG);
                    trial_data.duration_data = [voc_t, onsets, offsets];
                    
                end
                
                save([proc_folder...
                    processed_audio_fnames{proc_fname_indx}(1:end-4) '_duration.mat'],...
                    'trial_data')
                disp(['File saved : ' processed_audio_fnames{proc_fname_indx}(1:end-4) '_duration.mat']);

            end
        end
    else
        msgbox (['Audio file not found for trial ' num2str(k) ' .'],'Error','warn')
    end
    
end

disp('All files completed');
warning('on','MATLAB:loadobj');
% end