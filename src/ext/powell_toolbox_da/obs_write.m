function obs = obs_write( obs )

% obs_write( obs )
%
% Given an observation structure, write out the data into a proper,
% ROMS CF-compliant netcdf file. This function will automatically
% create the surveys, etc. 
%
% The following elements of 'obs' are REQUIRED:
%
%        x: grid x-positions of obs
%        y: grid y-positions of obs
%    depth: obs depth
%        z: grid z-position
%    value: obs values
%    error: obs error
%     type: obs types
%     time: obs times
% filename: output netcdf file name
% variance: global variance (size of state vector)
%
% All other fields are optional
%      lat: obs latitude
%      lon: obs longitude
% provenance: integer of where the obs came from
%    source: structure of provenance descriptions
%
% Example obs structure with a single obs:
% 
% 
%  obs =
%          x: 32.1000
%          y: 15.4000
%      value: 2
%       type: 1
%       time: 3838
%   filename: 'test.nc'
%   variance: [0.4000 0.4000 0.4000 0.4000 0.4000 0.4000 0.4000]
%      depth: 12
%          z: 12
%      error: 0.4000
% provenance: 4
%     source: [1x1 struct]
%        lat: 21.3000
%        lon: -158.3300
% 
% obs.source =
%   aviso_topex: 1
%   aviso_jason: 2
%  glider_sg129: 129

% Written by Brian Powell

% Check we have a valid obs struct
if ( ~length(obs.time) )
  error('Empty Observation Structure')
end

% Destroy any nan values
l=find(~isnan(obs.x .* obs.y .* obs.value .* obs.error));
obs=delstruct(obs,l,length(obs.value));

% Sort the observation structure in time
[t,slist]=sort(obs.time(:));

% Create the file
[id, status]=mexnc('create', obs.filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' obs.filename] )
end
mexnc('close',id);

% Set the global variables for the file
newline=sprintf('\n');
nc_attput( obs.filename, nc_global, 'title', 'Observations' );
[a,user]=unix('finger `whoami`');
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
nc_attput( obs.filename, nc_global, 'author', user.name );
nc_attput( obs.filename, nc_global, 'date', datestr(now));
nc_attput( obs.filename, nc_global, 'type', 'ROMS observations');
nc_attput( obs.filename, nc_global, 'Conventions', 'CF-1.4');
nc_attput( obs.filename, nc_global, 'state_variables', ...
       [newline, ...
       '1: free-surface (m) ', newline, ...
       '2: vertically integrated u-momentum component (m/s) ', newline, ...
       '3: vertically integrated v-momentum component (m/s) ', newline, ...
       '4: u-momentum component (m/s) ', newline, ...
       '5: v-momentum component (m/s) ', newline, ...
       '6: potential temperature (Celsius) ', newline, ...
       '7: salinity (nondimensional)']) ;

% Verify the nobs fields
obs.survey_time = sort(unique(obs.time));
obs.nobs=zeros(size(obs.survey_time));
for i=1:length(obs.survey_time),
  l = length(find( obs.time == obs.survey_time(i) ));
  if ( l == 0 ) 
    obs.survey_time(i) = nan;
  else
    obs.nobs(i) = l;
  end
end
l = find( isnan(obs.survey_time) );
if ( ~isempty(l) )
  l = find( ~isnan(obs.survey_time) );
  obs.survey_time = obs.survey_time(l);
  obs.nobs = obs.nobs(l);
end
obs.survey = length(obs.survey_time);
if (~isfield(obs,'spherical'))
  if ( isfield(obs, 'lat') & isfield(obs, 'lon') )
    obs.spherical=1;
  else
    obs.spherical=0;
  end
end

% Add the dimensions
nc_add_dimension( obs.filename, 'survey', obs.survey );
nc_add_dimension( obs.filename, 'state_variable', length(obs.variance) );
nc_add_dimension( obs.filename, 'datum', sum(obs.nobs) );

% Add the variables
rec = [];
rec.Name = 'spherical';
rec.Nctype = 'NC_INT';
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'grid type logical switch';
rec.Attribute(2).Name = 'flag_values';
rec.Attribute(2).Value = '0, 1';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.spherical );

rec = [];
rec.Name = 'Nobs';
rec.Nctype = 'NC_INT';
rec.Dimension(1) = cellstr('survey');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'number of observations with the same survey time';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.nobs );

rec = [];
rec.Name = 'survey_time';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('survey');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'survey time';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'day';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.survey_time(:) );

rec = [];
rec.Name = 'obs_variance';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('state_variable');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'global time and space observation variance';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'squared state variable units';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.variance );


rec = [];
rec.Name = 'obs_type';
rec.Nctype = 'NC_INT';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'model state variable associated with observation';
rec.Attribute(2).Name = 'flag_values';
rec.Attribute(2).Value = '1, 2, 3, 4, 5, 6, 7';
rec.Attribute(3).Name = 'flag_meanings';
rec.Attribute(3).Value = 'zeta ubar vbar u v temperature salinity';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.type(slist) );

rec = [];
rec.Name = 'obs_time';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'time of observation';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'day';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.time(slist) );

rec = [];
rec.Name = 'obs_depth';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'depth of observation';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter';
rec.Attribute(2).Name = 'negative';
rec.Attribute(2).Value = 'downwards';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.depth(slist) );


rec = [];
rec.Name = 'obs_Xgrid';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'x-grid observation location';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'nondimensional';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.x(slist) );

rec = [];
rec.Name = 'obs_Ygrid';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'y-grid observation location';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'nondimensional';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.y(slist) );

rec = [];
rec.Name = 'obs_Zgrid';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'z-grid observation location';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'nondimensional';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.z(slist) );

rec = [];
rec.Name = 'obs_error';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'observation error covariance';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'squared state variable units';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.error(slist) );

rec = [];
rec.Name = 'obs_value';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('datum');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'observation value';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'state variable units';
nc_addvar( obs.filename, rec );
nc_varput( obs.filename, rec.Name, obs.value(slist) );

if isfield(obs, 'meta')
  rec = [];
  rec.Name = 'obs_meta';
  rec.Nctype = 'NC_DOUBLE';
  rec.Dimension(1) = cellstr('datum');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'observation meta value';
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = 'nondimensional';
  nc_addvar( obs.filename, rec );
  nc_varput( obs.filename, rec.Name, obs.meta(slist) );
end

if isfield(obs, 'provenance')
  rec = [];
  rec.Name = 'obs_provenance';
  rec.Nctype = 'NC_INT';
  rec.Dimension(1) = cellstr('datum');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'observation source';
  nc_addvar( obs.filename, rec );
  nc_varput( obs.filename, rec.Name, obs.provenance(slist) );
  if isfield(obs, 'source')
    names=fieldnames(obs.source);
    src='';
    for i=1:length(names),
      n=char(names(i));
      src=[src ' ' newline num2str(int32(getfield(obs.source,n)), ...
           ['%d: ' n])];
    end
    nc_attput( obs.filename, rec.Name, 'source', src );
  else
    nc_attput( obs.filename, rec.Name, 'source', ...
        [newline, ...
        	' 1: gridded AVISO sea level anomaly ', newline, ...
        	' 2: blended satellite SST ', newline, ...
        	' 3: XBT temperature from Met Office ', newline, ...
        	' 4: CTD temperature from Met Office ', newline, ...
        	' 5: CTD salinity from Met Office ', newline, ...
        	' 6: ARGO floats temperature from Met Office ', newline, ...
        	' 7: ARGO floats salinity from Met Office '] );
  end
end

if ( isfield(obs, 'lat') & isfield(obs, 'lon') )
  rec = [];
  rec.Name = 'obs_lat';
  rec.Nctype = 'NC_DOUBLE';
  rec.Dimension(1) = cellstr('datum');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'observation latitude';
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = 'degrees';
  nc_addvar( obs.filename, rec );
  nc_varput( obs.filename, rec.Name, obs.lat(slist) );

  rec = [];
  rec.Name = 'obs_lon';
  rec.Nctype = 'NC_DOUBLE';
  rec.Dimension(1) = cellstr('datum');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'observation longitude';
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = 'degrees';
  nc_addvar( obs.filename, rec );
  nc_varput( obs.filename, rec.Name, obs.lon(slist) );
end
