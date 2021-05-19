function ini_write( grid, filename, epoch, empty_record )

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
  epoch='seconds since 0000-01-01 00:00:00';
else
  if (isnumeric(epoch))
    epoch=['seconds since ' datestr(epoch,31) ];
  end
end
if ( nargin<4 )
  empty_record = true;
end

if ( ~isfield(grid,'n') )
  error('you must specify the number of layers, n, as a member of the grid.');
  return
end

if ( ~isfield(grid,'theta_s') )
  error('you must specify theta_s as a member of the grid.');
  return
end

if ( ~isfield(grid,'theta_b') )
  error('you must specify theta_b as a member of the grid.');
  return
end

if ( ~isfield(grid,'tcline') )
  error('you must specify tcline as a member of the grid.');
  return
end

if ( ~isfield(grid,'hc') )
  error('you must specify hc as a member of the grid.');
  return
end

if ( ~isfield(grid,'vtransform') )
  grid.vtransform=1;
end
if ( ~isfield(grid,'vstretching') )
  grid.vstretching=1;
end

% Create the file
[id, status]=mexnc('create', filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' filename] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( filename, nc_global, 'title', 'Initialization File' );
[a,user]=unix('finger `whoami`');
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
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
nc_add_dimension( filename, 'ocean_time', 0 );

% Add the variables
rec = [];
rec.Name = 'theta_s';
rec.Nctype = 'NC_DOUBLE';
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate surface control parameter';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, grid.theta_s );

rec = [];
rec.Name = 'theta_b';
rec.Nctype = 'NC_DOUBLE';
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate bottom control parameter';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, grid.theta_b );

rec = [];
rec.Name = 'Tcline';
rec.Nctype = 'NC_DOUBLE';
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate surface/bottom layer width';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, grid.tcline );

rec = [];
rec.Name = 'hc';
rec.Nctype = 'NC_DOUBLE';
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate parameter, critical depth';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, grid.hc );

rec = [];
rec.Name = 'Vtransform';
rec.Nctype = 'NC_INT';
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'vertical terrain-following transformation equation';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, grid.vtransform );

rec = [];
rec.Name = 'Vstretching';
rec.Nctype = 'NC_INT';
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'vertical terrain-following stretching function';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, grid.vstretching );

[s,c]=stretching(grid.vstretching, grid.theta_s, grid.theta_b, ...
                 grid.hc, grid.n, 0, 0);
rec = [];
rec.Name = 's_rho';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('s_rho');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate at RHO-points';
rec.Attribute(2).Name = 'valid_min';
rec.Attribute(2).Value = -1;
rec.Attribute(3).Name = 'valid_max';
rec.Attribute(3).Value = 0;
rec.Attribute(4).Name = 'standard_name';
rec.Attribute(4).Value = 'ocean_s_coordinate';
rec.Attribute(5).Name = 'formula_terms';
rec.Attribute(5).Value = 's: s_rho eta: zeta depth: h a: theta_s b: theta_b depth_c: hc';
rec.Attribute(6).Name = 'field';
rec.Attribute(6).Value = 's_rho, scalar';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, s );

rec = [];
rec.Name = 'Cs_r';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('s_rho');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate stretching curves at RHO-points';
rec.Attribute(2).Name = 'valid_min';
rec.Attribute(2).Value = -1;
rec.Attribute(3).Name = 'valid_max';
rec.Attribute(3).Value = 0;
rec.Attribute(4).Name = 'field';
rec.Attribute(4).Value = 'Cs_r, scalar';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, c );

[s,c]=stretching(grid.vstretching, grid.theta_s, grid.theta_b, ...
                 grid.hc, grid.n, 1, 0);
rec = [];
rec.Name = 's_w';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('s_w');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate at W-points';
rec.Attribute(2).Name = 'valid_min';
rec.Attribute(2).Value = -1;
rec.Attribute(3).Name = 'valid_max';
rec.Attribute(3).Value = 0;
rec.Attribute(4).Name = 'standard_name';
rec.Attribute(4).Value = 'ocean_s_coordinate';
rec.Attribute(5).Name = 'formula_terms';
rec.Attribute(5).Value = 's: s_w eta: zeta depth: h a: theta_s b: theta_b depth_c: hc';
rec.Attribute(6).Name = 'field';
rec.Attribute(6).Value = 's_w, scalar';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, s);

rec = [];
rec.Name = 'Cs_w';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('s_w');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'S-coordinate stretching curves at W-points';
rec.Attribute(2).Name = 'valid_min';
rec.Attribute(2).Value = -1;
rec.Attribute(3).Name = 'valid_max';
rec.Attribute(3).Value = 0;
rec.Attribute(4).Name = 'field';
rec.Attribute(4).Value = 'Cs_w, scalar';
nc_addvar( filename, rec );
nc_varput( filename, rec.Name, c);

rec = [];
rec.Name = 'ocean_time';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'time since initialization';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = epoch;
rec.Attribute(3).Name = 'field';
rec.Attribute(3).Value = 'time, scalar, series';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'zeta';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Dimension(2) = cellstr('eta_rho');
rec.Dimension(3) = cellstr('xi_rho');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'free-surface';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter';
rec.Attribute(3).Name = 'time';
rec.Attribute(3).Value = 'ocean_time';
rec.Attribute(4).Name = 'coordinates';
rec.Attribute(4).Value = 'lat_rho lon_rho';
rec.Attribute(5).Name = 'field';
rec.Attribute(5).Value = 'free-surface, scalar, series';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'ubar';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Dimension(2) = cellstr('eta_u');
rec.Dimension(3) = cellstr('xi_u');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'vertically integrated u-momentum component';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter second-1';
rec.Attribute(3).Name = 'time';
rec.Attribute(3).Value = 'ocean_time';
rec.Attribute(4).Name = 'coordinates';
rec.Attribute(4).Value = 'lat_u lon_u';
rec.Attribute(5).Name = 'field';
rec.Attribute(5).Value = 'ubar-velocity, scalar, series';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'vbar';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Dimension(2) = cellstr('eta_v');
rec.Dimension(3) = cellstr('xi_v');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'vertically integrated v-momentum component';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter second-1';
rec.Attribute(3).Name = 'time';
rec.Attribute(3).Value = 'ocean_time';
rec.Attribute(4).Name = 'coordinates';
rec.Attribute(4).Value = 'lat_v lon_v';
rec.Attribute(5).Name = 'field';
rec.Attribute(5).Value = 'vbar-velocity, scalar, series';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'u';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Dimension(2) = cellstr('s_rho');
rec.Dimension(3) = cellstr('eta_u');
rec.Dimension(4) = cellstr('xi_u');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'u-momentum component';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter second-1';
rec.Attribute(3).Name = 'time';
rec.Attribute(3).Value = 'ocean_time';
rec.Attribute(4).Name = 'coordinates';
rec.Attribute(4).Value = 'lat_u lon_u';
rec.Attribute(5).Name = 'field';
rec.Attribute(5).Value = 'u-velocity, scalar, series';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'v';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Dimension(2) = cellstr('s_rho');
rec.Dimension(3) = cellstr('eta_v');
rec.Dimension(4) = cellstr('xi_v');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'v-momentum component';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'meter second-1';
rec.Attribute(3).Name = 'time';
rec.Attribute(3).Value = 'ocean_time';
rec.Attribute(4).Name = 'coordinates';
rec.Attribute(4).Value = 'lat_v lon_v';
rec.Attribute(5).Name = 'field';
rec.Attribute(5).Value = 'v-velocity, scalar, series';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'temp';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Dimension(2) = cellstr('s_rho');
rec.Dimension(3) = cellstr('eta_rho');
rec.Dimension(4) = cellstr('xi_rho');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'potential temperature';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = 'Celsius';
rec.Attribute(3).Name = 'time';
rec.Attribute(3).Value = 'ocean_time';
rec.Attribute(4).Name = 'coordinates';
rec.Attribute(4).Value = 'lat_rho lon_rho';
rec.Attribute(5).Name = 'field';
rec.Attribute(5).Value = 'temperature, scalar, series';
nc_addvar( filename, rec );

rec = [];
rec.Name = 'salt';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('ocean_time');
rec.Dimension(2) = cellstr('s_rho');
rec.Dimension(3) = cellstr('eta_rho');
rec.Dimension(4) = cellstr('xi_rho');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'salinity';
rec.Attribute(2).Name = 'time';
rec.Attribute(2).Value = 'ocean_time';
rec.Attribute(3).Name = 'coordinates';
rec.Attribute(3).Value = 'lat_rho lon_rho';
rec.Attribute(4).Name = 'field';
rec.Attribute(4).Value = 'temperature, scalar, series';
nc_addvar( filename, rec );

% Next, create a single record full of zeros
if ( empty_record )
  rec=[];
  rec.ocean_time=0;
  rec.zeta    = zeros(1,grid.mp,grid.lp);
  rec.ubar    = zeros(1,grid.mp,grid.l);
  rec.vbar    = zeros(1,grid.m,grid.lp);
  rec.u       = zeros(1,grid.n,grid.mp,grid.l);
  rec.v       = zeros(1,grid.n,grid.m,grid.lp);
  rec.temp    = zeros(1,grid.n,grid.mp,grid.lp);
  rec.salt    = zeros(1,grid.n,grid.mp,grid.lp);
  nc_addnewrecs( filename, rec, 'ocean_time' );
end

