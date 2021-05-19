function cora = cora_bln_info( var, path, tstart, tend, interp_grid )

% function cora = cora_bln_info( path, tstart, tend, interp_grid )
% 
% This function will return a structure of information needed about
% extracting data from the proper CORA blended wind product files
% This product is available from 7/1999 onward
epoch = datenum(1999,7,1);

if ( nargin < 4 )
  interp_grid = true;
end

if ( tstart > tend )
  error('The start date must be before the ending date');
end
% Because the CORA files end with the first record of the NEXT month (annoying)
% then we must start with the prior day, just in case
[y,m] = datevec([tstart-1:tend]);
times = unique( y*100+m );
cora.time_start = max(epoch, tstart);
cora.time_end = tend;
cora.interp_grid = interp_grid;

switch lower(var)
  case 'wind'
    cora.vars                      = 2;
    cora.var(1).long_name          = 'surface u-wind component';
    cora.var(1).roms_variable_name = 'Uwind';
    cora.var(1).roms_offset        = 0;
    cora.var(1).roms_scale         = 1;
    cora.var(1).units              = 'meter second-1';
    cora.var(1).time_str           = 'wind_time';
    cora.var(1).file               = strcat(path,'/',num2str(times','uv.%d.bln'));
    cora.var(1).epoch_year         = floor(times/100);
    cora.var(1).field              = 'u-wind, scalar, series';

    cora.var(2).long_name          = 'v-wind component at 10m';
    cora.var(2).roms_variable_name = 'Vwind';
    cora.var(2).roms_offset        = 0;
    cora.var(2).roms_scale         = 1;
    cora.var(2).units              = 'meter second-1';
    cora.var(2).time_str           = 'wind_time';
    cora.var(2).file               = strcat(path,'/',num2str(times','uv.%d.bln'));
    cora.var(2).epoch_year         = floor(times/100);
    cora.var(2).field              = 'v-wind, scalar, series';

  case 'stress'
    cora.vars                      = 2;
    cora.var(1).long_name          = 'surface u-momentum stress';
    cora.var(1).roms_variable_name = 'sustr';
    cora.var(1).roms_offset        = 0;
    cora.var(1).roms_scale         = 1;
    cora.var(1).units              = 'N meter-2';
    cora.var(1).time_str           = 'sms_time';
    cora.var(1).file               = strcat(path,'/',num2str(times','uv.%d.bln'));
    cora.var(1).epoch_year         = floor(times/100);
    cora.var(1).field              = 'surface u-momentum stress, scalar, series';
    cora.var(1).operation          = @op_cora_str;

    cora.var(2).long_name          = 'surface v-momentum stress';
    cora.var(2).roms_variable_name = 'svstr';
    cora.var(2).roms_offset        = 0;
    cora.var(2).roms_scale         = 1;
    cora.var(2).units              = 'N meter-2';
    cora.var(2).time_str           = 'sms_time';
    cora.var(2).file               = strcat(path,'/',num2str(times','uv.%d.bln'));
    cora.var(2).epoch_year         = floor(times/100);
    cora.var(2).field              = 'surface v-momentum stress, scalar, series';

  otherwise
    cora.vars = 0;
end

% Set the lat/lon fields for CORA
for i=1:cora.vars,
  cora.var(i).def_lon = linspace(0.5,360,720)';
  cora.var(i).def_lat = linspace(-88,88,353)';
end
