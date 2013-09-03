%run this script twice
%once for eliminating any incorrect durations
%second for manually adding durations to skipped vocs

clear;

bat_band='BK57';
% BK59 OR40 B52 B57 BK53 OR44 P72 W50
data_year=2008;
[d3_fnames, d3_path, ~, ~, ~, ~, ~, ~, ~, data_year, ...
  wavebook_path, wavebook_naming,~,processed_audio_dir]...
  =return_processed_file_names(bat_band,data_year);

processed_audio_files=dir([processed_audio_dir '*_duration.mat']);
processed_audio_fnames={processed_audio_files.name};

d=dir(wavebook_path);
isub = [d(:).isdir];
audio_dir = {d(isub).name}';
audio_dir(ismember(audio_dir,{'.','..'})) = [];
if isempty(audio_dir)
  audio_dir{1}='';
end
for dd=1:length(audio_dir)
  pathname=[wavebook_path audio_dir{dd}];
  files=dir([pathname '\*.bin']);
  for k=1:length(files)
    WB_fname = files(k).name;
    proc_fname_indx = find(~cellfun(@isempty,strfind(processed_audio_fnames,...
      WB_fname(1:end-4))));
    if ~isempty(proc_fname_indx)
      load([processed_audio_dir processed_audio_fnames{proc_fname_indx}])
      if ~isfield(trial_data,'duration_data_audit')
        [fd,h,c] = OpenIoTechBinFile([pathname '\' WB_fname]);
        Fs = h.preFreq;
        pretrig_t = h.PreCount/Fs;
        waveforms = ReadChnlsFromFile(fd,h,c,pretrig_t*Fs,1);
        waveform = waveforms{trial_data.ch};
        disp('Type Enter/Return to keep vocalization, minus to delete voc, ESC to quit');
        
        new_duration_data = trial_data.duration_data;
        vv_indx=find(~isnan(trial_data.duration_data(:,2)))';
        vv=1;
        while vv <= length(vv_indx)
          voc_s = trial_data.duration_data(vv_indx(vv),2);
          voc_e = trial_data.duration_data(vv_indx(vv),3);
          buffer_s = round((2e-3).*Fs);
          buffer_e = round((2e-3).*Fs);
          samp_s = round((voc_s + pretrig_t).*Fs);
          samp_e = round((voc_e + pretrig_t).*Fs);
          voc = waveform(max(1,samp_s):samp_e);
          
          clf;
          
          hh(1)=subplot(2,1,1); cla;
          voc_p = waveform(max(1,samp_s-buffer_s):min(samp_e+buffer_e,length(waveform)));
          plot((1:length(voc_p))./Fs,voc_p);
          hold on;
          plot([buffer_s buffer_s]./Fs,[min(voc_p) max(voc_p)],'r')
          plot([buffer_s+samp_e-samp_s buffer_s+samp_e-samp_s]./Fs,...
            [min(voc_p) max(voc_p)],'r')
          axis tight;
          aa=axis;
          hold off;
          
          hh(2)=subplot(2,1,2); cla;
          [~,F,T,P] = spectrogram(voc_p,128,120,512,Fs);
          imagesc(T,F,10*log10(P)); set(gca,'YDir','normal');
          set(gca,'clim',[-95 -30]);
          %         colormap jet
          %         colorbar
          hold on;
          axis tight;
          aaa=axis;
          plot([buffer_s buffer_s]./Fs,[0 Fs/2],'r')
          plot([buffer_s+samp_e-samp_s buffer_s+samp_e-samp_s]./Fs,...
            [0 Fs/2],'r')
          axis([aa(1:2) aaa(3:4)]);
          hold off;
          
          linkaxes(hh,'x');
          
          reply = getkey;
          while ischar(reply) || isempty(~find(reply==[13 45 27 28 29]))
            disp('neither return or minus were pressed, ESC to quit');
            reply = getkey;
          end
          switch reply
            case {13, 29} %return or right arrow, keep voc
              new_duration_data(vv_indx(vv),2:3)=...
                trial_data.duration_data(vv_indx(vv),2:3);
              vv=vv+1;
            case 45 % delete voc
              new_duration_data(vv_indx(vv),2:3)=nan;
              vv=vv+1;
            case 27 %ESC
              disp(['On voc: ' num2str(vv_indx(vv)) ' file ' num2str(k) ...
                ' dir ' num2str(dd)]);
              return;
            case 28 %going backwards
              vv=vv-1;
          end
          if vv < 1
            vv=1;
          elseif vv > length(vv_indx)
            disp('saving, press ESC to cancel, BACK to go back, any other key to continue')
            reply = getkey;
            if isequal(reply, 28)
              vv=vv-2;
            elseif ~isequal(reply, 27)
              trial_data.duration_data_audit = new_duration_data;
              save([processed_audio_dir processed_audio_fnames{proc_fname_indx}],'trial_data');
            end
          end
        end
        %we've audited but not added the ones in that we missed...
      elseif (~isfield(trial_data,'manual_additions')...
          || trial_data.manual_additions ~= 1)
        load([processed_audio_dir processed_audio_fnames{proc_fname_indx}])
        [fd,h,c] = OpenIoTechBinFile([pathname '\' WB_fname]);
        Fs = h.preFreq;
        pretrig_t = h.PreCount/Fs;
        waveforms = ReadChnlsFromFile(fd,h,c,pretrig_t*Fs,1);
        waveform = waveforms{trial_data.ch};
        disp(['On file ' num2str(k) ' of ' num2str(length(files)) ...
          ' and dir ' num2str(dd) ' of ' num2str(length(audio_dir))]);
        voc_ts = trial_data.duration_data(:,1);
        audit_vocs = ~isnan(trial_data.duration_data_audit(:,2));
        remaining_vocs_indx = find(~audit_vocs);
        
        new_duration_data = nan(length(remaining_vocs_indx),3);
        for vv=1:length(remaining_vocs_indx)
          buffer_s = round((10e-3).*Fs);
          buffer_e = round((14e-3).*Fs);
          voc_time = voc_ts(remaining_vocs_indx(vv));
          voc_samp = round((voc_time + pretrig_t)*Fs);
          voc=waveform(max(1,voc_samp-buffer_s):min(voc_samp+buffer_e,length(waveform)));
          
          clf;
          
          hh(1)=subplot(2,1,1); cla;
          plot((1:length(voc))./Fs,voc);
          hold on;
          plot(buffer_s/Fs,0,'*g');
          axis tight;
          aa=axis;
          hold off;
          
          hh(2)=subplot(2,1,2); cla;
          [~,F,T,P] = spectrogram(voc,128,120,512,Fs);
          imagesc(T,F,10*log10(P)); set(gca,'YDir','normal');
          set(gca,'clim',[-95 -30]);
          hold on;
          axis tight;
          aaa=axis;
          
          axis([aa(1:2) aaa(3:4)]);
          hold off;
          
          linkaxes(hh,'x');
          
          disp('press Return to ignore voc');
          [x,~]=ginput(2);
          if ~isempty(x) && diff(x)>0
            voc_s = voc_time - buffer_s/Fs + x(1);
            voc_e = voc_time - buffer_s/Fs + x(2);
            new_duration_data(vv,:) = [voc_time voc_s voc_e];
          end
        end
        trial_data.duration_data_audit(~audit_vocs,:) = new_duration_data;
        trial_data.manual_additions = 1;
        save([processed_audio_dir processed_audio_fnames{proc_fname_indx}],'trial_data');
      end
    end
  end
end