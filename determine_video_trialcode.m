%from audio full path
function trialcode = determine_video_trialcode(fname)
trialcode=0;

[pathstr, name, ext] = fileparts(fname);
load([getpref('audioanalysischecker','sound_data_pname') 'data_sheet.mat']);

if strcmp(ext,'.bin')
  %determine bat from pathstr
  slashes = strfind(pathstr,'\');
  colons = strfind(pathstr,':');
  %find root directory
  matches={};
  for k=2:length(slashes)
    matches{k} = find(strcmp(data_sheet(:,4),pathstr(colons(1)+1:slashes(k))));
  end
  correct_k=find(~cellfun(@isempty,matches),1,'last');
  last_match = matches{correct_k};
%   matches = strcmp(data_sheet(:,4),pathstr(colons(1)+1:slashes(k-1)));
  if correct_k < length(slashes)
    row_match = strcmp(data_sheet(last_match,5),...
      pathstr(slashes(correct_k)+1:slashes(correct_k+1)));
  else
    row_match = strcmp(data_sheet(last_match,5),...
      [pathstr(slashes(correct_k)+1:end) '\']);
  end
  bat = data_sheet{last_match(row_match),1};
  if strcmp(name([5 6]),'00')
    name([5 6])='08';
  end
  trialcode = [bat '.20' name([5 6 3 4 1 2]) '.' name(7:8)];
%   trialcode = [bat '.20' name(1:2) name(3:4) name(5:6) '.' name(7:8)];
elseif strcmp(ext,'.mat')
  slashes = strfind(fname,'\');
  
  bat = fname(slashes(end-1)+1:slashes(end)-1);
  date = datevec(fname(slashes(end)+1:end-7),'dd-mmm-yyyy');
  num=fname(slashes(end)+13:end-4);

  bat_indx=~cellfun(@isempty,strfind(data_sheet(:,2),bat));
  date_indx=~cellfun(@isempty,strfind(data_sheet(:,1),...
    [num2str(date(2)) '/' num2str(date(3)) '/' num2str(date(1))]));
  num_indx=cellfun(@ (c) isequal(str2double(num),c),data_sheet(:,3));

  indx=bat_indx&date_indx&num_indx;
  if ~isempty(find(indx,1))
    vicon_num=data_sheet{indx,4};
    trialcode=[bat '.' datestr(date,'yyyymmdd') '.' num2str(vicon_num,'%02d')];
  end
end

