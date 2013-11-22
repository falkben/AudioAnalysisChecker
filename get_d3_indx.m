function d3_indx=get_d3_indx(d3_fnames,tcode)

dot=strfind(tcode,'.');
if length(dot)> 2 %clements file naming...
  undr=strfind(tcode,'_');
  date=strrep(tcode(1:dot(3)-1),'.','-');
  trial=tcode(end-1:end);
  band=tcode(dot(3)+1:undr(1)-1);
  d3name=[date '.trial.' trial '.' band '_d3.mat'];
  d3_indx=find(~cellfun(@isempty,strfind(d3_fnames,d3name)));
else
  d3_indx=find(~cellfun(@isempty,strfind(d3_fnames,tcode)));
end