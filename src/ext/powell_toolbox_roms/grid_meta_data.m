function grid_meta_data(grid,gridfile)

% function grid_meta_data(grid,gridfile)
%
% This function will add meta data to the grid file, including:
%   theta_s
%   theta_b
%   tcline
%   hc
%
% NOTE: THIS INFORMATION IS NOT ACTUALLY USED BY ROMS. IF YOU ALTER YOUR
%   ROMS PARAMETERS, YOU MIGHT WANT TO REWRITE THIS DATA BECAUSE THE MATLAB
%   UTILITIES WILL HAVE DIFFERENT VALUES.
%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if ( isfield(grid,'n') )
  rec = [];
  rec.Name = 'N';
  if ( ~nc_isvar(gridfile,rec.Name) )
    rec.Nctype = 'NC_DOUBLE';
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = 'Number of vertical layers';
    nc_addvar( gridfile, rec );
  end
  nc_varput( gridfile, rec.Name, grid.n );
end

if ( isfield(grid,'theta_s') )
  rec = [];
  rec.Name = 'theta_s';
  if ( ~nc_isvar(gridfile,rec.Name) )
    rec.Nctype = 'NC_DOUBLE';
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = 'S-coordinate surface control parameter';
    nc_addvar( gridfile, rec );
  end
  nc_varput( gridfile, rec.Name, grid.theta_s );
end

if ( isfield(grid,'theta_b') )
  rec = [];
  rec.Name = 'theta_b';
  if ( ~nc_isvar(gridfile,rec.Name) )
    rec.Nctype = 'NC_DOUBLE';
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = 'S-coordinate bottom control parameter';
    nc_addvar( gridfile, rec );
  end
  nc_varput( gridfile, rec.Name, grid.theta_b );
end

if ( isfield(grid,'tcline') )
  rec = [];
  rec.Name = 'Tcline';
  if ( ~nc_isvar(gridfile,rec.Name) )
    rec.Nctype = 'NC_DOUBLE';
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = 'S-coordinate surface/bottom layer width';
    rec.Attribute(2).Name = 'units';
    rec.Attribute(2).Value = 'meter';
    nc_addvar( gridfile, rec );
  end
  nc_varput( gridfile, rec.Name, grid.tcline );
end

if ( isfield(grid,'hc') )
  rec = [];
  rec.Name = 'hc';
  if ( ~nc_isvar(gridfile,rec.Name) )
    rec.Nctype = 'NC_DOUBLE';
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = 'S-coordinate parameter, critical depth';
    rec.Attribute(2).Name = 'units';
    rec.Attribute(2).Value = 'meter';
    nc_addvar( gridfile, rec );
  end
  nc_varput( gridfile, rec.Name, grid.hc );
end

if ( isfield(grid,'vtransform') )
  rec = [];
  rec.Name = 'Vtransform';
  if ( ~nc_isvar(gridfile,rec.Name) )
    rec.Nctype = 'NC_INT';
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = 'vertical terrain-following transformation equation';
    nc_addvar( gridfile, rec );
  end
  nc_varput( gridfile, rec.Name, grid.vtransform );
end

if ( isfield(grid,'vstretching') )
  rec = [];
  rec.Name = 'Vstretching';
  if ( ~nc_isvar(gridfile,rec.Name) )
    rec.Nctype = 'NC_INT';
    rec.Attribute(1).Name = 'long_name';
    rec.Attribute(1).Value = 'vertical terrain-following stretching function';
    nc_addvar( gridfile, rec );
  end
  nc_varput( gridfile, rec.Name, grid.vstretching );
end
