%from audio full path
function trialcode = determine_vicon_trialcode(fname)

slashes = strfind(fname,'\');

bat = fname(slashes(3)+1:slashes(4)-1);
date = datevec(fname(slashes(4)+1:end-7),'dd-mmm-yyyy');
num=fname(slashes(4)+13:end-4);

load([getpref('audioanalysischecker','marked_voc_pname') 'data_sheet.mat']);

bat_indx=~cellfun(@isempty,strfind(data_sheet(:,2),bat));
date_indx=~cellfun(@isempty,strfind(data_sheet(:,1),...
  [num2str(date(2)) '/' num2str(date(3)) '/' num2str(date(1))]));
num_indx=cellfun(@ (c) isequal(str2double(num),c),data_sheet(:,4));

indx=bat_indx&date_indx&num_indx;
if ~isempty(find(indx,1))
  vicon_num=data_sheet{indx,4};
  trialcode=[bat '.' datestr(date,'yyyymmdd') '.' num2str(vicon_num,'%02d')];
else
  trialcode=0;
end