function obs = obs_merge( files, dt, times )

%
% obs = obs_merge( files, dt )
%
% Given a cell array of netcdf observation files, combine them into
% a single observation structure. The dt argument is the minimum amount
% of time that surveys must be separated by (MUST BE GREATER THAN DT OF
% YOUR MODEL CONFIGURATION). Surveys that are closer than dt together
% will be combined.
%
% On exit, a new structure is returned which can be written to disk.
%
% SEE obs_write, obs_read
%
% Written by Brian Powell

if ( nargin < 3 )
  times=[0 9e15];
end
obs.variance     = nc_varget(char(files(1)), 'obs_variance');
obs.type         = nc_varget(char(files(1)), 'obs_type');
obs.time         = nc_varget(char(files(1)), 'obs_time');
obs.depth        = nc_varget(char(files(1)), 'obs_depth');
obs.x            = nc_varget(char(files(1)), 'obs_Xgrid');
obs.y            = nc_varget(char(files(1)), 'obs_Ygrid');
obs.z            = nc_varget(char(files(1)), 'obs_Zgrid');
obs.error        = nc_varget(char(files(1)), 'obs_error');
obs.value        = nc_varget(char(files(1)), 'obs_value');
obs.lat          = obs.x * 0;
obs.lon          = obs.x * 0;
obs.provenance   = obs.x * 0;
obs.meta         = obs.x * 0;
try
  obs.lat        = nc_varget(char(files(1)), 'obs_lat');
  obs.lon        = nc_varget(char(files(1)), 'obs_lon');
  obs.provenance = nc_varget(char(files(1)), 'obs_provenance');
  obs.meta       = nc_varget(char(files(1)), 'obs_meta');
end
l=find(obs.time >= times(1) & obs.time <= times(2));
obs=delstruct(obs,l,length(obs.time));

for f=2:length(files),
  n.variance     = nc_varget(char(files(f)), 'obs_variance');
  n.type         = nc_varget(char(files(f)), 'obs_type');
  n.time         = nc_varget(char(files(f)), 'obs_time');
  n.depth        = nc_varget(char(files(f)), 'obs_depth');
  n.x            = nc_varget(char(files(f)), 'obs_Xgrid');
  n.y            = nc_varget(char(files(f)), 'obs_Ygrid');
  n.z            = nc_varget(char(files(f)), 'obs_Zgrid');
  n.error        = nc_varget(char(files(f)), 'obs_error');
  n.value        = nc_varget(char(files(f)), 'obs_value');
  n.lat          = n.x * 0;
  n.lon          = n.x * 0;
  n.provenance   = n.x * 0;
  n.meta         = n.x * 0;
  try
    n.lat        = nc_varget(char(files(f)), 'obs_lat');
    n.lon        = nc_varget(char(files(f)), 'obs_lon');
    n.provenance = nc_varget(char(files(f)), 'obs_provenance');
    n.meta       = nc_varget(char(files(f)), 'obs_meta');
  end
  
  l=find(n.time >= times(1) & n.time <= times(2));

  % Combine everything
  obs.variance     = maxvec(obs.variance, n.variance);
  obs.type         = [ obs.type; n.type(l) ];
  obs.time         = [ obs.time; n.time(l) ];
  obs.depth        = [ obs.depth; n.depth(l) ];
  obs.x            = [ obs.x; n.x(l) ];
  obs.y            = [ obs.y; n.y(l) ];
  obs.z            = [ obs.z; n.z(l) ];
  obs.error        = [ obs.error; n.error(l) ];
  obs.value        = [ obs.value; n.value(l) ];
  obs.lat          = [ obs.lat; n.lat(l) ];
  obs.lon          = [ obs.lon; n.lon(l) ];
  obs.provenance   = [ obs.provenance; n.provenance(l) ];
  obs.meta         = [ obs.meta; n.meta(l) ];
end

% Order everything properly
[l,i]=sort(obs.time);
obs.type         = obs.type(i);
obs.time         = obs.time(i); 
obs.depth        = obs.depth(i);
obs.x            = obs.x(i);
obs.y            = obs.y(i);
obs.z            = obs.z(i);
obs.error        = obs.error(i);
obs.value        = obs.value(i);
obs.lat          = obs.lat(i);
obs.lon          = obs.lon(i);
obs.provenance   = obs.provenance(i);
obs.meta         = obs.meta(i);

% Put the surveys together to be less than a minimum time
% Loop over survey times until they are well-spaced
if ( dt>0 )
  nt=sort(unique(obs.time));
  times=[nt(1):dt:nt(end)+dt];
  for t=times,
    l=find(obs.time>=t & obs.time<t+dt);
    obs.time(l)=t;
  end
end

% Build the surveys
obs.survey_time = sort(unique(obs.time));
obs.survey = length(obs.survey_time);
obs.nobs=zeros(size(obs.survey_time));
for i=1:length(obs.survey_time),
  obs.nobs(i) = length(find( obs.time == obs.survey_time(i) ));
end

% Sort the observations by the type for each survey
for i=1:obs.survey,
  l = find( obs.time == obs.survey_time(i) );
  [m,i]=sort(obs.type(l));
  obs.type(l)       = obs.type(l(i));
  obs.time(l)       = obs.time(l(i)); 
  obs.depth(l)      = obs.depth(l(i));
  obs.x(l)          = obs.x(l(i));
  obs.y(l)          = obs.y(l(i));
  obs.z(l)          = obs.z(l(i));
  obs.error(l)      = obs.error(l(i));
  obs.value(l)      = obs.value(l(i));
  obs.lat(l)        = obs.lat(l(i));
  obs.lon(l)        = obs.lon(l(i));
  obs.provenance(l) = obs.provenance(l(i));
  obs.meta(l)       = obs.meta(l(i));
end

% Finally, check the optional vectors and remove unused ones
if ~unique(obs.lat)
  obs = rmfield(obs,'lat');
end
if ~unique(obs.lon)
  obs = rmfield(obs,'lon');
end
if ~unique(obs.provenance)
  obs = rmfield(obs,'provenance');
end

% Lastly, remove any nan's that may have slipped through
l=find(~isnan(obs.value) & ~isnan(obs.time) & ~isnan(obs.x) & ~isnan(obs.y) & ...
       ~isnan(obs.z)     & ~isnan(obs.depth));
obs=delstruct(obs,l,length(obs.time));
