clear

sound_data_dir = 'F:\eptesicus_forest_collab\';

bat_band='BK59';
% BK59 OR40 B52 B57 B53 OR44 P72 W50
data_year=2009;

base_path='F:\eptesicus_forest_collab\lasse_forest_exploration\';
orig_dir = pwd;
cd(base_path)
[d3_fnames, d3_path, ~, ~, ~, ~, ~, ~, ~, data_year, ...
  wavebook_path, wavebook_naming]...
  =return_processed_file_names(bat_band,data_year);
cd(orig_dir);

processed_audio_dir='wavebook_processed_BK59_AudioAnalysisChecker\';
processed_audio_files=dir([base_path processed_audio_dir '*.mat']);
processed_audio_fnames={processed_audio_files.name};

d=dir([base_path wavebook_path]);
isub = [d(:).isdir];
audio_dir = {d(isub).name}';
audio_dir(ismember(audio_dir,{'.','..'})) = [];

for dd=2:length(audio_dir)
  pathname=[base_path wavebook_path audio_dir{dd}];
  files=dir([pathname '\*.bin']);
  for k=1:length(files)
    WB_fname = files(k).name;
    proc_fname_indx = find(~cellfun(@isempty,strfind(processed_audio_fnames,...
      WB_fname(1:end-4))));
    if ~isempty(proc_fname_indx)
      load([base_path processed_audio_dir ...
        processed_audio_fnames{proc_fname_indx}])
      if isfield(trial_data,'d3_start') && ~isnan(trial_data.d3_start)
        d3_start = trial_data.d3_start;
        d3_end = trial_data.d3_end;
      else
        cd(base_path);
        d3_indx = match_WB_fname_d3_fnames(WB_fname,d3_fnames,wavebook_naming);
        cd(orig_dir);
        d3_end=nan; d3_start=nan;
        for jj=1:length(d3_indx)
          load([base_path d3_path d3_fnames{d3_indx(jj)}]);
          d3_start = min(d3_start,d3_analysed.startframe/d3_analysed.fvideo);
          d3_end = max(d3_end,d3_analysed.endframe/d3_analysed.fvideo);
        end
      end
      
      [fd,h,c] = OpenIoTechBinFile([pathname '\' WB_fname]);
      waveforms = ReadChnlsFromFile(fd,h,c,10*250000,1);
      Fs = h.preFreq;
      waveform = waveforms{trial_data.ch};
      
      trial_start = max(-8,d3_start);
      trial_end = min(0,d3_end);
      
      %remove extraneous sounds below 20k
      [b,a] = butter(6,20e3/(Fs/2),'high');
      ddf=filtfilt(b,a,waveform);
      % freqz(b,a,SR/2,SR);
      data_square=smooth(ddf.^2,200);
      noise = median(max(reshape(data_square(1:floor(length(data_square)/1e3)*1e3),...
        1e3,[])));
      
      cd(base_path);
      b2mD_comb=nan(length(trial_data.voc_t),1);
      d3_indx = match_WB_fname_d3_fnames(WB_fname,d3_fnames,wavebook_naming);
      for jj=1:length(d3_indx)
        load([base_path d3_path d3_fnames{d3_indx(jj)}]);
        bat=d3_analysed.object(1).video;
        if isfield(d3_analysed,'ignore_segs')
          for ii=1:size(d3_analysed.ignore_segs,1)
            bat(d3_analysed.ignore_segs(ii,1):...
              d3_analysed.ignore_segs(ii,2),:)=nan;
          end
        end
        object_names = {d3_analysed.object.name};
        mic_objs_i = find(~cellfun(@isempty,strfind(object_names,'mic')));
        mic_obj = d3_analysed.object(mic_objs_i(trial_data.ch));
        bat_frame = ...
          mictime2frame(trial_data.voc_t,bat,mic_obj.video(1,:),...
          d3_analysed.fvideo,d3_analysed.startframe);
        b2mD=distance2(bat,mic_obj.video(1:length(bat),:));
        bat_indx_comb=bat_frame-d3_analysed.startframe+1;
        b2mD_comb(~isnan(bat_indx_comb)) = ...
          b2mD(bat_indx_comb(~isnan(bat_indx_comb)));
      end
      cd(orig_dir);
      
      if isempty(d3_indx)
        disp(['no video trial found for ' WB_fname]);
      else
        [durs, voc_t] = extract_dur(waveform,data_square,Fs,trial_data.voc_t,trial_start,trial_end,noise,b2mD_comb,0);
        trial_data.duration_data = [voc_t, durs];
      end
    end
  end
end