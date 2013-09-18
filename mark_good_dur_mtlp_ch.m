function mark_good_dur_mtlp_ch(processed_audio_dir,trial_data,audio,Fs,pretrig_t,processed_audio_fnames,proc_fname_indx)

if ~isfield(trial_data,'duration_data_audit')
    
for kk=1:length(trial_data.voc_t)
  
  ch_voc_t = trial_data.voc_t{kk};
  ch=trial_data.ch(kk);
  waveform=audio.data(:,ch);
  
  
    
  disp(['On file ' trial_data.trialcode ' and on channel #' ch])
  
  disp('Type Enter/Return to keep vocalization, minus to delete voc, ESC to quit');
  
  new_duration_data = trial_data.duration_data{kk};
  vv_indx=find(~isnan(trial_data.duration_data{kk}(:,2)))';
  vv=1;
  while vv <= length(vv_indx)
    voc_s = trial_data.duration_data{kk}(vv_indx(vv),2);
    voc_e = trial_data.duration_data{kk}(vv_indx(vv),3);
    buffer_s = round((2e-3).*Fs);
    buffer_e = round((2e-3).*Fs);
    samp_s = round((voc_s + pretrig_t).*Fs);
    samp_e = round((voc_e + pretrig_t).*Fs);
    voc = waveform(max(1,samp_s):samp_e);
    
    clf;
    
    hh(1)=subplot(2,1,1); cla;
    voc_p = waveform(max(1,samp_s-buffer_s):min(samp_e+buffer_e,length(waveform)));
    plot((1:length(voc_p))./Fs,voc_p);
    hold on;
    plot([buffer_s buffer_s]./Fs,[min(voc_p) max(voc_p)],'r')
    plot([buffer_s+samp_e-samp_s buffer_s+samp_e-samp_s]./Fs,...
      [min(voc_p) max(voc_p)],'r')
    axis tight;
    aa=axis;
    hold off;
    
    hh(2)=subplot(2,1,2); cla;
    [~,F,T,P] = spectrogram(voc_p,128,120,512,Fs);
    imagesc(T,F,10*log10(P)); set(gca,'YDir','normal');
    set(gca,'clim',[-95 -30]);
    %         colormap jet
    %         colorbar
    hold on;
    axis tight;
    aaa=axis;
    plot([buffer_s buffer_s]./Fs,[0 Fs/2],'r')
    plot([buffer_s+samp_e-samp_s buffer_s+samp_e-samp_s]./Fs,...
      [0 Fs/2],'r')
    axis([aa(1:2) aaa(3:4)]);
    hold off;
    
    linkaxes(hh,'x');
    
    reply = getkey;
    while ischar(reply) || isempty(~find(reply==[13 45 27 28 29]))
      disp('neither return or minus were pressed, ESC to quit');
      reply = getkey;
    end
    switch reply
      case {13, 29} %return or right arrow, keep voc
        new_duration_data(vv_indx(vv),2:3)=...
          trial_data.duration_data{kk}(vv_indx(vv),2:3);
        vv=vv+1;
      case 45 % delete voc
        new_duration_data(vv_indx(vv),2:3)=nan;
        vv=vv+1;
      case 27 %ESC
        disp(['On voc: ' num2str(vv_indx(vv)) ' file ' num2str(k) ...
          ' dir ' num2str(dd)]);
        return;
      case 28 %going backwards
        vv=vv-1;
    end
    if vv < 1
      vv=1;
    elseif vv > length(vv_indx)
      disp('saving, press ESC to cancel, BACK to go back, any other key to continue')
      reply = getkey;
      if isequal(reply, 28)
        vv=vv-2;
      elseif ~isequal(reply, 27)
        trial_data.duration_data_audit{kk} = new_duration_data;
        save([processed_audio_dir processed_audio_fnames{proc_fname_indx}],'trial_data');
      end
    end
  end
end
end