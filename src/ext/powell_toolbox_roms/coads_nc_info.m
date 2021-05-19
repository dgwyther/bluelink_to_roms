function coads = coads_nc_info( coads_vars, file, tstart, tend, interp_grid )

% function coads = coads_nc_info( coads_vars, coads_file, tstart, tend, interp_grid )
%
% 
% This function will return a structure of information needed about
% extracting data from the proper COADS file based upon the coads variable
% wanted (use standard ROMS files from varinfo.dat).

if ( nargin < 5 )
  interp_grid = true;
end

if ( tstart > tend )
  error('The start date must be before the ending date');
end
tvec = datevec([tstart:tend]);
year = unique(tvec(:,1));
coads.time_start = tstart;
coads.time_end = tend;
coads.interp_grid = interp_grid;
coads.input_file = file;

count=1;
for i=1:length(coads_vars),
  coads_var = char(coads_vars(i));
  % Grab the correct information
  switch lower(coads_var)
   case 'tair'
    coads.vars                      = 1;
    coads.var(count).variable_name      = 'AIR';
    coads.var(count).roms_variable_name = 'Tair';
    coads.var(count).long_name          = 'surface air temperature';
    coads.var(count).roms_offset        = 0;
    coads.var(count).roms_scale         = 1;
    coads.var(count).units              = 'Celsius';
    coads.var(count).file               = coads.input_file;
    coads.var(count).time_str           = 'tair_time';
    coads.var(count).field              = 'Tair, scalar, series';
    count = count + 1;
   case {'wind','uwind','vwind'}
    coads.vars                      = 2;
    coads.var(count).variable_name      = 'UWND';
    coads.var(count).roms_variable_name = 'Uwind';
    coads.var(count).long_name          = 'surface u-wind component';
    coads.var(count).roms_offset        = 0;
    coads.var(count).roms_scale         = 1;
    coads.var(count).units              = 'meter second-1';
    coads.var(count).time_str           = 'wind_time';
    coads.var(count).file               = coads.input_file;
    coads.var(count).field              = 'u-wind, scalar, series';
    coads.var(count+1).long_name          = 'v-wind component at 10m';
    coads.var(count+1).variable_name      = 'VWND';
    coads.var(count+1).roms_variable_name = 'Vwind';
    coads.var(count+1).roms_offset        = 0;
    coads.var(count+1).roms_scale         = 1;
    coads.var(count+1).units              = 'meter second-1';
    coads.var(count+1).time_str           = 'wind_time';
    coads.var(count+1).file               = coads.input_file;
    coads.var(count+1).field              = 'v-wind, scalar, series';
    count = count + 2;
   case {'stress','sustr','svstr'}
    coads.vars                      = 2;
    coads.var(count).variable_name      = 'uflx';
    coads.var(count).roms_variable_name = 'sustr';
    coads.var(count).long_name          = 'surface u-momentum stress';
    coads.var(count).roms_offset        = 0;
    coads.var(count).roms_scale         = 1;
    coads.var(count).units              = 'N meter-2';
    coads.var(count).time_str           = 'sms_time';
    coads.var(count).file               = strcat(path,'/',num2str(year,'uflx.sfc.gauss.%4d.nc'));
    coads.var(count).field              = 'surface u-momentum stress, scalar, series';
    coads.var(count+1).long_name          = 'surface v-momentum stress';
    coads.var(count+1).variable_name      = 'vflx';
    coads.var(count+1).roms_variable_name = 'svstr';
    coads.var(count+1).roms_offset        = 0;
    coads.var(count+1).roms_scale         = 1;
    coads.var(count+1).units              = 'N meter-2';
    coads.var(count+1).time_str           = 'sms_time';
    coads.var(count+1).file               = strcat(path,'/',num2str(year,'vflx.sfc.gauss.%4d.nc'));
    coads.var(count+1).field              = 'surface v-momentum stress, scalar, series';
    count = count + 2;
   case 'qair'
    coads.vars                      = 1;
    coads.var(count).variable_name      = 'RHUM';
    coads.var(count).roms_variable_name = 'Qair';
    coads.var(count).long_name          = 'surface air relative humidity';
    coads.var(count).roms_offset        = 0;
    coads.var(count).roms_scale         = 1;
    coads.var(count).units              = 'percentage';
    coads.var(count).file               = coads.input_file;
    coads.var(count).time_str           = 'qair_time';
    coads.var(count).field              = 'Qair, scalar, series';
    count = count + 1;
   case 'slp'
    coads.vars                      = 1;
    coads.var(count).variable_name      = 'SLP';
    coads.var(count).roms_variable_name = 'slp';
    coads.var(count).long_name          = 'sea level pressure';
    coads.var(count).roms_offset        = 0;
    coads.var(count).roms_scale         = 0.01;
    coads.var(count).units              = 'millibar';
    coads.var(count).file               = strcat(path,'/',num2str(year,'slp.%4d.nc'));
    coads.var(count).time_str           = 'slp_time';
    coads.var(count).field              = 'Pressure, scalar, series';
    count = count + 1;
   case 'shflux'
    % This is a composite variable. So, it is only a single variable comprised
    % of several fields added together
    coads.vars                      = 1;
    coads.var(count).variable_name      = 'shtfl';
    coads.var(count).roms_variable_name = 'shflux';
    coads.var(count).long_name          = 'surface net heat flux';
    coads.var(count).roms_offset        = 0;
    coads.var(count).roms_scale         = -1;
    coads.var(count).units              = 'watt meter-2';
    coads.var(count).file               = strcat(path,'/',num2str(year,'shtfl.sfc.gauss.%4d.nc'));
    coads.var(count).time_str           = 'shf_time';
    coads.var(count).field              = 'surface heat flux, scalar, series';
    coads.var(count).operation          = @op_plus;

    coads.var(count+1).file               = strcat(path,'/',num2str(year,'lhtfl.sfc.gauss.%4d.nc'));
    coads.var(count+1).variable_name      = 'lhtfl';
    coads.var(count+1).roms_scale         = -1;

    coads.var(count+2).file               = strcat(path,'/',num2str(year,'nlwrs.sfc.gauss.%4d.nc'));
    coads.var(count+2).variable_name      = 'nlwrs';
    coads.var(count+2).roms_scale         = -1;

    coads.var(count+3).file               = strcat(path,'/',num2str(year,'nswrs.sfc.gauss.%4d.nc'));
    coads.var(count+3).variable_name      = 'nswrs';
    coads.var(count+3).roms_scale         = -1;
    count = count + 4;
   case 'sst'
    % This is a composite variable. So, it will only save two values: SST
    % and dQdSST, calculated by the other variables.
    coads.vars                      = 2;
    coads.var(count).variable_name      = 'skt';
    coads.var(count).roms_variable_name = 'SST';
    coads.var(count).long_name          = 'sea surface temperature climatology';
    coads.var(count).roms_offset        = -273.15;
    coads.var(count).roms_scale         = 1;
    coads.var(count).units              = 'Celsius';
    coads.var(count).file               = strcat(path,'/',num2str(year,'skt.sfc.gauss.%4d.nc'));
    coads.var(count).time_str           = 'sst_time';
    coads.var(count).field              = 'SST, scalar, series';
    coads.var(count).operation          = @op_dqdsst;

    coads.var(count+1).variable_name      = 'air';
    coads.var(count+1).file               = strcat(path,'/',num2str(year,'air.2m.gauss.%4d.nc'));
    coads.var(count+1).roms_variable_name = 'dQdSST';
    coads.var(count+1).long_name          = 'surface net heat flux sensitivity to SST';
    coads.var(count+1).roms_offset        = -273.15;
    coads.var(count+1).roms_scale         = 1;
    coads.var(count+1).units              = 'watt meter-2 Celsius-1';
    coads.var(count+1).time_str           = 'sst_time';
    coads.var(count+1).field              = 'dQdSST, scalar, series';

    coads.var(count+2).variable_name      = 'rhum';
    coads.var(count+2).file               = strcat(path,'/',num2str(year,'rhum.sig995.%4d.nc'));
    coads.var(count+2).roms_scale         = 1;

    coads.var(count+3).variable_name      = 'pres';
    coads.var(count+3).file               = strcat(path,'/',num2str(year,'pres.sfc.gauss.%4d.nc'));
    coads.var(count+3).roms_scale         = 0.01;

    coads.var(count+4).variable_name      = 'uwnd';
    coads.var(count+4).file               = strcat(path,'/',num2str(year,'uwnd.10m.gauss.%4d.nc'));
    coads.var(count+4).roms_scale         = 1;

    coads.var(count+5).variable_name      = 'vwnd';
    coads.var(count+5).file               = strcat(path,'/',num2str(year,'vwnd.10m.gauss.%4d.nc'));
    coads.var(count+5).roms_scale         = 1;
    count = count + 6;
  end
end

% Grab the lat/lon
dn=nc_dim(coads.input_file);
for i=1:size(dn,1),
  if (regexp(dn(i,:),'LON'))
    lonv=dn(i,:);
  elseif ( regexp(dn(i,:),'LAT'))
    latv=dn(i,:);
  end
end

for i=1:length(coads.var),
  coads.var(i).lon = nc_varget( coads.var(i).file(1,:), lonv );
  l=find(coads.var(i).lon<0);
  if ( ~isempty(l) )
    coads.var(i).lon(l)=coads.var(i).lon(l)+360;
  end
  coads.var(i).lat = nc_varget( coads.var(i).file(1,:), latv );
end
coads.vars = length(coads.var);
