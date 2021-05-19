function bry_write( grid, filename, epoch, cycle )

% bry_write( grid, filename )
%
% Given a grid, create a blank boundary file
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
if ( nargin<4 )
  cycle=false;
end

% Create the file
[id, status]=mexnc('create', filename, bitor(nc_clobber_mode, nc_64bit_offset_mode) );
if ( status ~= 0 )
  error( ['Cannot Create: ' filename] )
end
mexnc('close',id);

% Set the global variables for the file
nc_attput( filename, nc_global, 'title', 'ROMS Boundary File' );
[a,user]=unix('finger `whoami`');
user=regexp(user, 'Name: (?<name>[\w ]*)', 'names');
nc_attput( filename, nc_global, 'author', user.name );
nc_attput( filename, nc_global, 'date', datestr(now));
nc_attput( filename, nc_global, 'type', 'ROMS Boundary');
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
nc_add_dimension( filename, 'bry_time', 0 );

% Add the variables
rec = [];
rec.Name = 'bry_time';
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr('bry_time');
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = 'time since initialization';
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = epoch;
rec.Attribute(3).Name = 'field';
rec.Attribute(3).Value = 'bry_time, scalar, series';
if (cycle)
  rec.Attribute(4).Name = 'cycle_length';
  rec.Attribute(4).Value = 365.25;
end
nc_addvar( filename, rec );


dirs={'north' 'south' 'east' 'west'};
grd={'xi' 'xi' 'eta' 'eta'};
desc={'northern' 'southern' 'eastern' 'western'};
vars={'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt'};
dims=[2 2 2 3 3 3 3];
type={'rho' 'u' 'v' 'u' 'v' 'rho' 'rho'};
name={'free-surface' '2D u-momentum' '2D v-momentum' '3D u-momentum' ...
      '3D v-momentum' 'potential temperature' 'salinity'};
units={'meter' 'meter second-1' 'meter second-1' 'meter second-1' ...
       'meter second-1' 'Celcius' 'salt'};

try       
for v=1:length(vars),
  var=char(vars(v));
  for d=1:length(dirs),  
    dir=char(dirs(d));
    rec = [];
    rec.Name = [ var '_' dir ];
    rec.Nctype = 'NC_DOUBLE';
    rec.Dimension(1) = cellstr('bry_time');
    rec.Dimension(2) = cellstr([char(grd(d)) '_' char(type(v))]);
    if (dims(v)>2)
      rec.Dimension(3) = rec.Dimension(2);
      rec.Dimension(2) = cellstr('s_rho');
    end
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = [char(name(v)) ' ' dir ' boundary condition'];
    rec.Attribute(2).Name = 'units';
    rec.Attribute(2).Value = char(units(v));
    rec.Attribute(3).Name = 'time';
    rec.Attribute(3).Value = 'bry_time';
    rec.Attribute(4).Name = 'field';
    rec.Attribute(4).Value = [ rec.Name ', scalar, series'];
    nc_addvar( filename, rec );
  end
end
catch
keyboard
end

% % Next, create a single record full of zeros
% rec=[];
% rec.bry_time=1;
% rec.zeta_north    = zeros(1,grid.lp)
% rec.zeta_south    = zeros(1,grid.lp);
% rec.zeta_east     = zeros(1,grid.mp);
% rec.zeta_west     = zeros(1,grid.mp);
% rec.ubar    = zeros(1,grid.mp,grid.l);
% rec.vbar    = zeros(1,grid.m,grid.lp);
% rec.u       = zeros(1,grid.n,grid.mp,grid.l);
% rec.v       = zeros(1,grid.n,grid.m,grid.lp);
% rec.temp_north    = zeros(1,grid.n,grid.mp);
% rec.salt_east    = zeros(1,grid.n,grid.lp);
% nc_addnewrecs( filename, rec, 'ocean_time' );


