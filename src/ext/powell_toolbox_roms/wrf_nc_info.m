function wrf = wrf_nc_info( wrf_vars, file, tstart, tend, interp_grid )

% function ncep = wrf_nc_info( wrf_var, file, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the raw WRF file based upon the variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 3 )
  interp_grid = false;
end

wrf.interp_grid = interp_grid;
wrf.time_start = tstart;
wrf.time_end = tend;
count = 1;

if (length(file)==1)
  file=repmat(file,[length(wrf_vars) 1]);
end
for i=1:length(wrf_vars),
  % Grab the correct information
  wrf_var=char(wrf_vars(i));
  switch lower(wrf_var)
   case 'tair'
    wrf.var(count).variable_name      = 'T2';
    wrf.var(count).roms_variable_name = 'Tair';
    wrf.var(count).long_name          = 'surface air temperature';
    wrf.var(count).roms_offset        = -273.15;
    wrf.var(count).roms_scale         = 1;
    wrf.var(count).units              = 'Celsius';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).time_str           = 'tair_time';
    wrf.var(count).field              = 'Tair, scalar, series';
    wrf.var(count).level              = 0;
    count = count + 1;
   case 'rain'
    wrf.var(count).variable_name      = 'RAINC';
    wrf.var(count).roms_variable_name = 'rain';
    wrf.var(count).long_name          = 'rain fall rate';
    wrf.var(count).roms_offset        = 0;
    wrf.var(count).roms_scale         = 1;
    wrf.var(count).units              = 'kilogram meter-2 second-1';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).time_str           = 'rain_time';
    wrf.var(count).field              = 'rain, scalar, series';
    wrf.var(count).level              = 0;
    wrf.var(count).operation          = @op_rain;
    wrf.var(count+1).variable_name    = 'RAINNC';
    wrf.var(count+1).file               = char(file(i));
    wrf.var(count+1).roms_variable_name = 'rainnc';
    wrf.var(count+1).long_name          = 'rain fall rate';
    wrf.var(count+1).roms_offset        = 0;
    wrf.var(count+1).roms_scale         = 1;
    wrf.var(count+1).level              = 0;
    count = count + 2;
   case {'wind','uwind','vwind'}
    wrf.var(count).variable_name      = 'U10';
    wrf.var(count).roms_variable_name = 'Uwind';
    wrf.var(count).long_name          = 'surface u-wind component';
    wrf.var(count).roms_offset        = 0;
    wrf.var(count).roms_scale         = 1;
    wrf.var(count).units              = 'meter second-1';
    wrf.var(count).time_str           = 'wind_time';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).field              = 'u-wind, scalar, series';
    wrf.var(count).level              = 0;
    wrf.var(count+1).variable_name      = 'V10';
    wrf.var(count+1).long_name          = 'v-wind component at 10m';
    wrf.var(count+1).roms_variable_name = 'Vwind';
    wrf.var(count+1).roms_offset        = 0;
    wrf.var(count+1).roms_scale         = 1;
    wrf.var(count+1).units              = 'meter second-1';
    wrf.var(count+1).time_str           = 'wind_time';
    wrf.var(count+1).file               = char(file(i));
    wrf.var(count+1).field              = 'v-wind, scalar, series';
    wrf.var(count+1).level              = 0;
    count = count + 2;
   case 'pair'
    wrf.var(count).variable_name      = 'PSFC';
    wrf.var(count).roms_variable_name = 'Pair';
    wrf.var(count).long_name          = 'surface air pressure';
    wrf.var(count).roms_offset        = 0;
    wrf.var(count).roms_scale         = .01;
    wrf.var(count).units              = 'millibar';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).time_str           = 'pair_time';
    wrf.var(count).field              = 'Pair, scalar, series';
    wrf.var(count).level              = 0;
    count = count + 1;
   case 'lwrad'
    wrf.var(count).variable_name      = 'GLW';
    wrf.var(count).roms_variable_name = 'lwrad_down';
    wrf.var(count).long_name          = 'net longwave radiation flux';
    wrf.var(count).roms_offset        = 0;
    wrf.var(count).roms_scale         = 1;
    wrf.var(count).units              = 'watt meter-2';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).time_str           = 'lrf_time';
    wrf.var(count).field              = 'longwave radiation, scalar, series';
    wrf.var(count).level              = 0;
    count = count + 1;
   case 'swrad'
    wrf.var(count).variable_name      = 'SWDOWN';
    wrf.var(count).roms_variable_name = 'swrad';
    wrf.var(count).long_name          = 'solar shortwave radiation flux';
    wrf.var(count).roms_offset        = 0;
    wrf.var(count).roms_scale         = 1;
    wrf.var(count).units              = 'watt meter-2';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).time_str           = 'srf_time';
    wrf.var(count).field              = 'shortwave radiation, scalar, series';
    wrf.var(count).level              = 0;
    count = count + 1;
   case 'qair'
    wrf.var(count).variable_name      = 'Q2';
    wrf.var(count).roms_variable_name = 'Qair';
    wrf.var(count).long_name          = 'surface air relative humidity';
    wrf.var(count).roms_offset        = 0;
    wrf.var(count).roms_scale         = 1;
    wrf.var(count).units              = 'percentage';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).time_str           = 'qair_time';
    wrf.var(count).field              = 'Qair, scalar, series';
    wrf.var(count).level              = 0;
    wrf.var(count).operation          = @op_hum;
    count = count + 1;
   case 'sst'
    wrf.var(count).variable_name      = 'SST';
    wrf.var(count).roms_variable_name = 'sst';
    wrf.var(count).long_name          = 'atmospheric guess for sst';
    wrf.var(count).roms_offset        = -273.15;
    wrf.var(count).roms_scale         = 1;
    wrf.var(count).units              = 'Celsius';
    wrf.var(count).file               = char(file(i));
    wrf.var(count).time_str           = 'tair_time';
    wrf.var(count).field              = 'SST, series';
    wrf.var(count).level              = 0;
    count = count + 1;
  end
end

for i=1:length(wrf.var),
  wrf.var(i).lon = squeeze(nc_varget( wrf.var(i).file(1,:), 'XLONG', [0 0 0],[1 -1 -1] ));
  wrf.var(i).lat = squeeze(nc_varget( wrf.var(i).file(1,:), 'XLAT', [0 0 0],[1 -1 -1] ));
  l=find(wrf.var(i).lon>180);
  if (~isempty(l))
    wrf.var(i).lon(l)=wrf.var(i).lon(l)-360;
  end
end
wrf.vars = length(wrf.var);
