function [onsets, offsets, voc_t, I] = extract_dur(waveform,Fs,voc_t,trial_start,trial_end,b2mD,manual,DIAG)

%remove extraneous sounds below 12k
[b,a] = butter(6,12e3/(Fs/2),'high');
ddf=filtfilt(b,a,waveform);
% freqz(b,a,SR/2,SR);
data_square=smooth(ddf.^2,100);

noise=median(max(reshape(data_square(1:floor(length(data_square)/1e3)*1e3),...
  1e3,[])));
data_square_diff = abs(smooth(diff(data_square),50));
noise_diff=median(max(reshape(data_square_diff(1:floor(length(data_square)/1e3)*1e3),...
  1e3,[])));

used_vocs = voc_t > trial_start & voc_t < trial_end;
voc_t=voc_t(used_vocs);
%it's possible that you don't have a bat position for each vocalization
%even after this if you have more than one d3 trial or some ignore segments
b2mD=b2mD(used_vocs);
lvl_diff = 20*log10(b2mD/.1);

%for marking the end freq, 
%we assume it's below 30k, removes some energy from echoes
[low_b, low_a]=butter(6,30e3/(Fs/2),'low'); 
waveform_low=filtfilt(low_b,low_a,waveform);
data_square_low=smooth((waveform_low.^2),100);

if ~manual && ...
    exist('F:\eptesicus_forest_collab\duration_threshold_fit.mat','file')
  load('F:\eptesicus_forest_collab\duration_threshold_fit.mat');
end

voc_samps = round(voc_t*Fs + 8*Fs);
buff_past = .0045*Fs;
buff_forw = .006*Fs;

onsets=nan(length(voc_t),1);
offsets=nan(length(voc_t),1);
I=nan(length(voc_t),1);
for k=22:length(voc_samps)
  voc_samp = voc_samps(k);
  voc = waveform(voc_samp - buff_past:voc_samp + buff_forw);
  data_square_voc = data_square(voc_samp - buff_past:voc_samp + buff_forw);
  data_square_low_voc = data_square_low(voc_samp - buff_past:voc_samp + buff_forw);
  smooth_derivative=data_square_diff(voc_samp - buff_past + 1:voc_samp + buff_forw);
  
  %1 ms before and after voc_t, look for maximum...
  [pk, loc]= max( data_square_voc(buff_past - .001*Fs:buff_past + .001*Fs) );
  loc = loc + buff_past - .001*Fs;
  
  %no idea if this equation is correct...
  I(k) = 20*log10(sqrt(pk)) + lvl_diff(k);
  
  voc_s=nan; voc_e=nan;
  %   thresh1 = nan; thresh2=nan;
  if ~manual && pk > .0005
%     if pk < .0015
%       thresh = noise*1.05;
%     elseif pk > 2
%       thresh = noise*1500;
%     elseif pk > 1
%       thresh = noise*150*1.5;
%     elseif pk > .5
%       thresh = noise*40*1.5;
%     elseif pk > .2
%       thresh = noise*15;
%     elseif pk > .1
%       thresh = noise*9;
%     elseif pk > .03
%       thresh = noise*3;
%     elseif pk < .01
%       thresh = noise*1.1;
%     else
%       thresh = noise*1.5;
%     end
    thresh = polyval(thresh1fit.coeff,pk);
    [voc_s,thresh1]=find_thresh_crossing(data_square_voc(1:loc),thresh,pk,...
      0,'last',smooth_derivative,noise_diff);
    [voc_e,thresh2]=find_thresh_crossing(data_square_low_voc(loc:end),[],pk,...
      loc,'first',smooth_derivative,noise_diff);
  end
  
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
    set(gca,'clim',[-95 -45]);
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
    
    figure(3), clf;
    plot((1:length(data_square_low_voc))./Fs,data_square_low_voc);
    hold on;
%     plot([voc_s voc_s]./Fs,[0 max(data_square_low)],'r');
    plot([voc_e voc_e]./Fs,[0 max(data_square_low_voc)],'r');
    plot([0,length(data_square_low_voc)]./Fs,[thresh2 thresh2],'g');
    axis tight;
    
    figure(4), hold on;
    scatter(pk,polyval(thresh1fit.coeff,pk));
    
    figure(2); clf;
    plot((1:length(data_square_voc(2:end)))./Fs,smooth_derivative);
    axis tight;
    aa = axis;
    hold on;
    plot([voc_s voc_s]./Fs,[0 aa(4)],'r');
    plot([voc_e voc_e]./Fs,[0 aa(4)],'r');
    plot([1 length(smooth_derivative)]./Fs,...
      [noise_diff noise_diff].*20,'g');
    plot(loc./Fs,pk,'*g');
    
%     figure(3); clf;
%     plot(data_square_low)
    
    %     if ~manual && ~isnan(voc_s) && ~isnan(voc_e)
    %       figure(4); clf;
    %       NFFT=1024;
    %       Y=fft(voc(voc_s:voc_e),NFFT);
    %       f=Fs/2*linspace(0,1,NFFT/2+1);
    %       plot(f,smooth(2*abs(Y(1:NFFT/2+1)),10))
    %       axis tight;
    %     end
    
    %     figure(5); clf;
    %     scatter(b2mD,sqrt(data_square(voc_samps)));
    %     hold on;
    %     plot(b2mD(k),sqrt(data_square(voc_samps(k))),'or','markerfacecolor','r');
    
    %     figure(6); clf;
    %     scatter(I,offsets-onsets);
    
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
  end
  
  onsets(k)=(voc_s + voc_samp - buff_past)/Fs - 8;
  offsets(k)=(voc_e + voc_samp - buff_past)/Fs - 8;
end

disp('analyze_thresholds');


function [cross, thresh]= find_thresh_crossing(data,thresh,pk,offset,type,smooth_derivative,noise_diff)
if strcmp(type,'first')
  [M,ii]=max(data);
  thresh = M/6;
  cross=find(data(ii:end) < thresh,1,type)+ii-1;
  while isempty(cross)
    thresh = thresh*1.5;
    cross = find(data(ii:end) < thresh,1,type)+ii-1;
    if thresh > M
      break;
    end
  end
  cross=find(smooth_derivative(cross+offset:end) < noise_diff*50,1,type)+cross - 1;
else
  cross = find(data < thresh,1,type);
  while isempty(cross)
    thresh = thresh*1.5;
    cross = find(data < thresh,1,type);
    if thresh > pk
      break;
    end
  end
  cross_diff=find(smooth_derivative(1:cross) < noise_diff*20,1,type);
  if ~isempty(cross_diff)
    cross=cross_diff;
  end
end

cross = cross + offset;




