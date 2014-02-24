clear;

making_video=1;
play_fps=30;

caxislev=[-85 -40];

ffmpeg_dir = 'F:\video_tools\ffmpeg_self_compiled\bin\ffmpeg.exe';

[fn,pn]=uigetfile('*.wav');
[data,Fs]=audioread([pn fn]);
SR=250e3;

figure(42);clf; set(gcf,'color','black');
colordef black
set(gcf,'position',[10 50 1000 600])
set(gca,'position',[0 0 1 1]);
box on;

[S,F,T,P]=spectrogram(data,128,120,2e3,SR);

aa=subaxis(2,1,1,'M',.01,'ml',.05);
plot((1:length(data))./SR,data(1:end),'w');
set(gca,'xtickLabel','')
axis tight;
a=axis;
axis([a(1:2) -1 1])
hold on;

bb=subaxis(2,1,2,'M',.01,'ml',.05);
imagesc(T,F,10*log10(P)); axis xy;
colormap(hot);
set(gca,'xticklabel','','ytick',0:40e3:125e3,'ytickLabel',0:40:125)
caxis(caxislev);
hold on;

linkaxes([aa bb],'x')

a=axis;


if making_video
  writerObj = VideoWriter([pn fn(1:end-3) 'avi'],...
    'Uncompressed AVI');
  writerObj.FrameRate = play_fps;
  open(writerObj);
end


tt=(0:length(data))./Fs;

frames=1:play_fps*tt(end);

gg=0;
hh=0;
for f=frames
  [~,ii]=min(abs(tt-f/play_fps));
  if gg~=0
    delete(gg);
  end
  gg=plot(aa,[ii ii]./SR,[-1 1],'b','linewidth',2);

  if hh~=0
    delete(hh);
  end
  hh=plot(bb,[ii ii]./SR,[a(3) a(4)],'b','linewidth',2);
  

  if making_video
    grabbed = getframe(gcf);
    writeVideo(writerObj,grabbed);
  else
    drawnow;
  end
end
if making_video
  close(writerObj);
end

system([ffmpeg_dir...
  ' -y -i ' pn fn(1:end-3) 'avi' ...
  ' -i ' pn fn ...
  ' -c:v libxvid -q:v 3 '...
  ' -c:a libfaac -ac 1 '...
  pn fn(1:end-3) 'mp4'...
  ])

delete([fnames{ff}(1:end-3) 'avi']);

colordef white
