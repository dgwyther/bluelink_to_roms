function ecmwf = ecmwf_nc_info( ecmwf_vars, path, tstart, tend, interp_grid )

% function ecmwf = ecmwf_nc_info( ecmwf_vars, path, tstart, tend, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the proper ecmwf file based upon the ecmwf variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 5 )
  interp_grid = true;
end

if ( tstart > tend )
  error('The start date must be before the ending date');
end
tvec = datevec([tstart:tend]);
year = unique(tvec(:,1));
ecmwf.time_start = tstart;
ecmwf.time_end = tend;
ecmwf.interp_grid = interp_grid;

count=1;
for i=1:length(ecmwf_vars),
  ecmwf_var = char(ecmwf_vars(i));
  % Grab the correct information
  switch lower(ecmwf_var)
   case 'tair'
    ecmwf.var(count).variable_name      = 'T2M_sfc';
    ecmwf.var(count).roms_variable_name = 'Tair';
    ecmwf.var(count).long_name          = 'surface air temperature';
    ecmwf.var(count).roms_offset        = -273.15;
    ecmwf.var(count).roms_scale         = 1;
    ecmwf.var(count).units              = 'Celsius';
    ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.t106.2t.%4d.nc'));
    ecmwf.var(count).time_str           = 'tair_time';
    ecmwf.var(count).field              = 'Tair, scalar, series';
    ecmwf.var(count).scale_factor       = 0.01;
    count = count + 1;
   case 'rain'
    % ecmwf.var(count).variable_name      = 'IE_sfc';
    % ecmwf.var(count).roms_variable_name = 'rain';
    % ecmwf.var(count).long_name          = 'rain fall rate';
    % ecmwf.var(count).roms_offset        = 0;
    % ecmwf.var(count).roms_scale         = 1;
    % ecmwf.var(count).units              = 'kilogram meter-2 second-1';
    % ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.othr.t106.ie.%4d.nc'));
    % ecmwf.var(count).time_str           = 'rain_time';
    % ecmwf.var(count).field              = 'rain, scalar, series';
    % ecmwf.var(count).scale_factor       = 1e-5;
    % count = count + 1;
    ecmwf.var(count).variable_name      = 'LSP';
    ecmwf.var(count).roms_variable_name = 'rain';
    ecmwf.var(count).long_name          = 'rain fall rate';
    ecmwf.var(count).roms_offset        = 0;
    ecmwf.var(count).roms_scale         = 1000;
    ecmwf.var(count).units              = 'kilogram meter-2 second-1';
    ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.othr.t106.lsp.%4d.nc'));
    ecmwf.var(count).time_str           = 'rain_time';
    ecmwf.var(count).field              = 'rain, scalar, series';
    ecmwf.var(count).level              = 0;
    ecmwf.var(count).scale_factor        = 1.0e-5;
    ecmwf.var(count).operation          = @op_ecmwf_rain;
    ecmwf.var(count+1).variable_name    = 'CP';
    ecmwf.var(count+1).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.othr.t106.cp.%4d.nc'));
    ecmwf.var(count+1).roms_variable_name = 'rainnc';
    ecmwf.var(count+1).long_name          = 'rain';
    ecmwf.var(count+1).roms_offset        = 0;
    ecmwf.var(count+1).roms_scale         = 1000;
    ecmwf.var(count+1).level              = 0;
    count = count + 2;
   case {'wind','uwind','vwind'}
    ecmwf.var(count).variable_name      = 'U10M_sfc';
    ecmwf.var(count).roms_variable_name = 'Uwind';
    ecmwf.var(count).long_name          = 'surface u-wind component';
    ecmwf.var(count).roms_offset        = 0;
    ecmwf.var(count).roms_scale         = 1;
    ecmwf.var(count).units              = 'meter second-1';
    ecmwf.var(count).time_str           = 'wind_time';
    ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.t106.10u.%4d.nc'));
    ecmwf.var(count).field              = 'u-wind, scalar, series';
    ecmwf.var(count).scale_factor       = 1e-3;
    ecmwf.var(count+1).long_name          = 'v-wind component at 10m';
    ecmwf.var(count+1).variable_name      = 'V10M_sfc';
    ecmwf.var(count+1).roms_variable_name = 'Vwind';
    ecmwf.var(count+1).roms_offset        = 0;
    ecmwf.var(count+1).roms_scale         = 1;
    ecmwf.var(count+1).units              = 'meter second-1';
    ecmwf.var(count+1).time_str           = 'wind_time';
    ecmwf.var(count+1).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.t106.10v.%4d.nc'));
    ecmwf.var(count+1).field              = 'v-wind, scalar, series';
    ecmwf.var(count+1).scale_factor       = 1e-3;
    count = count + 2;
   case 'pair'
    ecmwf.var(count).variable_name      = 'MSL_sfc';
    ecmwf.var(count).roms_variable_name = 'Pair';
    ecmwf.var(count).long_name          = 'surface air pressure';
    ecmwf.var(count).roms_offset        = 0;
    ecmwf.var(count).roms_scale         = 0.01;
    ecmwf.var(count).units              = 'millibar';
    ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.t106.msl.%4d.nc'));
    ecmwf.var(count).time_str           = 'pair_time';
    ecmwf.var(count).field              = 'Pair, scalar, series';
    ecmwf.var(count).scale_factor       = 0.1;
    count = count + 1;
   case 'qair'
    ecmwf.var(count).variable_name      = 'D2M_sfc';
    ecmwf.var(count).roms_variable_name = 'Qair';
    ecmwf.var(count).long_name          = 'surface air relative humidity';
    ecmwf.var(count).roms_offset        = -273.15;
    ecmwf.var(count).roms_scale         = 1;
    ecmwf.var(count).units              = 'percentage';
    ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.t106.2d.%4d.nc'));
    ecmwf.var(count).time_str           = 'qair_time';
    ecmwf.var(count).field              = 'Qair, scalar, series';
    ecmwf.var(count).operation          = @op_rhum;
    ecmwf.var(count).scale_factor         = 0.1;
    % 
    % ecmwf.var(count+1).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.t106.2t.%4d.nc'));
    % ecmwf.var(count+1).variable_name      = 'T2M_sfc';
    % ecmwf.var(count+1).roms_offset        = -273.15;
    % ecmwf.var(count+1).roms_scale         = 1;
    % count = count + 2;
    count=count+1;
   case 'lwrad'
    ecmwf.var(count).variable_name      = 'STRD_sfc';
    ecmwf.var(count).roms_variable_name = 'lwrad_down';
    ecmwf.var(count).long_name          = 'net longwave radiation flux';
    ecmwf.var(count).roms_offset        = 0;
    ecmwf.var(count).roms_scale         = 1/(6*3600);
    ecmwf.var(count).units              = 'watt meter-2';
    ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.othr.t106.strd.%4d.nc'));
    ecmwf.var(count).time_str           = 'lrf_time';
    ecmwf.var(count).field              = 'longwave radiation, scalar, series';
    ecmwf.var(count).scale_factor       = 0.1;
    count = count + 1;
   case 'swrad'
    ecmwf.var(count).variable_name      = 'SSRD_sfc';
    ecmwf.var(count).roms_variable_name = 'swrad';
    ecmwf.var(count).long_name          = 'solar shortwave radiation flux';
    ecmwf.var(count).roms_offset        = 0;
    ecmwf.var(count).roms_scale         = 1/(6*3600);
    ecmwf.var(count).units              = 'watt meter-2';
    ecmwf.var(count).file               = strcat(path,'/',num2str(year,'e4oper.an.sfc.othr.t106.ssrd.%4d.nc'));
    ecmwf.var(count).time_str           = 'srf_time';
    ecmwf.var(count).field              = 'shortwave radiation, scalar, series';
    ecmwf.var(count).scale_factor       = 0.1;
    count = count + 1;
  end
end

for i=1:length(ecmwf.var),
  ecmwf.var(i).lon = nc_varget( ecmwf.var(i).file(1,:), 'lon' );
  ecmwf.var(i).lat = nc_varget( ecmwf.var(i).file(1,:), 'lat' );
end
ecmwf.vars = length(ecmwf.var);
