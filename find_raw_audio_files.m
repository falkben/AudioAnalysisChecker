function [raw_audio_dir,audio_fnames]=find_raw_audio_files(raw_audio_dir,processed_audio_fnames,duration_fnames)

files=dir([raw_audio_dir '\*.mat']);
audio_fnames = setdiff({files.name},[processed_audio_fnames'; duration_fnames']);
if isempty(audio_fnames)
  files=dir([raw_audio_dir '\*.bin']);
  audio_fnames = {files.name};
end
if isempty(audio_fnames)
  disp('no audio files found, trying to load a different folder')
  raw_audio_dir=uigetdir(raw_audio_dir,...
    'Select the folder for the raw audio files');
  if isequal(raw_audio_dir,0)
    return
  end
  [raw_audio_dir,audio_fnames]=find_raw_audio_files(raw_audio_dir...
    ,processed_audio_fnames,duration_fnames);
end