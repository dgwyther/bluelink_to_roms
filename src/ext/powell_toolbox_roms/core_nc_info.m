function core = core_nc_info( core_vars, path, tstart, tend, interp_grid )

% function core = core_nc_info( core_var, path, tstart, tend, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the proper core file based upon the core variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 5 )
  interp_grid = true;
end

if ( tstart > tend )
  error('The start date must be before the ending date');
end
tvec = datevec([tstart:tend]);
year = unique(tvec(:,1));
year = [year(1)-1;year];
core.time_start = tstart;
core.time_end = tend;
core.interp_grid = interp_grid;

count=1;
for i=1:length(core_vars),
  core_var = char(core_vars(i));
  % Grab the correct information
  switch lower(core_var)
    case 'tair'
      % COMES IN KELVIN
      core.vars                      = 1;
      core.var(count).variable_name      = 'T_10_MOD';
      core.var(count).variable_time      = 'TIME';
      core.var(count).time_offset        = 0;
      core.var(count).roms_variable_name = 'Tair';
      core.var(count).long_name          = 'surface air temperature';
      core.var(count).roms_offset        = -273.15;
      core.var(count).roms_scale         = 1;
      core.var(count).units              = 'Celsius';
      core.var(count).year               = year;
      core.var(count).file               = strcat(path,'/',num2str(year,'t_10.%4d'),'.7JULY2008.nc');
      core.var(count).time_str           = 'tair_time';
      core.var(count).field              = 'Tair, scalar, series';
      count = count + 1;
    case 'rain'
      % THIS COMES IN MM/S which is equal to kg m^-2 s^-1 for pure water
      core.vars                      = 1;
      core.var(count).variable_name      = 'RAIN';
      core.var(count).variable_time      = 'TIME';
      core.var(count).time_offset        = 0;
      core.var(count).roms_variable_name = 'rain';
      core.var(count).long_name          = 'rain fall rate';
      core.var(count).roms_offset        = 0;
      core.var(count).roms_scale         = 1;
      core.var(count).units              = 'kilogram meter-2 second-1';
      core.var(count).year               = year;
      core.var(count).file               = strcat(path,'/',num2str(year,'ncar_precip.%4d'),'.7JULY2008.nc');
      core.var(count).time_str           = 'rain_time';
      core.var(count).field              = 'rain, scalar, series';
      count = count + 1;
    case {'wind','uwind','vwind'}
      core.vars                      = 2;
      core.var(count).variable_name      = 'U_10_MOD';
      core.var(count).variable_time      = 'TIME';
      core.var(count).time_offset        = 0;
      core.var(count).roms_variable_name = 'Uwind';
      core.var(count).long_name          = 'surface u-wind component';
      core.var(count).roms_offset        = 0;
      core.var(count).roms_scale         = 1;
      core.var(count).units              = 'meter second-1';
      core.var(count).time_str           = 'wind_time';
      core.var(count).year               = year;
      core.var(count).file               = strcat(path,'/',num2str(year,'u_10.%4d'),'.7JULY2008.nc');
      core.var(count).field              = 'u-wind, scalar, series';
      core.var(count+1).long_name          = 'v-wind component at 10m';
      core.var(count+1).variable_name      = 'V_10_MOD';
      core.var(count+1).variable_time      = 'TIME';
      core.var(count+1).time_offset        = 0;
      core.var(count+1).roms_variable_name = 'Vwind';
      core.var(count+1).roms_offset        = 0;
      core.var(count+1).roms_scale         = 1;
      core.var(count+1).units              = 'meter second-1';
      core.var(count+1).time_str           = 'wind_time';
      core.var(count+1).year               = year;
      core.var(count+1).file               = strcat(path,'/',num2str(year,'v_10.%4d'),'.7JULY2008.nc');
      core.var(count+1).field              = 'v-wind, scalar, series';
      count = count + 2;
    case 'qair'
      core.vars                      = 1;
      core.var(count).variable_name      = 'Q_10_MOD';
      core.var(count).variable_time      = 'TIME';
      core.var(count).time_offset        = 0;
      core.var(count).roms_variable_name = 'Qair';
      core.var(count).long_name          = 'surface air relative humidity';
      core.var(count).roms_offset        = 0;
      core.var(count).roms_scale         = 1;
      core.var(count).units              = 'percentage';
      core.var(count).year               = year;
      core.var(count).file               = strcat(path,'/',num2str(year,'q_10.%4d'),'.7JULY2008.nc');
      core.var(count).time_str           = 'qair_time';
      core.var(count).field              = 'Qair, scalar, series';
      count = count + 1;
    case 'pair'
      % COMES IN PASCALS
      core.vars                      = 1;
      core.var(count).variable_name      = 'SLP';
      core.var(count).variable_time      = 'TIME';
      core.var(count).time_offset        = 0;
      core.var(count).roms_variable_name = 'Pair';
      core.var(count).long_name          = 'surface air pressure';
      core.var(count).roms_offset        = 0;
      core.var(count).roms_scale         = 0.01;
      core.var(count).units              = 'millibar';
      core.var(count).year               = year;
      core.var(count).file               = strcat(path,'/',num2str(year,'slp.%4d'),'.7JULY2008.nc');
      core.var(count).time_str           = 'pair_time';
      core.var(count).field              = 'Pair, scalar, series';
      count = count + 1;
    case {'rad','lwrad','swrad'}
      core.vars                      = 2;
      core.var(count).variable_name      = 'LWDN_MOD';
      core.var(count).variable_time      = 'TIME';
      core.var(count).time_offset        = -1;
      core.var(count).roms_variable_name = 'lwrad_down';
      core.var(count).long_name          = 'net longwave radiation flux';
      core.var(count).roms_offset        = 0;
      core.var(count).roms_scale         = 1;
      core.var(count).units              = 'watt meter-2';
      core.var(count).year               = year;
      core.var(count).file               = strcat(path,'/',num2str(year,'ncar_rad.%4d'),'.7JULY2008.nc');
      core.var(count).time_str           = 'lrf_time';
      core.var(count).field              = 'longwave radiation, scalar, series';
      core.var(count+1).variable_name      = 'SWDN_MOD';
      core.var(count+1).variable_time      = 'TIME';
      core.var(count+1).time_offset        = -1;
      core.var(count+1).roms_variable_name = 'swrad';
      core.var(count+1).long_name          = 'solar shortwave radiation flux';
      core.var(count+1).roms_offset        = 0;
      core.var(count+1).roms_scale         = 1;
      core.var(count+1).units              = 'watt meter-2';
      core.var(count+1).year               = year;
      core.var(count+1).file               = strcat(path,'/',num2str(year,'ncar_rad.%4d'),'.7JULY2008.nc');
      core.var(count+1).time_str           = 'srf_time';
      core.var(count+1).field              = 'shortwave radiation, scalar, series';
      count = count + 2;
    otherwise
      core.vars = 0;
  end
end

for i=1:length(core.var),
  core.var(i).lon = nc_varget( core.var(i).file(1,:), 'LON' );
  core.var(i).lat = nc_varget( core.var(i).file(1,:), 'LAT' );
end
core.vars = length(core.var);

