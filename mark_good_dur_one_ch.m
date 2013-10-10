function mark_good_dur_one_ch(processed_audio_dir,trial_data,audio,duration_fname)

disp(['On file ' trial_data.trialcode])

[saving,new_duration_data]=...
  mark_good_dur(trial_data,trial_data.duration_data,audio);
if saving
  trial_data.duration_data_audit = new_duration_data;
  save([processed_audio_dir '\' duration_fname],'trial_data');
end