%this function uses data from audited files to create a fitted function
%that maps the intensity of the voc with the appropriate threshold
function create_threshold_fit

DIAG=0;

if exist('data_folders.mat','file')
  load('data_folders.mat');
else
  data_folders={};
  cont=1;
  prev_fold=[];
  while cont
    prev_fold=uigetdir(prev_fold,'Pick folder for proc duration files');
    if isequal(prev_fold,0)
      cont=0;
    else
      data_folders{end+1}=prev_fold;
    end
  end
end

% base='F:\eptesicus_forest_collab\lasse_forest_exploration\';
% addpath(base);

allthresh1=[];
allthresh2=[];
allI=[];

for k=1:length(data_folders)
  if isempty(dir([data_folders{k} '\*duration.mat']))
    dur_files=dir([data_folders{k} '\*data_detect.mat']);
    
    
    thresh1=cell(length(dur_files),1);
    thresh2=cell(length(dur_files),1);
    I=cell(length(dur_files),1);
    for g=1:length(dur_files)
      trial_data = load([data_folders{k} '\' dur_files(g).name]);
      if trial_data.dur_marked
        afname = strrep(dur_files(g).name,'_detect','');
        
        load([data_folders{k} '\' afname])
        
        waveform = sig(:,trial_data.chsel);
        
        [b,a] = butter(6,12e3/(fs/2),'high');
        ddf=filtfilt(b,a,waveform);
        data_square = smooth((ddf.^2),100);
        
        [low_b, low_a]=butter(6,30e3/(fs/2),'high');
        waveform_high=filtfilt(low_b,low_a,waveform);
        data_square_high=smooth((waveform_high.^2),100);
        
        [low_b, low_a]=butter(6,30e3/(fs/2),'low');
        waveform_low=filtfilt(low_b,low_a,ddf);
        data_square_low=smooth((waveform_low.^2),100);
        
        onsets=[trial_data.call.call_start_idx];
        offsets=[trial_data.call.call_end_idx];
        
        pk=nan(length(onsets),1);
        val_s=nan(length(onsets),1);
        val_e=nan(length(onsets),1);
        for vv=find(isfinite(onsets))'
          buff=1e2;
          starts=onsets(vv);
          stops=offsets(vv);
          locs=buff;
          loce=buff+(stops-starts+1);

          pk(vv)=max(data_square(max(1,starts-buff):min(stops+buff,length(data_square))));
          val_s(vv)=data_square_high(starts);
          val_e(vv)=data_square_low(stops);

          if DIAG
            figure(1);clf;
            subplot(3,1,1)
            plot(waveform(starts-buff:stops+buff));
            hold on;
            plot([locs loce],[0 0],'*g');

            subplot(3,1,2)
            plot(data_square_high(starts-buff:stops+buff));
            hold on;
            plot(locs,data_square_high(starts-buff+locs),'*g');

            subplot(3,1,3)
            plot(data_square_low(starts-buff:stops+buff));
            hold on;
            plot(loce,data_square_low(starts-buff+loce),'*g');
          end
        end
      end
      
      thresh1{g}=val_s(~isnan(val_s));
      thresh2{g}=val_e(~isnan(val_e));
      I{g}=pk(~isnan(val_e));
    end
    allthresh1=[allthresh1; cell2mat(thresh1)];
    allthresh2=[allthresh2; cell2mat(thresh2)];
    allI=[allI; cell2mat(I)];
  else
    dur_files=dir([data_folders{k} '\*duration.mat']);
    load([data_folders{k} '\' dur_files(1).name]);
    dots=strfind(trial_data.trialcode,'.');
    %to properly load the data files, adjust for different file locations
    [~,~,~,~,~,~,~,~,~,~,wavebook_path]=...
      return_processed_file_names(trial_data.bat,...
      str2double(trial_data.trialcode(dots(1)+1:dots(1)+4)));
    afiles=dir([base wavebook_path '*.bin']);
    
    thresh1=cell(length(dur_files),1);
    thresh2=cell(length(dur_files),1);
    I=cell(length(dur_files),1);
    for g=1:length(dur_files)
      load([data_folders{k} '\' dur_files(g).name]);
      if trial_data.manual_additions
        afname=[dur_files(g).name(1:end-23) '.bin'];
        ii=find(~cellfun(@isempty,strfind({afiles.name},afname)));
        if ~isempty(ii)
          afullname = ([base wavebook_path afiles(ii).name]);
          
          %load in the audio files
          [fd,h,c] = OpenIoTechBinFile(afullname);
          Fs = h.preFreq;
          pretrig_t = h.PreCount/Fs;
          waveforms = ReadChnlsFromFile(fd,h,c,pretrig_t*Fs+.2*Fs,1);
          waveform = waveforms{trial_data.ch};
          
          [b,a] = butter(6,12e3/(Fs/2),'high');
          ddf=filtfilt(b,a,waveform);
          data_square = smooth((ddf.^2),100);
          
          [low_b, low_a]=butter(6,30e3/(Fs/2),'high');
          waveform_high=filtfilt(low_b,low_a,waveform);
          data_square_high=smooth((waveform_high.^2),100);
          
          [low_b, low_a]=butter(6,30e3/(Fs/2),'low');
          waveform_low=filtfilt(low_b,low_a,ddf);
          data_square_low=smooth((waveform_low.^2),100);
          
          onsets=trial_data.duration_data_audit(:,2);
          offsets=trial_data.duration_data_audit(:,3);
          
          pk=nan(length(onsets),1);
          val_s=nan(length(onsets),1);
          val_e=nan(length(onsets),1);
          for vv=1:length(onsets)
            if ~isnan(onsets(vv))
              buff=1e2;
              starts=round((onsets(vv)+pretrig_t)*Fs);
              stops=round((offsets(vv)+pretrig_t)*Fs);
              locs=buff;
              loce=buff+(stops-starts+1);
              
              pk(vv)=max(data_square(max(1,starts-buff):min(stops+buff,length(data_square))));
              val_s(vv)=data_square_high(starts);
              val_e(vv)=data_square_low(stops);
              
              if DIAG
                figure(1);clf;
                subplot(3,1,1)
                plot(waveform(starts-buff:stops+buff));
                hold on;
                plot([locs loce],[0 0],'*g');
                
                subplot(3,1,2)
                plot(data_square_high(starts-buff:stops+buff));
                hold on;
                plot(locs,data_square_high(locs),'*g');
                
                subplot(3,1,3)
                plot(data_square_low(starts-buff:stops+buff));
                hold on;
                plot(loce,data_square_low(loce),'*g');
              end
            end
          end
        end
      end
      
      thresh1{g}=val_s(~isnan(val_s));
      thresh2{g}=val_e(~isnan(val_e));
      I{g}=pk(~isnan(val_e));
    end
    allthresh1=[allthresh1; cell2mat(thresh1)];
    allthresh2=[allthresh2; cell2mat(thresh2)];
    allI=[allI; cell2mat(I)];
  end
  
end


outliers1=allthresh1 > 10*std(allthresh1);
[p1,S] = polyfit(allI(~outliers1),allthresh1(~outliers1),2);

outliers2=allthresh2 > 10*std(allthresh2);
[p2,S] = polyfit(allI(~outliers2),allthresh2(~outliers2),1);

pk_vs_thresh1.coeff = p1;
pk_vs_thresh2.coeff = p2;

if DIAG
  
  figure(2); clf;
  scatter(allI(~outliers1),allthresh1(~outliers1));
  a=axis;
  xx=linspace(a(1),a(2),100);
  yy=polyval(pk_vs_thresh1.coeff,xx);
  hold on;
  plot(xx,yy,'r');
  
  figure(3); clf;
  scatter(allI(~outliers2),allthresh2(~outliers2));a=axis;
  xx=linspace(a(1),a(2),100);
  yy=polyval(pk_vs_thresh2.coeff,xx);
  hold on;
  plot(xx,yy,'r');
end

save([data_folders{k} '\' 'duration_threshold_fit.mat'],'pk_vs_thresh1','pk_vs_thresh2');
