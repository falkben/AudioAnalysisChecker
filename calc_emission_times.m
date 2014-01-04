function emission_t = calc_emission_times(D,t,voc_t)
%D: distance between bat and microphone
%t: frame times for bat location
%voc_t: voc time on microphone

c=344;

delays_at_bat = D/c;
t_at_mike = t' + D/c;

delay=nan(length(voc_t),1);
for v=1:length(voc_t)
  voc=voc_t(v);

  d_indx = find( (t_at_mike - voc) < 0 , 1 , 'last');
  if ~isempty(d_indx)
    delay(v) = delays_at_bat(d_indx);
  end
end

emission_t = voc_t - delay;