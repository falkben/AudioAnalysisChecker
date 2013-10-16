function [new_duration_data,completed]=mark_dur(audio,trial_data,duration_data,duration_data_audit)
completed=0;

ff=figure(1);
set(ff,'position',[30 45 750 700])

Fs = audio.SR;
pretrig_t = audio.pretrigger;
waveform = audio.data(:,trial_data.ch);
voc_ts = duration_data(:,1);
audit_vocs = ~isnan(duration_data_audit(:,2));
remaining_vocs_indx = find(~audit_vocs);
new_duration_data = nan(length(remaining_vocs_indx),3);
for vv=1:length(remaining_vocs_indx)
  disp(['On voc #' num2str(vv) ' of ' num2str(length(remaining_vocs_indx)) ' vocs.']);
  
  buffer_s = round((10e-3).*Fs);
  buffer_e = round((14e-3).*Fs);
  voc_time = voc_ts(remaining_vocs_indx(vv));
  voc_samp = round((voc_time + pretrig_t)*Fs);
  voc=waveform(max(1,voc_samp-buffer_s):min(voc_samp+buffer_e,length(waveform)));
  
  clf(ff);
  
  hh(1)=subplot(2,1,1); cla;
  plot((1:length(voc))./Fs,voc);
  hold on;
  plot(buffer_s/Fs,0,'*g');
  axis tight;
  aa=axis;
  hold off;
  
  hh(2)=subplot(2,1,2); cla;
  [~,F,T,P] = spectrogram(voc,128,120,512,Fs);
  imagesc(T,F,10*log10(P)); set(gca,'YDir','normal');
  set(gca,'clim',[-95 -30]);
  hold on;
  axis tight;
  aaa=axis;
  
  axis([aa(1:2) aaa(3:4)]);
  hold off;
  
  linkaxes(hh,'x');
  
  disp('press Return to ignore voc, ESC (2x) to quit');
  [x,~,button]=ginput(2);
  if isempty(x) || ismember(13,button) || length(x) < 2
    disp('Ignoring voc');
  elseif diff(x)<0
    disp('Error clicks not in order, ignoring voc')
  elseif ismember(27,button) %ESC
    return;
  else
    voc_s = voc_time - buffer_s/Fs + x(1);
    voc_e = voc_time - buffer_s/Fs + x(2);
    new_duration_data(vv,:) = [voc_time voc_s voc_e];
  end
end

fprintf('<strong>Save file?</strong>\n');
disp('Press any key to continue.  ESC to cancel.');
reply = getkey;
if isequal(reply, 27)
  disp('pressed ESC, quitting')
  return;
end

completed=1;