function clim_write( grid, filename, vars, numrecs )

% clim_write( grid, filename, [vars], [numrecs] )
%
% Given a grid, create a blank climatology file
%
%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin<2)
  error('you must specify a filename');
end
if (nargin<3)
  vars={'temp' 'salt'};
end
if (nargin<4)
  numrecs=4;
end

% Create the file
[id, status]=mexnc('create', filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' filename] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( filename, nc_global, 'title', 'Climatology File' );
[a,user]=unix('finger `whoami`');
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
if isempty(user); user=[]; [~,matchuser] = system('echo $USER'); user.name = matchuser(regexp(matchuser,'\w')); disp(['setting user name to ',user.name]);end
nc_attput( filename, nc_global, 'author', user.name );
nc_attput( filename, nc_global, 'date', datestr(now));
nc_attput( filename, nc_global, 'type', 'ROMS Initialization');
nc_attput( filename, nc_global, 'Conventions', 'CF-1.0');

% Add the dimensions
nc_add_dimension( filename, 'xi_rho', grid.lp );
nc_add_dimension( filename, 'xi_u', grid.l );
nc_add_dimension( filename, 'xi_v', grid.lp );
nc_add_dimension( filename, 'eta_rho', grid.mp );
nc_add_dimension( filename, 'eta_u', grid.mp );
nc_add_dimension( filename, 'eta_v', grid.m );
nc_add_dimension( filename, 's_rho', grid.n );
nc_add_dimension( filename, 's_w', grid.n+1 );
nc_add_dimension( filename, 'tracer', grid.tracer );

% Add the variables

for v=1:length(vars)
  switch lower(char(vars(v)))
    case 'zeta'
      nc_add_dimension( filename, 'zeta_time', numrecs );
      rec = [];
      rec.Name = 'zeta_time';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('zeta_time');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'free-surface climatology time';
      rec.Attribute(2).Name = 'cycle_length';
      rec.Attribute(2).Value = 365.25;
      rec.Attribute(3).Name = 'field';
      rec.Attribute(3).Value = 'time, scalar, series';
      nc_addvar( filename, rec );

      rec = [];
      rec.Nctype = 'NC_DOUBLE';
      rec.Name = 'zeta';
      rec.Dimension(1) = cellstr('zeta_time');
      rec.Dimension(2) = cellstr('eta_rho');
      rec.Dimension(3) = cellstr('xi_rho');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'free-surface';
      rec.Attribute(2).Name = 'units';
      rec.Attribute(2).Value = 'meter';
      rec.Attribute(3).Name = 'time';
      rec.Attribute(3).Value = 'zeta_time';
      rec.Attribute(4).Name = 'coordinates';
      rec.Attribute(4).Value = 'lat_rho lon_rho';
      rec.Attribute(5).Name = 'field';
      rec.Attribute(5).Value = 'free-surface, scalar, series';
      nc_addvar( filename, rec );

    case 'ubar'
      nc_add_dimension( filename, 'v2d_time', numrecs );
      rec = [];
      rec.Name = 'v2d_time';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('v2d_time');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = '2D-velocity climatology time';
      rec.Attribute(2).Name = 'cycle_length';
      rec.Attribute(2).Value = 365.25;
      rec.Attribute(3).Name = 'field';
      rec.Attribute(3).Value = 'time, scalar, series';
      nc_addvar( filename, rec );

      rec = [];
      rec.Name = 'ubar';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('v2d_time');
      rec.Dimension(2) = cellstr('eta_u');
      rec.Dimension(3) = cellstr('xi_u');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'vertically integrated u-momentum component';
      rec.Attribute(2).Name = 'units';
      rec.Attribute(2).Value = 'meter second-1';
      rec.Attribute(3).Name = 'time';
      rec.Attribute(3).Value = 'v2d_time';
      rec.Attribute(4).Name = 'coordinates';
      rec.Attribute(4).Value = 'lat_u lon_u';
      rec.Attribute(5).Name = 'field';
      rec.Attribute(5).Value = 'ubar-velocity, scalar, series';
      nc_addvar( filename, rec );
    case 'vbar'
      rec = [];
      rec.Name = 'vbar';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('v2d_time');
      rec.Dimension(2) = cellstr('eta_v');
      rec.Dimension(3) = cellstr('xi_v');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'vertically integrated v-momentum component';
      rec.Attribute(2).Name = 'units';
      rec.Attribute(2).Value = 'meter second-1';
      rec.Attribute(3).Name = 'time';
      rec.Attribute(3).Value = 'v2d_time';
      rec.Attribute(4).Name = 'coordinates';
      rec.Attribute(4).Value = 'lat_v lon_v';
      rec.Attribute(5).Name = 'field';
      rec.Attribute(5).Value = 'vbar-velocity, scalar, series';
      nc_addvar( filename, rec );
      
    case 'u'
      nc_add_dimension( filename, 'v3d_time', numrecs );
      rec = [];
      rec.Name = 'v3d_time';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('v3d_time');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = '3D-velocity climatology time';
      rec.Attribute(2).Name = 'cycle_length';
      rec.Attribute(2).Value = 365.25;
      rec.Attribute(3).Name = 'field';
      rec.Attribute(3).Value = 'time, scalar, series';
      nc_addvar( filename, rec );

      rec = [];
      rec.Name = 'u';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('v3d_time');
      rec.Dimension(2) = cellstr('s_rho');
      rec.Dimension(3) = cellstr('eta_u');
      rec.Dimension(4) = cellstr('xi_u');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'u-momentum component';
      rec.Attribute(2).Name = 'units';
      rec.Attribute(2).Value = 'meter second-1';
      rec.Attribute(3).Name = 'time';
      rec.Attribute(3).Value = 'v3d_time';
      rec.Attribute(4).Name = 'coordinates';
      rec.Attribute(4).Value = 'lat_u lon_u';
      rec.Attribute(5).Name = 'field';
      rec.Attribute(5).Value = 'u-velocity, scalar, series';
      nc_addvar( filename, rec );
    case 'v'
      rec = [];
      rec.Name = 'v';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('v3d_time');
      rec.Dimension(2) = cellstr('s_rho');
      rec.Dimension(3) = cellstr('eta_v');
      rec.Dimension(4) = cellstr('xi_v');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'v-momentum component';
      rec.Attribute(2).Name = 'units';
      rec.Attribute(2).Value = 'meter second-1';
      rec.Attribute(3).Name = 'time';
      rec.Attribute(3).Value = 'v3d_time';
      rec.Attribute(4).Name = 'coordinates';
      rec.Attribute(4).Value = 'lat_v lon_v';
      rec.Attribute(5).Name = 'field';
      rec.Attribute(5).Value = 'v-velocity, scalar, series';
      nc_addvar( filename, rec );
    
    case 'temp'
      nc_add_dimension( filename, 'temp_time', numrecs );
      rec = [];
      rec.Name = 'temp_time';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('temp_time');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'temperature climatology time';
      rec.Attribute(2).Name = 'cycle_length';
      rec.Attribute(2).Value = 365.25;
      rec.Attribute(3).Name = 'field';
      rec.Attribute(3).Value = 'time, scalar, series';
      nc_addvar( filename, rec );

      rec = [];
      rec.Name = 'temp';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('temp_time');
      rec.Dimension(2) = cellstr('s_rho');
      rec.Dimension(3) = cellstr('eta_rho');
      rec.Dimension(4) = cellstr('xi_rho');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'potential temperature';
      rec.Attribute(2).Name = 'units';
      rec.Attribute(2).Value = 'Celsius';
      rec.Attribute(3).Name = 'time';
      rec.Attribute(3).Value = 'temp_time';
      rec.Attribute(4).Name = 'coordinates';
      rec.Attribute(4).Value = 'lat_rho lon_rho';
      rec.Attribute(5).Name = 'field';
      rec.Attribute(5).Value = 'temperature, scalar, series';
      nc_addvar( filename, rec );

    case 'salt'
      nc_add_dimension( filename, 'salt_time', numrecs );
      rec = [];
      rec.Name = 'salt_time';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('salt_time');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'salt climatology time';
      rec.Attribute(2).Name = 'cycle_length';
      rec.Attribute(2).Value = 365.25;
      rec.Attribute(3).Name = 'field';
      rec.Attribute(3).Value = 'time, scalar, series';
      nc_addvar( filename, rec );

      rec = [];
      rec.Name = 'salt';
      rec.Nctype = 'NC_DOUBLE';
      rec.Dimension(1) = cellstr('salt_time');
      rec.Dimension(2) = cellstr('s_rho');
      rec.Dimension(3) = cellstr('eta_rho');
      rec.Dimension(4) = cellstr('xi_rho');
      rec.Attribute(1).Name = 'long_name';
      rec.Attribute(1).Value = 'salinity';
      rec.Attribute(2).Name = 'time';
      rec.Attribute(2).Value = 'salt_time';
      rec.Attribute(3).Name = 'coordinates';
      rec.Attribute(3).Value = 'lat_rho lon_rho';
      rec.Attribute(4).Name = 'field';
      rec.Attribute(4).Value = 'temperature, scalar, series';
      nc_addvar( filename, rec );
  end
end
