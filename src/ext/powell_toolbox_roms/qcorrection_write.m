function qcorrection_write( filename, sst, dqdsst, lon, lat, time )

% qcorrection_write( filename, sst, dqdsst )
%
% Create a Qcorrection file from the sst and dqdsst
%
%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin<5)
  error('you must specify a filename');
end
if (nargin<6)
  time=[];
end

% Create the file
[id, status]=mexnc('create', filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' filename] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( filename, nc_global, 'title', 'QCorrection File' );
[a,user]=unix('finger `whoami`');
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
nc_attput( filename, nc_global, 'author', user.name );
nc_attput( filename, nc_global, 'date', datestr(now));
nc_attput( filename, nc_global, 'type', 'ROMS');
nc_attput( filename, nc_global, 'Conventions', 'CF-1.0');

% Add the dimensions
nc_add_dimension( filename, 'lat', size(sst,2) );
nc_add_dimension( filename, 'lon', size(sst,3) );
nc_add_dimension( filename, 'sst_time', size(sst, 1) );

% Add the variables
rec = [];
rec.Name = 'lat';
rec.Nctype = 'NC_FLOAT';
if ( ndims(lat)==2 )
  rec.Dimension(1) = cellstr('lat');
  rec.Dimension(2) = cellstr('lon');
else
  rec.Dimension(1) = cellstr('lat');
end
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'Latitude';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'degrees_north';
nc_addvar( filename, rec );
nc_varput( filename, 'lat', single(lat) );

rec = [];
rec.Name = 'lon';
rec.Nctype = 'NC_FLOAT';
if ( ndims(lat)==2 )
  rec.Dimension(1) = cellstr('lat');
  rec.Dimension(2) = cellstr('lon');
else
  rec.Dimension(1) = cellstr('lon');
end
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'Longitude';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'degrees_east';
nc_addvar( filename, rec );
nc_varput( filename, 'lon', single(lon) );

rec = [];
rec.Name = 'sst_time';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('sst_time');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'time for sea surface temperature';
rec.Attribute(2).Name = 'field';
rec.Attribute(2).Value = 'time, scalar, series';
if (isempty(time))
  rec.Attribute(3).Name = 'cycle_length';
  rec.Attribute(3).Value = 365.25;
  dt=floor(360/size(sst,1));
  time=[floor(dt/2):dt:365];
end
nc_addvar( filename, rec );
nc_varput( filename, 'sst_time', time);

rec = [];
rec.Nctype = 'NC_DOUBLE';
rec.Name = 'SST';
rec.Dimension(1) = cellstr('sst_time');
rec.Dimension(2) = cellstr('lat');
rec.Dimension(3) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'sea surface temperature climatology';
rec.Attribute(2).Name = 'time';
rec.Attribute(2).Value = 'sst_time';
rec.Attribute(3).Name = 'field';
rec.Attribute(3).Value = 'SST, scalar, series';
rec.Attribute(4).Name = 'units';
rec.Attribute(4).Value = 'degrees Celcius';
rec.Attribute(5).Name = 'coordinates';
rec.Attribute(5).Value = 'lon lat';
nc_addvar( filename, rec );
nc_varput( filename, 'SST', sst);

rec = [];
rec.Nctype = 'NC_DOUBLE';
rec.Name = 'dQdSST';
rec.Dimension(1) = cellstr('sst_time');
rec.Dimension(2) = cellstr('lat');
rec.Dimension(3) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'surface net heat flux sensitivity to SST';
rec.Attribute(2).Name = 'time';
rec.Attribute(2).Value = 'sst_time';
rec.Attribute(3).Name = 'field';
rec.Attribute(3).Value = 'dQdSST, scalar, series';
rec.Attribute(4).Name = 'units';
rec.Attribute(4).Value = 'watt meter-2';
rec.Attribute(5).Name = 'coordinates';
rec.Attribute(5).Value = 'lon lat';
nc_addvar( filename, rec );
nc_varput( filename, 'dQdSST', dqdsst);

