function duration_data=extract_dur_each_file(waveform,voc_t,trial_data,fvideo,Fs,pretrig_t,manual,DIAG)

trial_start = max(-8,trial_data.d3_start);
trial_end = min(0,trial_data.d3_end);

if isfield(trial_data,'net_crossings')
  net_cross_t1=...
    (trial_data.net_crossings(1)-300-length(trial_data.centroid))./fvideo;
%   net_cross_t2=...
%     (trial_data.net_crossings(2)+100-length(trial_data.centroid))./fvideo;
  trial_start=max(-8,net_cross_t1);
end

[onsets, offsets, voc_t] = extract_dur(waveform,Fs,voc_t,trial_start,...
  trial_end,pretrig_t,[],manual,DIAG);
duration_data = [voc_t, onsets, offsets];