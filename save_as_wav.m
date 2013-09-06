clear


main_dir= ['E:\Data Stage USA\Floor_mics' '\'];
sub_dir = dir(main_dir);


files={};
for D = 1 :length(sub_dir)
    if ~strcmp('.',sub_dir(D).name)&& ~strcmp('..',sub_dir(D).name)
        sub_dir_2 = dir([main_dir sub_dir(D) '\']);
        
        for DD = 1 : length(subdir_2)
            if ~strcmp('.',sub_dir_2(DD).name)&& ~strcmp('..',sub_dir_2(DD).name)
                
                audio_dir=[main_dir sub_dir(D) sub_dir_2(DD).name '\'];
                fnames=dir([audio_dir '*.mat']);
                
                mkdir('E:\Data Stage USA\zz_WAV_floor_mics\',[sub_dir(D).name]);
                mkdir(['E:\Data Stage USA\zz_WAV_floor_mics\' sub_dir(D).name], sub_dir_2(DD).name);
                
                files_indx=[];
                for ii = 1 : length(fnames)
                    h=strfind(fnames(ii).name,'_processed');
                    if isempty(h)
                        files_indx(end+1)=ii;
                    end
                end
                
                for jj = 1:length(files_indx)
                    
                    files{jj}= fnames(files_indx(jj));
                    
                end
                
                done = 0;
                
                for i = 1 : length(files)
                    
                    %         if done~=1
                    %             k = questdlg(['Do you want to save the file: ' files{i}.name '?']);
                    
                    %             if strcmp(k,'Yes')
                    
                    audio = load([audio_dir files{i}.name]);
                    
                    data=[];
                    data(:,1)=audio.data(:,1);
                    data(:,1)=audio.data(:,2);
                    
                    
                    
                    wavwrite(data,24000,['E:\Data Stage USA\zz_WAV_floor_mics\' sub_dir(D).name '\' sub_dir_2(DD).name '\' files{i}.name(1:end-4)  '.wav']);
                    
                    %             end
                    
                    %             kk=questdlg('Go to the next file?');
                    
                    %             if strcmp(kk,'No')
                    
                    %                 done = 1;
                    
                    %             end
                end
            end
        end
    end
    
end

