function [durs, voc_t] = extract_dur(waveform,Fs,voc_t,trial_start,trial_end,noise)

voc_t=voc_t(voc_t > trial_start & voc_t < trial_end);
durs=nan(length(voc_t),1);

voc_samps = round(voc_t*Fs + 8*Fs);
[b,a] = butter(6,30e3/(Fs/2),'high');

for k=1:length(voc_samps)
  voc_samp = voc_samps(k);
  voc = waveform(voc_samp - .005*Fs:voc_samp + .006*Fs);
  
  ddf=filtfilt(b,a,voc);
  % freqz(b,a,SR/2,SR);
  data_square=smooth(ddf.^2,100);
  
  [pk, loc] = findpeaks(data_square,'NPEAKS',1,...
    'MINPEAKHEIGHT',max(data_square)*.5);
  voc_s = find(noise*1.5 > data_square(1:loc),1,'last');
  voc_e = find(noise*1.5 > data_square(loc:end),1,'first') + loc;
  
  
  figure(1);
  clf; 
  plot(voc);
  hold on;
  plot([voc_s voc_s],[min(voc) max(voc)],'r');
  plot([voc_e voc_e],[min(voc) max(voc)],'r');
  axis tight;
  
  figure(2);
  clf;
  [S,F,T,P] = spectrogram(voc,256,250,256,Fs);
  imagesc(T,F,10*log10(P)); axis tight; set(gca,'YDir','normal');
  hold on;
  plot([voc_s voc_s]./Fs,[0 Fs/2],'r');
  plot([voc_e voc_e]./Fs,[0 Fs/2],'r');
  
  figure(3);
  clf;
  plot(data_square);
  hold on;
  plot([voc_s voc_s],[0 max(data_square)],'r');
  plot([voc_e voc_e],[0 max(data_square)],'r');
  axis tight;
  
  figure(4);
  clf;
  NFFT=1024;
  Y=fft(voc,NFFT);
  f=Fs/2*linspace(0,1,NFFT/2+1);
  plot(f,smooth(2*abs(Y(1:NFFT/2+1)),10))
  
%   pause(.1);
end