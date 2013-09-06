function [d3_indx]=get_d3_indx(processed_audio_files,d3_files)

d3_indx =[];

   
    undr = strfind(processed_audio_files(1).name,'_');
    dot = strfind(processed_audio_files(1).name,'.');
    bat_band = processed_audio_files(1).name(dot(3)+1:undr(1)-1);
    date_dot = processed_audio_files(1).name(1:dot(3)-1);
    date=strrep(date_dot,'.','-');

    for i = 1 : length(d3_files)
        
        if ~isempty(strfind(d3_files(i).name,bat_band))&&~isempty(strfind(d3_files(i).name,date))
            d3_indx(end+1)=i;
        end

    end
    
end

