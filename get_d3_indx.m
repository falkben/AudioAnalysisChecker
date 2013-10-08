function d3_indx=get_d3_indx(d3_fnames,tcode)

d3_indx=find(~cellfun(@isempty,strfind(d3_fnames,tcode)));