function zgrid_write( zgrid, filename, epoch, username )

% ini_write( grid, filename )
%
% Given a grid, create a blank initialization file
%
%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin<2)
  error('you must specify a filename');
end
if (nargin<3 | isempty(epoch) )
  epoch='days since 0000-01-01 00:00:00';
else
  if (isnumeric(epoch))
    epoch=['days since ' datestr(epoch,31) ];
  end
end

% Create the file
[id, status]=mexnc('create', filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' filename] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( filename, nc_global, 'title', 'Z Grid File' );
[a,user]=unix('pinky `whoami`'); %update of finger to pinky commands. Finger not installed on Gadi. Neither work on VDI.
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
%if isempty(user); user=[]; user.name = input('user.name can''t be automatically filled, please enter name'); end
if (nargin>=3 | ~isempty(username));
	user=[]; user.name=username; disp('setting user name from input')
end
nc_attput( filename, nc_global, 'author', user.name );
nc_attput( filename, nc_global, 'date', datestr(now));
nc_attput( filename, nc_global, 'type', 'ROMS Initialization');
nc_attput( filename, nc_global, 'Conventions', 'CF-1.0');

% Add the dimensions
nc_add_dimension( filename, 'lat',  length(zgrid.lat) );
nc_add_dimension( filename, 'lon',  length(zgrid.lon));
nc_add_dimension( filename, 'depth',length(zgrid.depth) );
nc_add_dimension( filename, 'time', 0 );

% Add the variables
rec = [];
rec.Name = 'lat';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('lat');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'Latitude';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, zgrid.lat);

rec = [];
rec.Name = 'lon';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'Longitude';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, zgrid.lon);

rec = [];
rec.Name = 'depth';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('depth');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'Z-Level Depth';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, zgrid.depth);

rec = [];
rec.Name = 'time';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('time');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'time since initialization';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = epoch;
nc_addvar( filename, rec );
if isfield(zgrid, 'time'),
  nc_varput( filename, rec.Name, zgrid.time);
end

rec = [];
rec.Name = 'zeta';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('time');
rec.Dimension(2) = cellstr('lat');
rec.Dimension(3) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'free-surface';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'u';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('time');
rec.Dimension(2) = cellstr('depth');
rec.Dimension(3) = cellstr('lat');
rec.Dimension(4) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'u-momentum component';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter second-1';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'v';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('time');
rec.Dimension(2) = cellstr('depth');
rec.Dimension(3) = cellstr('lat');
rec.Dimension(4) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'v-momentum component';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter second-1';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'temp';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('time');
rec.Dimension(2) = cellstr('depth');
rec.Dimension(3) = cellstr('lat');
rec.Dimension(4) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'potential temperature';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'Celsius';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'salt';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('time');
rec.Dimension(2) = cellstr('depth');
rec.Dimension(3) = cellstr('lat');
rec.Dimension(4) = cellstr('lon');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'salinity';
nc_addvar( filename, rec );
