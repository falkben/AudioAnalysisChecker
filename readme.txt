Steps to automatically marking calls with this software.

1. Extract the vocalization times using extract_vocs_across_files_cc.m
  a. Expects bat band to be a part of the filename for .mat files
  b. Doesn't load .bin files (exclusive to only this part of the code)
  c. Outputs '_processed.mat' files in the same folder as the data files
2. For each file, run AudioAnalysisChecker to make sure ea. voc is correctly marked
3. To get onset/offest of each voc, run extract_dur_across_files.m
4. Audit the onsets/offsets of each voc:
  a. check_duration_marking.m (marking good durations/bad durations)
  b. audit_duration.m (for each bad duration or unmarked duration, manually mark)
  
Output: .mat files with onsets/offsets of vocalizations