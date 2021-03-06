function audit_single_channel(audio,trial_data,processed_audio_dir,dur_fname)
disp(['On file ' trial_data.trialcode ' on channel #' num2str(trial_data.ch)]);

[new_duration_data,completed]=mark_dur(audio,trial_data,trial_data.duration_data,...
  trial_data.duration_data_audit);

if completed
  audit_vocs = ~isnan(trial_data.duration_data_audit(:,2));
  trial_data.duration_data_audit(~audit_vocs,2:3) = new_duration_data(:,2:3);
  trial_data.manual_additions = 1;
  save([processed_audio_dir '\' dur_fname],'trial_data');
end
