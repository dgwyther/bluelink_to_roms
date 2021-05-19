function create_netcdf( nc )

if ( isfield(nc,'epoch') )
  epoch_str = ['days since ' datestr(nc.epoch, 'yyyy-mm-dd HH:MM:SS') ' GMT'];
  epoch = julian(datevec(nc.epoch));
else
  epoch_str = 'days since 0000-01-01 00:00:00 GMT';
  epoch = 0;
end

% Create an empty file
fprintf( 1,'Write Forcing File: %s\n', nc.output_file );
[id, status]=mexnc('create', nc.output_file, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' nc.output_file] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( nc.output_file, 'GLOBAL', 'title', 'nc Bulk Forcing Data' );
nc_attput( nc.output_file, 'GLOBAL', 'author', 'B.S. Powell');
nc_attput( nc.output_file, 'GLOBAL', 'date', datestr(now));
nc_attput( nc.output_file, 'GLOBAL', 'type', 'ROMS forcing');
nc_attput( nc.output_file, 'GLOBAL', 'Conventions', 'CF-1.0');
nc_add_dimension( nc.output_file, nc.var(1).time_str, 0 );
if ( nc.roms_grid == true )
  nc_add_dimension( nc.output_file, 'eta_rho', nc.var(1).eta );
  nc_add_dimension( nc.output_file, 'xi_rho', nc.var(1).xi );
else
  nc_add_dimension( nc.output_file, 'lat', length(nc.var(1).lat) );
  nc_add_dimension( nc.output_file, 'lon', length(nc.var(1).lon) );
  
  % Add the lat and lon vectors
  rec = [];
  rec.Name = 'lat';
  rec.Nctype = 'NC_DOUBLE';
  rec.Dimension(1) = cellstr('lat');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'Latitude';
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = 'degrees_north';
  nc_addvar( nc.output_file, rec );
  nc_varput( nc.output_file, 'lat', nc.var(1).lat(:) );
  rec = [];
  rec.Name = 'lon';
  rec.Nctype = 'NC_DOUBLE';
  rec.Dimension(1) = cellstr('lon');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'Longitude';
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = 'degrees_east';
  nc_addvar( nc.output_file, rec );
  nc_varput( nc.output_file, 'lon', nc.var(1).lon(:) );
end

% Add the Time Information
rec = [];
rec.Name = nc.var(1).time_str;
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr(nc.var(1).time_str);
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = [nc.var(1).long_name ' time'];
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = epoch_str;
% rec.Attribute(3).Name = 'calendar';
% rec.Attribute(3).Value = 'gregorian';
% rec.Attribute(4).Name = 'add_offset';
% rec.Attribute(4).Value = epoch;
rec.Attribute(5).Name = 'field';
rec.Attribute(5).Value = [nc.var(1).time_str ', scalar, series'];
% if ( epoch )
%   rec.Attribute(6).Name = 'start_date';
%   rec.Attribute(6).Value = datestr(nc.var(1).data_time(1), 1);
%   rec.Attribute(7).Name = 'end_date';
%   rec.Attribute(7).Value = datestr(nc.var(1).data_time(end), 1);
% end

nc_addvar( nc.output_file, rec );
