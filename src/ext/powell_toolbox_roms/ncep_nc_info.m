function ncep = ncep_nc_info( ncep_vars, path, tstart, tend, interp_grid )

% function ncep = ncep_nc_info( ncep_vars, path, tstart, tend, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the proper NCEP file based upon the ncep variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 5 )
  interp_grid = true;
end

if ( tstart > tend )
  error('The start date must be before the ending date');
end
tvec = datevec([tstart:tend]);
year = unique(tvec(:,1));
ncep.time_start = tstart;
ncep.time_end = tend;
ncep.interp_grid = interp_grid;
ncep.land_file = [path '/land.sfc.gauss.nc'];

count=1;
for i=1:length(ncep_vars),
  ncep_var = char(ncep_vars(i));
  % Grab the correct information
  switch lower(ncep_var)
   case 'tair'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'air';
    ncep.var(count).roms_variable_name = 'Tair';
    ncep.var(count).long_name          = 'surface air temperature';
    ncep.var(count).roms_offset        = -273.15;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'Celsius';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'air.2m.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'tair_time';
    ncep.var(count).field              = 'Tair, scalar, series';
    ncep.var(count).scale_factor       = 0.01;
    count = count + 1;
   case 'rain'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'prate';
    ncep.var(count).roms_variable_name = 'rain';
    ncep.var(count).long_name          = 'rain fall rate';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'kilogram meter-2 second-1';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'prate.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'rain_time';
    ncep.var(count).field              = 'rain, scalar, series';
    ncep.var(count).scale_factor       = 1.0e-5;
    count = count + 1;
   case {'wind','uwind','vwind'}
    ncep.vars                      = 2;
    ncep.var(count).variable_name      = 'uwnd';
    ncep.var(count).roms_variable_name = 'Uwind';
    ncep.var(count).long_name          = 'surface u-wind component';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'meter second-1';
    ncep.var(count).time_str           = 'wind_time';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'uwnd.10m.gauss.%4d.nc'));
    ncep.var(count).field              = 'u-wind, scalar, series';
    ncep.var(count).scale_factor       = 0.001;
    ncep.var(count+1).long_name          = 'v-wind component at 10m';
    ncep.var(count+1).variable_name      = 'vwnd';
    ncep.var(count+1).roms_variable_name = 'Vwind';
    ncep.var(count+1).roms_offset        = 0;
    ncep.var(count+1).roms_scale         = 1;
    ncep.var(count+1).units              = 'meter second-1';
    ncep.var(count+1).time_str           = 'wind_time';
    ncep.var(count+1).file               = strcat(path,'/',num2str(year,'vwnd.10m.gauss.%4d.nc'));
    ncep.var(count+1).field              = 'v-wind, scalar, series';
    ncep.var(count+1).scale_factor       = 0.001;
    count = count + 2;
   case {'stress','sustr','svstr'}
    ncep.vars                      = 2;
    ncep.var(count).variable_name      = 'uflx';
    ncep.var(count).roms_variable_name = 'sustr';
    ncep.var(count).long_name          = 'surface u-momentum stress';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'N meter-2';
    ncep.var(count).time_str           = 'sms_time';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'uflx.sfc.gauss.%4d.nc'));
    ncep.var(count).field              = 'surface u-momentum stress, scalar, series';
    ncep.var(count+1).long_name          = 'surface v-momentum stress';
    ncep.var(count+1).variable_name      = 'vflx';
    ncep.var(count+1).roms_variable_name = 'svstr';
    ncep.var(count+1).roms_offset        = 0;
    ncep.var(count+1).roms_scale         = 1;
    ncep.var(count+1).units              = 'N meter-2';
    ncep.var(count+1).time_str           = 'sms_time';
    ncep.var(count+1).file               = strcat(path,'/',num2str(year,'vflx.sfc.gauss.%4d.nc'));
    ncep.var(count+1).field              = 'surface v-momentum stress, scalar, series';
    count = count + 2;
   case 'qair'
    ncep.land_file                 = [path '/land.sig995.nc'];
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'rhum';
    ncep.var(count).roms_variable_name = 'Qair';
    ncep.var(count).long_name          = 'surface air relative humidity';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'percentage';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'rhum.sig995.%4d.nc'));
    ncep.var(count).time_str           = 'qair_time';
    ncep.var(count).field              = 'Qair, scalar, series';
    ncep.var(count).scale_factor       = 0.1;
    count = count + 1;
   case 'pair'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'pres';
    ncep.var(count).roms_variable_name = 'Pair';
    ncep.var(count).long_name          = 'surface air pressure';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 0.01;
    ncep.var(count).units              = 'millibar';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'pres.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'pair_time';
    ncep.var(count).field              = 'Pair, scalar, series';
    ncep.var(count).scale_factor       = 0.1;
    count = count + 1;
   case 'slpair'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'slp';
    ncep.var(count).roms_variable_name = 'Pair';
    ncep.var(count).long_name          = 'surface air pressure';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 0.01;
    ncep.var(count).units              = 'millibar';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'slp.%4d.nc'));
    ncep.var(count).time_str           = 'pair_time';
    ncep.var(count).field              = 'Pair, scalar, series';
    ncep.var(count).scale_factor       = 0.1;
    count = count + 1;
   case 'slp'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'slp';
    ncep.var(count).roms_variable_name = 'slp';
    ncep.var(count).long_name          = 'sea level pressure';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 0.01;
    ncep.var(count).units              = 'millibar';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'slp.%4d.nc'));
    ncep.var(count).time_str           = 'slp_time';
    ncep.var(count).field              = 'Pressure, scalar, series';
    count = count + 1;
   case 'lwrad'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'dlwrf';
    ncep.var(count).roms_variable_name = 'lwrad_down';
    ncep.var(count).long_name          = 'down longwave radiation flux';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'watt meter-2';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'dlwrf.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'lrf_time';
    ncep.var(count).field              = 'longwave radiation, scalar, series';
    ncep.var(count).scale_factor       = 0.1;
    count = count + 1;
   case 'lwrad-net'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'nlwrs';
    ncep.var(count).roms_variable_name = 'lwrad';
    ncep.var(count).long_name          = 'net longwave radiation flux';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'watt meter-2';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'nlwrs.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'lrf_time';
    ncep.var(count).field              = 'longwave radiation, scalar, series';
    count = count + 1;
   case 'swrad'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'dswrf';
    ncep.var(count).roms_variable_name = 'swrad';
    ncep.var(count).long_name          = 'solar shortwave radiation flux';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'watt meter-2';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'dswrf.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'srf_time';
    ncep.var(count).field              = 'shortwave radiation, scalar, series';
    ncep.var(count).scale_factor       = 0.1;
    count = count + 1;
   case 'swrad-net'
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'nswrs';
    ncep.var(count).roms_variable_name = 'swrad';
    ncep.var(count).long_name          = 'solar shortwave radiation flux';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'watt meter-2';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'nswrs.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'srf_time';
    ncep.var(count).field              = 'shortwave radiation, scalar, series';
    count = count + 1;
   case 'shflux'
    % This is a composite variable. So, it is only a single variable comprised
    % of several fields added together
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'shtfl';
    ncep.var(count).roms_variable_name = 'shflux';
    ncep.var(count).long_name          = 'surface net heat flux';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = -1;
    ncep.var(count).units              = 'watt meter-2';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'shtfl.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'shf_time';
    ncep.var(count).field              = 'surface heat flux, scalar, series';
    ncep.var(count).operation          = @op_plus;

    ncep.var(count+1).file               = strcat(path,'/',num2str(year,'lhtfl.sfc.gauss.%4d.nc'));
    ncep.var(count+1).variable_name      = 'lhtfl';
    ncep.var(count+1).roms_scale         = -1;

    ncep.var(count+2).file               = strcat(path,'/',num2str(year,'nlwrs.sfc.gauss.%4d.nc'));
    ncep.var(count+2).variable_name      = 'nlwrs';
    ncep.var(count+2).roms_scale         = -1;

    ncep.var(count+3).file               = strcat(path,'/',num2str(year,'nswrs.sfc.gauss.%4d.nc'));
    ncep.var(count+3).variable_name      = 'nswrs';
    ncep.var(count+3).roms_scale         = -1;
    count = count + 4;
   case 'sst'
    % This is a composite variable. So, it will only save two values: SST
    % and dQdSST, calculated by the other variables.
    ncep.vars                      = 2;
    ncep.var(count).variable_name      = 'skt';
    ncep.var(count).roms_variable_name = 'SST';
    ncep.var(count).long_name          = 'sea surface temperature climatology';
    ncep.var(count).roms_offset        = -273.15;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'Celsius';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'skt.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'sst_time';
    ncep.var(count).field              = 'SST, scalar, series';
    ncep.var(count).operation          = @op_dqdsst;

    ncep.var(count+1).variable_name      = 'air';
    ncep.var(count+1).file               = strcat(path,'/',num2str(year,'air.2m.gauss.%4d.nc'));
    ncep.var(count+1).roms_variable_name = 'dQdSST';
    ncep.var(count+1).long_name          = 'surface net heat flux sensitivity to SST';
    ncep.var(count+1).roms_offset        = -273.15;
    ncep.var(count+1).roms_scale         = 1;
    ncep.var(count+1).units              = 'watt meter-2 Celsius-1';
    ncep.var(count+1).time_str           = 'sst_time';
    ncep.var(count+1).field              = 'dQdSST, scalar, series';

    ncep.var(count+2).variable_name      = 'rhum';
    ncep.var(count+2).file               = strcat(path,'/',num2str(year,'rhum.sig995.%4d.nc'));
    ncep.var(count+2).roms_scale         = 1;

    ncep.var(count+3).variable_name      = 'pres';
    ncep.var(count+3).file               = strcat(path,'/',num2str(year,'pres.sfc.gauss.%4d.nc'));
    ncep.var(count+3).roms_scale         = 0.01;

    ncep.var(count+4).variable_name      = 'uwnd';
    ncep.var(count+4).file               = strcat(path,'/',num2str(year,'uwnd.10m.gauss.%4d.nc'));
    ncep.var(count+4).roms_scale         = 1;

    ncep.var(count+5).variable_name      = 'vwnd';
    ncep.var(count+5).file               = strcat(path,'/',num2str(year,'vwnd.10m.gauss.%4d.nc'));
    ncep.var(count+5).roms_scale         = 1;
    count = count + 6;

   case 'swflux'
    % This is a composite variable. So, it will only save swflux
    ncep.vars                      = 1;
    ncep.var(count).variable_name      = 'prate';
    ncep.var(count).roms_variable_name = 'swflux';
    ncep.var(count).long_name          = 'surface net freswater flux, (E-P)';
    ncep.var(count).roms_offset        = 0;
    ncep.var(count).roms_scale         = 1;
    ncep.var(count).units              = 'centimeter day-1';
    ncep.var(count).file               = strcat(path,'/',num2str(year,'prate.sfc.gauss.%4d.nc'));
    ncep.var(count).time_str           = 'swf_time';
    ncep.var(count).field              = 'surface net salt flux, scalar, series';
    ncep.var(count).operation          = @op_swflux;
    
    ncep.var(count+1).file               = strcat(path,'/',num2str(year,'lhtfl.sfc.gauss.%4d.nc'));
    ncep.var(count+1).variable_name      = 'lhtfl';
    ncep.var(count+1).roms_scale         = -1;
    count = count + 2;
  end
end

for i=1:length(ncep.var),
  ncep.var(i).lon = nc_varget( ncep.var(i).file(1,:), 'lon' );
  ncep.var(i).lat = nc_varget( ncep.var(i).file(1,:), 'lat' );
end
ncep.land_mask = abs(squeeze(nc_varget(ncep.land_file,'land')) - 1);
ncep.vars = length(ncep.var);
