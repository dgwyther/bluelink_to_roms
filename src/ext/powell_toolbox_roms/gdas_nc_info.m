function gdas = gdas_nc_info( gdas_vars, path, tstart, tend, interp_grid )

% function ncep = gdas_nc_info( ncep_vars, path, tstart, tend, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the proper GLS file based upon the ncep variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 5 )
  interp_grid = true;
end

tvec = datevec([tstart:tend]);
tvec = tvec(:,1)*10000 + tvec(:,2)*100 + tvec(:,3);
gdas.time_start = tstart;
gdas.time_end = tend;
gdas.interp_grid = interp_grid;

count = 1;
for i=1:length(gdas_vars),
  % Grab the correct information
  gdas_var=char(gdas_vars(i));
  switch lower(gdas_var)
   case 'tair'
    gdas.var(count).variable_name      = 'T_sfc';
    gdas.var(count).roms_variable_name = 'Tair';
    gdas.var(count).long_name          = 'surface air temperature';
    gdas.var(count).roms_offset        = -273.15;
    gdas.var(count).roms_scale         = 1;
    gdas.var(count).units              = 'Celsius';
    gdas.var(count).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count).time_str           = 'tair_time';
    gdas.var(count).field              = 'Tair, scalar, series';
    gdas.var(count).level              = 0;
    count = count + 1;
   case 'rain'
    gdas.var(count).variable_name      = 'precip_rt';
    gdas.var(count).roms_variable_name = 'rain';
    gdas.var(count).long_name          = 'rain fall rate';
    gdas.var(count).roms_offset        = 0;
    gdas.var(count).roms_scale         = 1;
    gdas.var(count).units              = 'kilogram meter-2 second-1';
    gdas.var(count).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count).time_str           = 'rain_time';
    gdas.var(count).field              = 'rain, scalar, series';
    gdas.var(count).level              = 0;
    count = count + 1;
   case {'wind','uwind','vwind'}
    gdas.var(count).variable_name      = 'u_fhg';
    gdas.var(count).roms_variable_name = 'Uwind';
    gdas.var(count).long_name          = 'surface u-wind component';
    gdas.var(count).roms_offset        = 0;
    gdas.var(count).roms_scale         = 1;
    gdas.var(count).units              = 'meter second-1';
    gdas.var(count).time_str           = 'wind_time';
    gdas.var(count).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count).field              = 'u-wind, scalar, series';
    gdas.var(count).level              = 2;
    gdas.var(count+1).long_name          = 'v-wind component at 10m';
    gdas.var(count+1).variable_name      = 'v_fhg';
    gdas.var(count+1).roms_variable_name = 'Vwind';
    gdas.var(count+1).roms_offset        = 0;
    gdas.var(count+1).roms_scale         = 1;
    gdas.var(count+1).units              = 'meter second-1';
    gdas.var(count+1).time_str           = 'wind_time';
    gdas.var(count+1).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count+1).field              = 'v-wind, scalar, series';
    gdas.var(count+1).level              = 2;
    count = count + 2;
   case 'qair'
    gdas.var(count).variable_name      = 'RH_fhg';
    gdas.var(count).roms_variable_name = 'Qair';
    gdas.var(count).long_name          = 'surface air relative humidity';
    gdas.var(count).roms_offset        = 0;
    gdas.var(count).roms_scale         = 1;
    gdas.var(count).units              = 'percentage';
    gdas.var(count).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count).time_str           = 'qair_time';
    gdas.var(count).field              = 'Qair, scalar, series';
    gdas.var(count).level              = 1;
    count = count + 1;
   case 'pair'
    gdas.var(count).variable_name      = 'P_msl';
    gdas.var(count).roms_variable_name = 'Pair';
    gdas.var(count).long_name          = 'surface air pressure';
    gdas.var(count).roms_offset        = 0;
    gdas.var(count).roms_scale         = 0.01;
    gdas.var(count).units              = 'millibar';
    gdas.var(count).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count).time_str           = 'pair_time';
    gdas.var(count).field              = 'Pair, scalar, series';
    gdas.var(count).level              = 0;
    count = count + 1;
   case 'lwrad'
    gdas.var(count).variable_name      = 'dlwrf_sfc';
    gdas.var(count).roms_variable_name = 'lwrad_down';
    gdas.var(count).long_name          = 'net longwave radiation flux';
    gdas.var(count).roms_offset        = 0;
    gdas.var(count).roms_scale         = 1;
    gdas.var(count).units              = 'watt meter-2';
    gdas.var(count).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count).time_str           = 'lrf_time';
    gdas.var(count).field              = 'longwave radiation, scalar, series';
    gdas.var(count).level              = 0;
    count = count + 1;
   case 'swrad'
    gdas.var(count).variable_name      = 'dswrf_sfc';
    gdas.var(count).roms_variable_name = 'swrad';
    gdas.var(count).long_name          = 'solar shortwave radiation flux';
    gdas.var(count).roms_offset        = 0;
    gdas.var(count).roms_scale         = 1;
    gdas.var(count).units              = 'watt meter-2';
    gdas.var(count).file               = strcat(path,'/',num2str(tvec,'%8d.nc'));
    gdas.var(count).time_str           = 'srf_time';
    gdas.var(count).field              = 'shortwave radiation, scalar, series';
    gdas.var(count).level              = 0;
    count = count + 1;
  end
end

for i=1:length(gdas.var),
  gdas.var(i).lon = nc_varget( gdas.var(i).file(1,:), 'lon' );
  gdas.var(i).lat = nc_varget( gdas.var(i).file(1,:), 'lat' );
end
gdas.vars = length(gdas.var);
