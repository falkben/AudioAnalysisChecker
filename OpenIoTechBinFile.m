function [fd,h,c] = OpenIoTechBinFile(FN)
%
%	function [fd,h,c] = OpenIoTechBinFile(FN)
%
%	Open an IoTech .bin digital sound file and return a file handle
%	to the raw data (fd), a header structure (h), and a channel
%	structure (c). Header and channel information come from the .dsc
%	file.
%

BPF = 2;	%	Bytes Per Frame

fd = fopen(FN,'r');
fnl = length(FN);
descfile = strcat(FN(1:fnl-3),'dsc');
if isempty(dir(descfile))
    [h,c] = PromptUserForHdrInfo(fd,BPF);
else
    [h,c] = ReadIoTechHeadernewlaptop(descfile);
end
return;


function [HDR,CH]=ReadIoTechHeadernewlaptop(infile)

fd=fopen(infile,'r');
    
hdr(1)=fread(fd,1,'int16');
hdr(2:3)=fread(fd,2,'int32');
hdr(4:5)=fread(fd,2,'float');
hdr(6:7)=fread(fd,2,'int32');
HDR=struct('numChannels',hdr(1),'NumScans',hdr(2),'bcHSdiStatus',hdr(3),...
   'preFreq',hdr(4),'postFreq',hdr(5),'PreCount',hdr(6),'packed',hdr(7));

for i = 1:HDR.numChannels
   ch{i,1} = fread(fd,1,'float');
   ch{i,2} = fread(fd,1,'float');
   ch{i,3} = fread(fd,1,'float');
   ch{i,4} = fread(fd,1,'int32');
   ch{i,5} = fread(fd,1,'float');
   ch{i,6} = transpose(char(fread(fd,9,'char')));
   ch{i,7} = transpose(char(fread(fd,9,'char')));
end

CH=struct('GainValue',ch(:,1),'m',ch(:,2),'b',ch(:,3),'bipolar',ch(:,4),...
   'uniAdder',ch(:,5),'label',ch(:,6),'units',ch(:,7));
fclose(fd);

return












