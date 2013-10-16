function audit_multp_ch(audio,trial_data,processed_audio_dir,dur_fname)
for kk = 1:length(trial_data.voc_t)
  disp(['On file ' trial_data.trialcode ' on channel #' num2str(trial_data.ch(kk))]);
  
  [new_duration_data,completed]=mark_dur(audio,trial_data,trial_data.duration_data{kk},...
    trial_data.duration_data_audit{kk});
  
  if completed
    audit_vocs = ~isnan(trial_data.duration_data_audit{kk}(:,2));
    trial_data.duration_data_audit{kk}(~audit_vocs,2:3)=new_duration_data(:,2:3);
    trial_data.manual_additions{kk} = 1;
    save([processed_audio_dir '\' dur_fname],'trial_data');
  end
end