function pos_fn = get_vicon_trialcode_from_data_detect(fn)
%bat_pos order
%species_yyyymmdd_band_trialnum_bat_pos.mat

%data_detect_order
%species_yyyymmdd_band_trialnum_mic_data_detect.mat

C=strsplit(fn,'_mic_data_detect.mat');
pos_fn = [C{1} '_bat_pos.mat'];
