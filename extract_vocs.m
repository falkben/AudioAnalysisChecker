%thresh_mult, how much above noise to mark a call
%min_PI, acceptable amount of time (sec) between calls
function[locs,pks]=extract_vocs(dd,SR,thesh_mult,min_PI,echo_rem_iterations,DIAG)

%remove extraneous sounds below 20k
[b,a] = butter(6,20e3/(SR/2),'high');
ddf=filtfilt(b,a,dd);
% freqz(b,a,SR/2,SR);

data_square=smooth(ddf.^2,200);

noise = median(max(reshape(data_square(1:floor(length(data_square)/1e3)*1e3),...
  1e3,[])));

thresh=thesh_mult*noise; %.01
[pks,locs]=findpeaks(data_square,'MINPEAKDISTANCE',min_PI*SR,...
  'MINPEAKHEIGHT',thresh);

for k=1:echo_rem_iterations
  PI=diff(locs/SR)*1e3; %in ms
  peak_ratio=pks(1:end-1)./pks(2:end);
  remove_pks = [false; PI < 15] & [false; peak_ratio > 5];

  locs(remove_pks)=[];
  pks(remove_pks)=[];
end

if nargin > 5 && DIAG
  buffer=.004*SR;
  %indx=1
  for indx=1:-1%length(locs)
    voc=ddf(max(1,locs(indx)-buffer):min(length(ddf),locs(indx)+buffer));
    voc=voc-mean(voc);
    figure(1); plot(voc); axis tight;
    title(num2str(indx))
    N = 1024;
    y = fft(voc,N);
    p = abs(y);
    f=SR/N.*(0:(N/2)-1);
    figure(2);
    plot(f,p(1:N/2)); 
    axis([0 20e3 0 max(p(1:82))]);
    title(num2str(indx))
    
    figure(5); clf;
    [S,F,T,P] = spectrogram(voc,256,250,256,SR);
    imagesc(T,F,10*log10(P)); axis tight; set(gca,'YDir','normal');
        
%     sound(voc,SR/10)
%     pause(2)
  end
  
  figure(3); clf; 
  plot(ddf); axis tight;
  hold on;
  plot(locs,ones(length(locs),1),'*r'); hold off;
  
%   figure(4); clf;
%   [S,F,T,P] = spectrogram(ddf,256,250,256,SR);
%   imagesc(T,F,10*log10(P)); axis tight; set(gca,'YDir','normal');
%   colormap('hot');
%   caxis([-80 -15])
% %   hold on; plot(locs./SR,ones(length(locs),1)*20e3,'w*'); hold off;
%   text(locs./SR,ones(length(locs),1)*20e3,num2str([1:length(locs)]'),...
%     'color','w','horizontalalignment','center')
  
%   sound(ddf,SR/20);

  figure(6); clf;
  plot(data_square); axis tight;
  hold on;
  plot(locs,ones(length(locs),1)*mean(pks),'*r');
  plot([0 length(data_square)],[thresh thresh],'m');
  hold off;
  
  figure(7); clf;
  plot(locs(2:end)/SR,diff(locs/SR)*1e3,'.-')
  axis tight;
end














function extra_stuff

% durations=nan(length(locs),1);
% for k=1:length(locs)
%   durations(k) = sum(data_square(max(1,locs(k)-500):min(locs(k)+500,length(data_square)))>thresh)/SR*1e3;
% end


[x,y]=ginput(1);
[mmmm vv]=min(abs(locs-x));
Y=dd(locs(vv)-2500:locs(vv)+2500); 
max_corr=nan(length(locs),1);
for k=1:length(locs)
  X=dd(locs(k)-2500:locs(k)+2500); 
  max_corr(k)=max(xcorr(X,Y)); 
end

remove_pks = max_corr < 50;

locs(remove_pks)=[];
pks(remove_pks)=[];


% PI=diff(locs/SR)*1e3;
% [false; false; diff(PI)<-60] |
% remove_pks = [false; false; diff(PI)<-60];

% remove_pks = [false; (diff(pks)<-2) & PI < 7]...
%   | [false; false; diff(PI) < -75] ...
%   | [false; PI < 5];
% %   | durations < .17 ...
% % | [false; diff(durations)<-.9] ...
% % remove_pks = [false; (diff(pks)<-2) & PI < 7] | remove_pks';
% 
% locs_removed=locs(remove_pks);
% pks_removed=dd(remove_pks);
% locs(remove_pks)=[];
% pks(remove_pks)=[];

PI=diff(locs)/SR*1e3;

t=-1:1/SR:1;
voc_times=t(locs);

if DIAG
  
  figure(1);clf;
  plot(t,dd);
  hold on;
  plot(t(locs),zeros(length(locs),1)+sqrt(500*min(mnd)),'*r');
%   plot(t(locs_removed),pks_removed,'+y');
  axis tight;
  a=axis;
  
%   plot(t(locs(remove_pks)),zeros(length(locs(remove_pks)),1),'*y');
%   text(t(locs),zeros(length(locs),1)+1,...
%     num2str(durations','%2.2f'),...
%     'horizontalAlignment','center');
%   text(t(locs(2:end)),zeros(length(locs)-1,1)+3,...
%     [num2str(diff(pks),'%22.0f') repmat(', ',length(PI),1) num2str(PI,'%22.0f')],...
%     'horizontalAlignment','center');
  
%   subplot(3,1,2)
  figure(2); clf;
  plot(t(locs(2:end)),PI,'.-')
  axis tight;
  aa=axis;
  axis([a(1:2) aa(3:4)]);
  
%   figure(3);
%   a = [min(dd) max(dd)];
%   step_size=.05*SR;
%   for k=1:step_size/10:length(dd)-step_size
%     clf;
%     tt=(k:k+step_size)/SR;
%     plot(tt,dd(k:k+step_size));
%     hold on;
%     found_locs=locs(locs>=k & locs<=k+step_size);
%     plot(found_locs/SR,ones(length(found_locs),1),'*r');
%     axis([tt(1) tt(end) a]);
%     drawnow;
%     pause(.1)
%   end
  
%   figure(7); plot(t(locs),[0 diff(durations)])
%   figure(8); plot(t(locs),durations)
%   sound(dd,SR/10)
end


% mel's code...
% [onsets_sec, offsets_sec, threshold] = find_pulse_times (dd, SR);

% figure(3); clf; plot(-1:1/SR:1,dd')
% hold on;
% plot(onsets_sec-1,dd(round((onsets_sec)*SR)),'*r')