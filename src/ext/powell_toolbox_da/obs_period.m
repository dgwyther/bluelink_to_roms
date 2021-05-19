function obs = obs_period( obs, start_time, end_time )

% 
% obs = obs_period( obs, start_time, end_time )
%
% Cut out all observations outside of the time period

l = find( obs.survey_time < start_time | obs.survey_time > end_time );
if ( ~isempty(l) )
  % Mark the periods as nan
  for i=1:length(l),
    obs.time(find( obs.time == obs.survey_time(l(i)) )) = nan;
  end
  obs.survey_time(l) = nan;
  l = find( ~isnan( obs.survey_time ) );
  obs = delstruct( obs, l, length(obs.survey_time) );
  l = find( ~isnan( obs.time ) );
  obs = delstruct( obs, l, length(obs.time) );
  obs.survey = length(obs.survey_time);
end
