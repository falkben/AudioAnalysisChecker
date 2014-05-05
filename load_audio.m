function [waveforms,Fs,length_t,waveform_y_range]=load_audio(pathname,filename,exportwav)

if nargin<2
  if ispref('audioanalysischecker','audio_pname') &&...
      exist(getpref('audioanalysischecker','audio_pname'),'dir')
    pathname=getpref('audioanalysischecker','audio_pname');
  else
    pathname='';
  end
  
  [filename,pathname]=uigetfile({'*.mat;*.bin;*.wav'},...
    'Load audio file',pathname);
  if isequal(pathname,0)
    return
  end
end

[~,~,ext]=fileparts([pathname filename]);

%determine which file it is from the filename
if strcmp(ext,'.mat') %loading from nidaq_matlab_tools
  warning('off','MATLAB:loadobj');
  audio=open([pathname '\' filename]);
  warning('on','MATLAB:loadobj');
  waveforms = audio.data;
  Fs = audio.SR;
  length_t = audio.pretrigger;
  waveform_y_range = [min(min(audio.inputranges,[],2))...
    max(max(audio.inputranges,[],2))];
elseif strcmp(ext,'.bin') %loading from wavebook
  [fd,h,c] = OpenIoTechBinFile([pathname '\' filename]);
  Fs = h.preFreq;
  length_t=h.PreCount/Fs;
  waveforms = ReadChnlsFromFile(fd,h,c,length_t*Fs,1);
  waveforms=cell2mat(waveforms);
  waveform_y_range = [min(floor(min(waveforms)))...
    max(ceil(max(waveforms)))];
elseif strcmp(ext,'.wav')
  [waveforms,Fs]=audioread([pathname filename]);
  length_t=size(waveforms,1)./Fs;
  waveform_y_range=[-1 1];
end

if nargin>2 && exportwav
  audiowrite([pathname filename(1:end-3) 'wav'],waveforms./abs(max(waveform_y_range)),Fs);
end