function gfs = gfs_nc_info( gfs_vars, file, interp_grid )

% function ncep = gfs_nc_info( gfs_var, file, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the proper GLS file based upon the ncep variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 3 )
  interp_grid = true;
end

if ( nc_isvar(file,'time') )
  t = nc_varget(file,'time')+365;
  gfs.time_start = t(1);
  gfs.time_end = t(end);
end
gfs.interp_grid = interp_grid;
count = 1;

for i=1:length(gfs_vars),
  % Grab the correct information
  gfs_var=char(gfs_vars(i));
  switch lower(gfs_var)
   case 'tair'
    gfs.var(count).variable_name      = 'tmpsfc';
    gfs.var(count).roms_variable_name = 'Tair';
    gfs.var(count).long_name          = 'surface air temperature';
    gfs.var(count).roms_offset        = -273.15;
    gfs.var(count).roms_scale         = 1;
    gfs.var(count).units              = 'Celsius';
    gfs.var(count).file               = file;
    gfs.var(count).time_str           = 'tair_time';
    gfs.var(count).field              = 'Tair, scalar, series';
    gfs.var(count).level              = 0;
    count = count + 1;
   case 'rain'
    gfs.var(count).variable_name      = 'pratesfc';
    gfs.var(count).roms_variable_name = 'rain';
    gfs.var(count).long_name          = 'rain fall rate';
    gfs.var(count).roms_offset        = 0;
    gfs.var(count).roms_scale         = 1;
    gfs.var(count).units              = 'kilogram meter-2 second-1';
    gfs.var(count).file               = file;
    gfs.var(count).time_str           = 'rain_time';
    gfs.var(count).field              = 'rain, scalar, series';
    gfs.var(count).level              = 0;
    count = count + 1;
   case {'wind','uwind','vwind'}
    gfs.var(count).variable_name      = 'ugrd10m';
    gfs.var(count).roms_variable_name = 'Uwind';
    gfs.var(count).long_name          = 'surface u-wind component';
    gfs.var(count).roms_offset        = 0;
    gfs.var(count).roms_scale         = 1;
    gfs.var(count).units              = 'meter second-1';
    gfs.var(count).time_str           = 'wind_time';
    gfs.var(count).file               = file;
    gfs.var(count).field              = 'u-wind, scalar, series';
    gfs.var(count).level              = 0;
    gfs.var(count+1).long_name          = 'v-wind component at 10m';
    gfs.var(count+1).variable_name      = 'vgrd10m';
    gfs.var(count+1).roms_variable_name = 'Vwind';
    gfs.var(count+1).roms_offset        = 0;
    gfs.var(count+1).roms_scale         = 1;
    gfs.var(count+1).units              = 'meter second-1';
    gfs.var(count+1).time_str           = 'wind_time';
    gfs.var(count+1).file               = file;
    gfs.var(count+1).field              = 'v-wind, scalar, series';
    gfs.var(count+1).level              = 0;
    count = count + 2;
   case 'qair'
    gfs.var(count).variable_name      = 'rh2m';
    gfs.var(count).roms_variable_name = 'Qair';
    gfs.var(count).long_name          = 'surface air relative humidity';
    gfs.var(count).roms_offset        = 0;
    gfs.var(count).roms_scale         = 1;
    gfs.var(count).units              = 'percentage';
    gfs.var(count).file               = file;
    gfs.var(count).time_str           = 'qair_time';
    gfs.var(count).field              = 'Qair, scalar, series';
    gfs.var(count).level              = 0;
    count = count + 1;
   case 'pair'
    gfs.var(count).variable_name      = 'prmslmsl';
    gfs.var(count).roms_variable_name = 'Pair';
    gfs.var(count).long_name          = 'surface air pressure';
    gfs.var(count).roms_offset        = 0;
    gfs.var(count).roms_scale         = 0.01;
    gfs.var(count).units              = 'millibar';
    gfs.var(count).file               = file;
    gfs.var(count).time_str           = 'pair_time';
    gfs.var(count).field              = 'Pair, scalar, series';
    gfs.var(count).level              = 0;
    count = count + 1;
   case 'lwrad'
    gfs.var(count).variable_name      = 'dlwrfsfc';
    gfs.var(count).roms_variable_name = 'lwrad_down';
    gfs.var(count).long_name          = 'net longwave radiation flux';
    gfs.var(count).roms_offset        = 0;
    gfs.var(count).roms_scale         = 1;
    gfs.var(count).units              = 'watt meter-2';
    gfs.var(count).file               = file;
    gfs.var(count).time_str           = 'lrf_time';
    gfs.var(count).field              = 'longwave radiation, scalar, series';
    gfs.var(count).level              = 0;
    count = count + 1;
   case 'swrad'
    gfs.var(count).variable_name      = 'dswrfsfc';
    gfs.var(count).roms_variable_name = 'swrad';
    gfs.var(count).long_name          = 'solar shortwave radiation flux';
    gfs.var(count).roms_offset        = 0;
    gfs.var(count).roms_scale         = 1;
    gfs.var(count).units              = 'watt meter-2';
    gfs.var(count).file               = file;
    gfs.var(count).time_str           = 'srf_time';
    gfs.var(count).field              = 'shortwave radiation, scalar, series';
    gfs.var(count).level              = 0;
    count = count + 1;
  end
end

gfs.var(1).lon = nc_varget( gfs.var(1).file(1,:), 'lon' );
l=find(gfs.var(1).lon>180);
if (~isempty(l))
  gfs.var(1).lon(l)=gfs.var(1).lon(l)-360;
end
gfs.var(1).lat = nc_varget( gfs.var(1).file(1,:), 'lat' );

for i=2:length(gfs.var),
  gfs.var(i).lon=gfs.var(1).lon;
  gfs.var(i).lat=gfs.var(1).lat;
end
gfs.vars = length(gfs.var);
