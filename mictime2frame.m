%get the emmission times as frames for all vocalizations
function [bat_frame, emission_t] = mictime2frame(DataArray,bat,mic,fvideo,trialstart)

bat_t=((0:size(bat,1)-1)+trialstart)./fvideo;

d2m = distance2(bat,mic); %calc. dist. betw. bat and microphone
tof = d2m/343; %calc. time-of-flight between bat and microphone at bat pos. (dist/343=sec)
tom = bat_t + tof'; %convert bat times to time on microphone

bat_frame=nan(size(DataArray,1),1);
emission_t=nan(size(DataArray,1),1);
for g=1:size(DataArray,1)
  poss_mic_times=tom(DataArray(g,1)-tom > 0);
  if ~isempty(poss_mic_times)
    [M fff] = min(abs(DataArray(g,1) - tom));
%     hold on;
%     plot(bat_t(fff)*fvideo,M,'*')
    if M <= 1/fvideo
      bat_frame(g)=round(bat_t(fff)*fvideo);
      emission_t(g)=DataArray(g,1) - tof(fff);
    end
  end
end
% plot([bat_t(1)*fvideo bat_t(end)*fvideo],[1/fvideo 1/fvideo],'--g');

% figure; plot3(bat(:,1),bat(:,2),bat(:,3),'r'); axis square; grid on;