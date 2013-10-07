% the base directory is where you have your .mat files from the floor mics.
% base_dir='E:\Data Stage USA\Floor_mics\Baseline_data_forest\';
if ispref('audioanalysischecker') && ispref('audioanalysischecker','audio_pname')...
    && exist(getpref('audioanalysischecker','audio_pname'),'dir')
  base_dir_def=getpref('audioanalysischecker','audio_pname');
else
  base_dir_def=[];
end
base_dir=uigetdir(base_dir_def,...
  'Select the directory of the recorded sound files');
if isequal(base_dir,0)
  return;
end
files=dir([base_dir '\*.mat']);

% this is the folder where you want to save the sound_data file for all the
% trials in the base_dir directory
% sound_data_dir = 'C:\Users\Clément\Desktop\Sound_data\Baseline_forest\R20\';
if ispref('audioanalysischecker') && ispref('audioanalysischecker','sound_data_pname')...
    && exist(getpref('audioanalysischecker','sound_data_pname'),'dir')
  sound_data_dir_def=getpref('audioanalysischecker','sound_data_pname');
else
  sound_data_dir_def=[];
end
sound_data_dir = uigetdir(sound_data_dir_def,...
  'Select the directory for your sound_data.mat file');
if isequal(sound_data_dir,0)
  return;
end

prompt = 'Enter bat band exactly as in the filenames:';
dlg_title = 'Bat';
num_lines = 1;
def = {''};
bat_band = inputdlg(prompt,dlg_title,num_lines,def);
if isequal(bat_band,'') || isequal(bat_band,{})
  return
end
files = files(~cellfun(@isempty,strfind({files.name},cell2mat(bat_band))));

extracted_sound_data=struct('voc_t',[],'trialcode',[],'bat',[],...
  'voc_checked',[],'voc_checked_time',[],'d3_start',[],'d3_end',[]);
for k=1:length(files)
  warning('off','MATLAB:loadobj');
  load([base_dir '\' files(k).name]);
  warning('on','MATLAB:loadobj');
  
  trialcode = files(k).name(1 : end -4);
  bat_band=files(k).name(12 : end-7);
  for ch=1:size(data,2)-1
    [locs]=extract_vocs(data(:,ch),SR,2,.005,2,0);
    length_t = pretrigger;
    
    trt_data=[];
    trt_data.voc_t=locs./SR - length_t;
    trt_data.trialcode=trialcode;
    trt_data.bat=bat_band;
    trt_data.voc_checked=[];
    trt_data.voc_checked_time=[];
    trt_data.ch = ch;
    trt_data.d3_start =[];
    trt_data.d3_end=[];
    if k>1
      extracted_sound_data(end+1) = trt_data;
    else
      extracted_sound_data=trt_data;
    end
    save([sound_data_dir '\sound_data.mat'],'extracted_sound_data');
  end
  disp(['completed file ' num2str(k) ' of ' num2str(length(files))]);
end