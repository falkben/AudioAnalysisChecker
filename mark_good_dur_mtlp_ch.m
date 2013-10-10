function mark_good_dur_mtlp_ch(processed_audio_dir,trial_data,audio,duration_fname)

for kk=1:length(trial_data.voc_t)
  disp(['On file ' trial_data.trialcode ' and on channel #' num2str(trial_data.ch(kk))])
  
  [saving,new_duration_data]=...
    mark_good_dur(trial_data,trial_data.duration_data{kk},audio);
  if saving
    trial_data.duration_data_audit{kk} = new_duration_data;
    save([processed_audio_dir '\' duration_fname],'trial_data');
  end
end
