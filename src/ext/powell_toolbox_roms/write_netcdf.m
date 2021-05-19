function write_netcdf( nc, file, epoch, use_short )

% function write_netcdf( nc )
%
% This function writes the contents of the nc structure
% into a NetCDF file.

if ( nargin < 4 )
  use_short = false;
end
if ( nargin > 2 )
  epoch_str = ['days since ' datestr(epoch, 'yyyy-mm-dd HH:MM:SS') ' GMT'];
  epoch = julian(datevec(epoch));
else
  epoch_str = 'days since 0000-01-01 00:00:00 GMT';
  epoch = 0;
end
nc.output_file = file;
tic
% Create an empty file
fprintf( 1,'Write Forcing File: %s\n', nc.output_file );
[id, status]=mexnc('create', nc.output_file, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' nc.output_file] )
end
mexnc('close',id);

% Are we specifying a matrix or vector for position?
if ~isvector(nc.var(1).lat),
  lat = nc.var(1).lat;
  lon = nc.var(1).lon;
else
  [lon,lat]=meshgrid(nc.var(1).lon,nc.var(1).lat);
end


% Set the global variables for the file
nc_attput( nc.output_file, nc_global, 'title', 'nc Bulk Forcing Data' );
nc_attput( nc.output_file, nc_global, 'author', 'C. Kerry');
nc_attput( nc.output_file, nc_global, 'date', datestr(now));
nc_attput( nc.output_file, nc_global, 'type', 'ROMS forcing');
nc_attput( nc.output_file, nc_global, 'Conventions', 'CF-1.0');
if ( nc.roms_grid == true )
  nc_add_dimension( nc.output_file, 'eta_rho', size(nc.var(1).data,2) );
  nc_add_dimension( nc.output_file, 'xi_rho', size(nc.var(1).data,3) );
  nc_add_dimension( nc.output_file, 'eta_u', size(nc.var(1).data,2) );
  nc_add_dimension( nc.output_file, 'xi_u', size(nc.var(1).data,3)-1 );
  nc_add_dimension( nc.output_file, 'eta_v', size(nc.var(1).data,2)-1 );
  nc_add_dimension( nc.output_file, 'xi_v', size(nc.var(1).data,3) );
else
  nc_add_dimension( nc.output_file, 'lat', size(lat,1) );
  nc_add_dimension( nc.output_file, 'lon', size(lon,2) );
  
  % Add the lat and lon matrices
  rec = [];
  rec.Name = 'lat';
  rec.Nctype = 'NC_FLOAT';
  rec.Dimension(1) = cellstr('lat');
  rec.Dimension(2) = cellstr('lon');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'Latitude';
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = 'degrees_north';
  nc_addvar( nc.output_file, rec );
  nc_varput( nc.output_file, 'lat', single(lat) );
  rec = [];
  rec.Name = 'lon';
  rec.Nctype = 'NC_FLOAT';
  rec.Dimension(1) = cellstr('lat');
  rec.Dimension(2) = cellstr('lon');
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = 'Longitude';
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = 'degrees_east';
  nc_addvar( nc.output_file, rec );
  nc_varput( nc.output_file, 'lon', single(lon) );
end

used = {'**'};
for i=1:nc.vars,
  toc; tic
  disp(nc.var(i).roms_variable_name)
  if ( isempty(find(strcmp(used,nc.var(i).time_str))) & ~isempty(nc.var(i).data))
    used(end+1) = {nc.var(i).time_str};
    % Add the Time Dimension
    nc_add_dimension( nc.output_file, nc.var(i).time_str, size(nc.var(i).data,1) );
    
    % Add the Time Information
    rec = [];
    rec.Name = nc.var(i).time_str;
    rec.Nctype = 'NC_FLOAT';
    rec.Dimension(1) = cellstr(nc.var(i).time_str);
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = [nc.var(i).long_name ' time'];
    rec.Attribute(2).Name = 'units';
    if ( isfield(nc.var(i),'epoch_str') )
      rec.Attribute(2).Value = nc.var(i).epoch_str;
    else
      rec.Attribute(2).Value = epoch_str;
    end
    % rec.Attribute(3).Name = 'calendar';
    % rec.Attribute(3).Value = 'gregorian';
    % rec.Attribute(4).Name = 'add_offset';
    % rec.Attribute(4).Value = epoch;
    % rec.Attribute(5).Name = 'field';
    % rec.Attribute(5).Value = [nc.var(i).time_str ', scalar, series'];
    if ( epoch )
      rec.Attribute(3).Name = 'start_date';
      rec.Attribute(3).Value = datestr(nc.var(i).data_time(1), 1);
      rec.Attribute(4).Name = 'end_date';
      rec.Attribute(4).Value = datestr(nc.var(i).data_time(end), 1);
    end
    nc_addvar( nc.output_file, rec );

    % Add the Time Data
    if ( epoch )
      nc_varput( nc.output_file, nc.var(i).time_str, ...
                 single(julian(datevec(nc.var(i).data_time)) - epoch) );
    else
      nc_varput( nc.output_file, nc.var(i).time_str, single(nc.var(i).data_time) );
    end
  end

  % Add the variable information
  if (~isfield(nc.var(i),'roms_variable_name') | isempty(nc.var(i).data))
    continue; 
  end
  rec = [];
  rec.Name = nc.var(i).roms_variable_name;
  if ( use_short )
    rec.Nctype = 'NC_SHORT';
  else
    rec.Nctype = 'NC_FLOAT';
  end
  rec.Dimension(1) = cellstr(nc.var(i).time_str);
  if ( nc.roms_grid == true )
    rec.Dimension(2) = cellstr('eta_rho');
    rec.Dimension(3) = cellstr('xi_rho');
    if ( isfield(nc.var(i),'roms_u') & nc.var(i).roms_u )
      rec.Dimension(2) = cellstr('eta_u');
      rec.Dimension(3) = cellstr('xi_u');
    elseif ( isfield(nc.var(i),'roms_v')  & nc.var(i).roms_v  )
      rec.Dimension(2) = cellstr('eta_v');
      rec.Dimension(3) = cellstr('xi_v');
    end
  else
    rec.Dimension(2) = cellstr('lat');
    rec.Dimension(3) = cellstr('lon');
  end
  rec.Attribute(1).Name = 'long_name';
  rec.Attribute(1).Value = nc.var(i).long_name;
  rec.Attribute(2).Name = 'units';
  rec.Attribute(2).Value = nc.var(i).units;
  rec.Attribute(3).Name = 'coordinates';
  if ( nc.roms_grid == true )
    rec.Attribute(3).Value = [char(rec.Dimension(2)) ' ' char(rec.Dimension(3))];
  else
    rec.Attribute(3).Value = 'lon lat';
  end
  rec.Attribute(4).Name = 'field';
  rec.Attribute(4).Value = nc.var(i).field;
  rec.Attribute(5).Name = 'time';
  rec.Attribute(5).Value = nc.var(i).time_str;
  cnt=6;
  if use_short
    rec.Attribute(5).Name = 'scale_factor';
    rec.Attribute(5).Value = nc.var(i).scale_factor;
    cnt=cnt+1;
  end
  % See if there are any NaN values
  nan_list = find( isnan( nc.var(i).data ));
  if ( ~isempty( nan_list ))
    rec.Attribute(cnt).Name = 'missing_value';
    rec.Attribute(cnt).Value = -999999.0;
    nc.var(i).data(nan_list) = -999999.0;
  elseif (isfield(nc.var(i),'bad'))
    rec.Attribute(cnt).Name = 'missing_value';
    rec.Attribute(cnt).Value = nc.var(i).bad;
  end
  nc_addvar( nc.output_file, rec );
  % Add the Variable Data
  nc_varput( nc.output_file, nc.var(i).roms_variable_name, nc.var(i).data );
end   
  toc

