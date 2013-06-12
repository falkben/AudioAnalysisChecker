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
      
      %remove extraneous sounds below 30k
      [b,a] = butter(6,30e3/(Fs/2),'high');
      ddf=filtfilt(b,a,waveform);
      % freqz(b,a,SR/2,SR);
      data_square=smooth(ddf.^2,200);
      noise = median(max(reshape(data_square(1:floor(length(data_square)/1e3)*1e3),...
        1e3,[])));
      
      extract_dur(waveform,Fs,trial_data.voc_t,trial_start,trial_end,noise);
    end
  end
end