function [Chnls,Frame] = ReadChnlsFromFile(fd,h,c,Size,Frame)

if ~(Frame == 0)
   fseek(fd,Frames2Bytes(Frame,h),-1);
else
   if Size > (h.NumScans-Bytes2Frames(ftell(fd),h))
      FfwdToEnd(fd,h,Size);
   end
	Frame = Bytes2Frames(ftell(fd),h);
end   
WhichFrame(Frame);
Buff = fread(fd,Frames2Bytes(Size,h)/2,'int16');
for i = 1:h.numChannels
   Chnls{i} = Buff(i:h.numChannels:length(Buff));
	%	Convert to real-unit values.
	Chnls{i} = ((Chnls{i}.*(5.0/c(i).GainValue)./32768)+c(i).uniAdder)*c(i).m+c(i).b;
end
return;

function Bytes = Frames2Bytes(Frames,h)

Bytes = Frames*h.numChannels*2;

function CurFrame = WhichFrame(varargin)

persistent TheFrame;

if (nargin==0)
   CurFrame = TheFrame;
   return;
else
   CurFrame = TheFrame;
   TheFrame = varargin{1};
   return;
end