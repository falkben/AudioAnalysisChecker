clear

bat_band='BK57';
% BK59 OR40 B52 B57 B53 OR44 P72 W50
data_year=2008;
[d3_fnames, d3_path, ~, ~, ~, ~, ~, ~, ~, data_year, ...
  wavebook_path, wavebook_naming,~,processed_audio_dir]...
  =return_processed_file_names(bat_band,data_year);

processed_audio_files=dir([processed_audio_dir '*_processed.mat']);
processed_duration_files=dir([processed_audio_dir '*_processed_duration.mat']);
processed_audio_fnames={processed_audio_files.name};
processed_duration_fnames={processed_duration_files.name};

d=dir(wavebook_path);
isub = [d(:).isdir];
audio_dir = {d(isub).name}';
audio_dir(ismember(audio_dir,{'.','..'})) = [];
if isempty(audio_dir)
  audio_dir{1}='';
end
for dd=1:length(audio_dir)
  pathname=[wavebook_path audio_dir{dd}];
  files=dir([pathname '\*.bin']);
  for k=1:length(files)
    WB_fname = files(k).name;
    proc_fname_indx = find(~cellfun(@isempty,strfind(processed_audio_fnames,...
      WB_fname(1:end-4))));
    if ~isempty(proc_fname_indx) && ...
        isempty(find(strcmp(processed_audio_fnames{proc_fname_indx}(1:8),...
        cellfun(@(c) c(1:8),processed_duration_fnames,'UniformOutput',false)), 1))
      load([processed_audio_dir ...
        processed_audio_fnames{proc_fname_indx}])
      if isfield(trial_data,'d3_start') && ~isnan(trial_data.d3_start)
        d3_start = trial_data.d3_start;
        d3_end = trial_data.d3_end;
      else
        d3_indx = match_WB_fname_d3_fnames(WB_fname,d3_fnames,wavebook_naming);
        d3_end=nan; d3_start=nan;
        for jj=1:length(d3_indx)
          load([d3_path d3_fnames{d3_indx(jj)}]);
          d3_start = min(d3_start,d3_analysed.startframe/d3_analysed.fvideo);
          d3_end = max(d3_end,d3_analysed.endframe/d3_analysed.fvideo);
        end
      end
      
      [fd,h,c] = OpenIoTechBinFile([pathname '\' WB_fname]);
      Fs = h.preFreq;
      pretrig_t = h.PreCount/Fs;
      waveforms = ReadChnlsFromFile(fd,h,c,pretrig_t*Fs+.2*Fs,1);
      waveform = waveforms{trial_data.ch};
      
      trial_start = max(-8,d3_start);
      trial_end = min(0,d3_end);
      
      b2mD_comb=nan(length(trial_data.voc_t),1);
      d3_indx = match_WB_fname_d3_fnames(WB_fname,d3_fnames,wavebook_naming);
      for jj=1:length(d3_indx)
        load([d3_path d3_fnames{d3_indx(jj)}]);
        bat=d3_analysed.object(1).video;
        if isfield(d3_analysed,'ignore_segs')
          for ii=1:size(d3_analysed.ignore_segs,1)
            bat(d3_analysed.ignore_segs(ii,1):...
              d3_analysed.ignore_segs(ii,2),:)=nan;
          end
        end
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
      end
      
      if isempty(d3_indx)
        disp(['no video trial found for ' WB_fname]);
      else
        [onsets, offsets, voc_t] = extract_dur(waveform,Fs,...
          trial_data.voc_t,trial_start,trial_end,pretrig_t,b2mD_comb,0,0);
        trial_data.duration_data = [voc_t, onsets, offsets];
        save([processed_audio_dir...
          processed_audio_fnames{proc_fname_indx}(1:end-4) '_duration.mat'],...
          'trial_data')
      end
    end
  end
end