function srelax_write( grid, filename, numrecs )

% srelax_write( grid, filename, [numrecs] )
%
% Given a grid, create a blank SSS file
%
%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin<2)
  error('you must specify a filename');
end
if (nargin<3)
  numrecs=12;
end

% Create the file
[id, status]=mexnc('create', filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' filename] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( filename, nc_global, 'title', 'Sea Surface Salinity Relaxation File' );
[a,user]=unix('finger `whoami`');
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
nc_attput( filename, nc_global, 'author', user.name );
nc_attput( filename, nc_global, 'date', datestr(now));
nc_attput( filename, nc_global, 'type', 'ROMS');
nc_attput( filename, nc_global, 'Conventions', 'CF-1.0');

% Add the dimensions
nc_add_dimension( filename, 'xi_rho', grid.lp );
nc_add_dimension( filename, 'eta_rho', grid.mp );
nc_add_dimension( filename, 'sss_time', numrecs );

% Add the variables
rec = [];
rec.Name = 'sss_time';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('sss_time');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'time for sea surface salinity';
rec.Attribute(2).Name = 'field';
rec.Attribute(2).Value = 'time, scalar, series';
if ( numrecs == 12 )
  rec.Attribute(3).Name = 'cycle_length';
  rec.Attribute(3).Value = 365.25;
end
nc_addvar( filename, rec );

rec = [];
rec.Nctype = 'NC_DOUBLE';
rec.Name = 'SSS';
rec.Dimension(1) = cellstr('sss_time');
rec.Dimension(2) = cellstr('eta_rho');
rec.Dimension(3) = cellstr('xi_rho');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'sea surface salinity';
rec.Attribute(2).Name = 'time';
rec.Attribute(2).Value = 'sss_time';
rec.Attribute(3).Name = 'field';
rec.Attribute(3).Value = 'SSS, scalar, series';
nc_addvar( filename, rec );
