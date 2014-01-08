Steps to automatically marking calls with this software.

1. Extract the vocalization times using extract_vocs_across_files_cc.m
  a. Expects bat band to be a part of the filename for .mat files
  b. Doesn't load .bin files (exclusive to only this part of the code)
	c. creates a sound_data.mat struct file, containing each audio file's auto-marked voc times
2. For each file, run AudioAnalysisChecker to make sure ea. voc is correctly marked and that none are skipped
  a. Outputs a '_processed.mat' file in the same folder as each data file
3. To get onset/offest of each voc, run extract_dur_across_files.m
  a. Outputs a '_processed_duration.mat' file in the same folder as each data file
4. Audit the onsets/offsets of each voc:
  a. check_duration_marking.m (marking good durations/bad durations)
  b. audit_duration.m (for each bad duration or unmarked duration, manually mark)
  
The end result is '_processed_duration.mat' files for each trial with duration_data_audit and manual_additions in that file