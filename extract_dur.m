function [onsets, offsets, voc_t, I] = extract_dur(waveform,data_square,Fs,voc_t,trial_start,trial_end,noise,b2mD,manual,DIAG)

used_vocs = voc_t > trial_start & voc_t < trial_end;
voc_t=voc_t(used_vocs);
%it's possible that you don't have a bat position for each vocalization
%even after this if you have more than one d3 trial or some ignore segments
b2mD=b2mD(used_vocs);
onsets=nan(length(voc_t),1);
offsets=nan(length(voc_t),1);
I=nan(length(voc_t),1);

buff_past = .005*Fs;
buff_forw = .006*Fs;

voc_samps = round(voc_t*Fs + 8*Fs);

lvl_diff = 20*log10(b2mD);

for k=1:length(voc_samps)
  voc_samp = voc_samps(k);
  voc = waveform(voc_samp - buff_past:voc_samp + buff_forw);
  data_square_voc = data_square(voc_samp - buff_past:voc_samp + buff_forw);
  
  [pk, loc]= max(data_square_voc( buff_past - .0005*Fs:buff_past + .0005*Fs));
  loc = loc + buff_past - .0005*Fs;
  
  I(k) = 20*log10(sqrt(pk)) + lvl_diff(k);
  
  voc_s=nan; voc_e=nan;
  thresh1 = nan; thresh2=nan;
  if ~manual
    thresh = noise*1.5;
    
    if pk < 2e-3
      thresh = thresh/1.8;
    elseif pk > .5
      thresh = thresh*40;
    elseif pk > .06
      thresh = thresh*10;
    elseif pk > .03
      thresh = thresh*6;
    elseif pk > 7e-3
      thresh = thresh*1.5;
    end
    [voc_s,thresh1]=find_thresh_crossing(data_square_voc(1:loc),thresh,pk,0,'last');
    [voc_e,thresh2]=find_thresh_crossing(data_square_voc(loc:end),thresh,pk,loc,'first');
  end
  
  smooth_derivative=smooth(diff(data_square_voc),50);
  %   smooth_derivative<10e-7;
  %   [voc_s,thresh1]=find_thresh_crossing(abs(smooth_derivative),10e-7,pk,0,'last');
  
  if DIAG || manual
    figure(1);
    clf;
    hh(1)=subplot(3,1,1);
    plot((1:length(voc))./Fs,voc);
    hold on;
    plot([voc_s voc_s]./Fs,[min(voc) max(voc)],'r');
    plot([voc_e voc_e]./Fs,[min(voc) max(voc)],'r');
    axis tight;
    aa=axis;
    
    hh(2)=subplot(3,1,2); cla;
    [S,F,T,P] = spectrogram(voc,256,250,256,Fs);
    imagesc(T,F,10*log10(P)); set(gca,'YDir','normal');
    set(gca,'clim',[-90 -45]);
    hold on;
    plot([voc_s voc_s]./Fs,[0 Fs/2],'r');
    plot([voc_e voc_e]./Fs,[0 Fs/2],'r');
    axis tight;
    aaa=axis;
    axis([aa(1:2) aaa(3:4)]);
    
    hh(3)=subplot(3,1,3); cla;
    plot((1:length(data_square_voc))./Fs,data_square_voc);
    hold on;
    plot([voc_s voc_s]./Fs,[0 max(data_square_voc)],'r');
    plot([voc_e voc_e]./Fs,[0 max(data_square_voc)],'r');
    plot([0,length(data_square_voc)/2]./Fs,[thresh1 thresh1],'g');
    plot([length(data_square_voc)/2,length(data_square_voc)]./Fs,...
      [thresh2 thresh2],'g');
    plot(loc./Fs,pk,'*g');
    axis tight;
    
    linkaxes(hh,'x');
    
    figure(2); clf;
    plot((1:length(data_square_voc(2:end)))./Fs,abs(smooth_derivative));
    axis tight;
    aa = axis;
    hold on;
    plot([voc_s voc_s]./Fs,[0 aa(4)],'r');
    plot([voc_e voc_e]./Fs,[0 aa(4)],'r');
    plot(loc./Fs,pk,'*g');
    
    if ~manual
    figure(4); clf;
    NFFT=1024;
    Y=fft(voc(voc_s:voc_e),NFFT);
    f=Fs/2*linspace(0,1,NFFT/2+1);
    plot(f,smooth(2*abs(Y(1:NFFT/2+1)),10))
    axis tight;
    end
    
    figure(5); clf;
    scatter(b2mD,sqrt(data_square(voc_samps)));
    hold on;
    plot(b2mD(k),sqrt(data_square(voc_samps(k))),'or','markerfacecolor','r');
    
    figure(6); clf;
    scatter(offsets-onsets,I);
    
    if manual
      disp('mark start and stop of vocalization')
      axes(hh(3));
      x=ginput(2);
      if diff(x)<0
        disp('wrong order')
        x=ginput(2);
      end
      voc_s = x(1)*Fs;
      voc_e = x(2)*Fs;
    end
    
    %     pause(.1);
  end
  
  onsets(k)=(voc_s + voc_samp - buff_past)/Fs - 8;
  offsets(k)=(voc_e + voc_samp - buff_past)/Fs - 8;
end


function [cross, thresh]= find_thresh_crossing(data,thresh,pk,offset,type)
cross = find(data < thresh,1,type);
while isempty(cross)
  thresh = thresh*2;
  cross = find(data < thresh,1,type);
  if thresh > pk
    break;
  end
end
cross = cross + offset;