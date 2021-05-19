function narr = narr_nc_info( narr_vars, path, tstart, tend, interp_grid )

% function narr = narr_nc_info( narr_vars, path, tstart, tend, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the proper narr file based upon the narr variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 5 )
  interp_grid = true;
end

if ( tstart > tend )
  error('The start date must be before the ending date');
end
tvec = datevec([tstart:tend]);
year = unique(tvec(:,1));
narr.time_start = tstart;
narr.time_end = tend;
narr.interp_grid = interp_grid;

count=1;
for i=1:length(narr_vars),
  narr_var = char(narr_vars(i));
  % Grab the correct information
  switch lower(narr_var)
   case 'tair'
    narr.vars                      = 1;
    narr.var(count).variable_name      = 'air';
    narr.var(count).roms_variable_name = 'Tair';
    narr.var(count).long_name          = 'surface air temperature';
    narr.var(count).roms_offset        = -273.15;
    narr.var(count).roms_scale         = 1;
    narr.var(count).units              = 'Celsius';
    narr.var(count).file               = strcat(path,'/',num2str(year,'air.sfc.%4d.nc'));
    narr.var(count).time_str           = 'tair_time';
    narr.var(count).field              = 'Tair, scalar, series';
    count = count + 1;
   case 'rain'
    narr.vars                      = 1;
    narr.var(count).variable_name      = 'prate';
    narr.var(count).roms_variable_name = 'rain';
    narr.var(count).long_name          = 'rain fall rate';
    narr.var(count).roms_offset        = 0;
    narr.var(count).roms_scale         = 1;
    narr.var(count).units              = 'kilogram meter-2 second-1';
    narr.var(count).file               = strcat(path,'/',num2str(year,'prate.%4d.nc'));
    narr.var(count).time_str           = 'rain_time';
    narr.var(count).field              = 'rain, scalar, series';
    count = count + 1;
   case {'wind','uwind','vwind'}
    narr.vars                      = 2;
    narr.var(count).variable_name      = 'uwnd';
    narr.var(count).roms_variable_name = 'Uwind';
    narr.var(count).long_name          = 'surface u-wind component';
    narr.var(count).roms_offset        = 0;
    narr.var(count).roms_scale         = 1;
    narr.var(count).units              = 'meter second-1';
    narr.var(count).time_str           = 'wind_time';
    narr.var(count).file               = strcat(path,'/',num2str(year,'uwnd.10m.%4d.nc'));
    narr.var(count).field              = 'u-wind, scalar, series';
    narr.var(count+1).long_name          = 'v-wind component at 10m';
    narr.var(count+1).variable_name      = 'vwnd';
    narr.var(count+1).roms_variable_name = 'Vwind';
    narr.var(count+1).roms_offset        = 0;
    narr.var(count+1).roms_scale         = 1;
    narr.var(count+1).units              = 'meter second-1';
    narr.var(count+1).time_str           = 'wind_time';
    narr.var(count+1).file               = strcat(path,'/',num2str(year,'vwnd.10m.%4d.nc'));
    narr.var(count+1).field              = 'v-wind, scalar, series';
    count = count + 2;
   case 'qair'
    narr.vars                          = 1;
    narr.var(count).variable_name      = 'rhum';
    narr.var(count).roms_variable_name = 'Qair';
    narr.var(count).long_name          = 'surface air relative humidity';
    narr.var(count).roms_offset        = 0;
    narr.var(count).roms_scale         = 1;
    narr.var(count).units              = 'percentage';
    narr.var(count).file               = strcat(path,'/',num2str(year,'rhum.2m.%4d.nc'));
    narr.var(count).time_str           = 'qair_time';
    narr.var(count).field              = 'Qair, scalar, series';
    count = count + 1;
   case 'pair'
    narr.vars                      = 1;
    narr.var(count).variable_name      = 'pres';
    narr.var(count).roms_variable_name = 'Pair';
    narr.var(count).long_name          = 'surface air pressure';
    narr.var(count).roms_offset        = 0;
    narr.var(count).roms_scale         = 0.01;
    narr.var(count).units              = 'millibar';
    narr.var(count).file               = strcat(path,'/',num2str(year,'pres.sfc.%4d.nc'));
    narr.var(count).time_str           = 'pair_time';
    narr.var(count).field              = 'Pair, scalar, series';
    count = count + 1;
   case 'lwrad'
    narr.vars                      = 1;
    narr.var(count).variable_name      = 'dlwrf';
    narr.var(count).roms_variable_name = 'lwrad_down';
    narr.var(count).long_name          = 'down longwave radiation flux';
    narr.var(count).roms_offset        = 0;
    narr.var(count).roms_scale         = 1;
    narr.var(count).units              = 'watt meter-2';
    narr.var(count).file               = strcat(path,'/',num2str(year,'dlwrf.%4d.nc'));
    narr.var(count).time_str           = 'lrf_time';
    narr.var(count).field              = 'longwave radiation, scalar, series';
    count = count + 1;
   case 'swrad'
    narr.vars                      = 1;
    narr.var(count).variable_name      = 'dswrf';
    narr.var(count).roms_variable_name = 'swrad';
    narr.var(count).long_name          = 'solar shortwave radiation flux';
    narr.var(count).roms_offset        = 0;
    narr.var(count).roms_scale         = 1;
    narr.var(count).units              = 'watt meter-2';
    narr.var(count).file               = strcat(path,'/',num2str(year,'dswrf.%4d.nc'));
    narr.var(count).time_str           = 'srf_time';
    narr.var(count).field              = 'shortwave radiation, scalar, series';
    count = count + 1;
  end
end

for i=1:length(narr.var),
  narr.var(i).lon = nc_varget( narr.var(i).file(1,:), 'lon' );
  l=find(narr.var(i).lon<0);
  if (~isempty(l))
    narr.var(i).lon(l)=narr.var(i).lon(l)+360;
  end
  narr.var(i).lat = nc_varget( narr.var(i).file(1,:), 'lat' );
end
narr.vars = length(narr.var);
