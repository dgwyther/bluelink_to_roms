function create_netcdf_var( nc, var_num )

var = nc.var(var_num);

% Add the variable information
rec = [];
rec.Name = var.roms_variable_name;
rec.Nctype = 'NC_DOUBLE';
rec.Dimension(1) = cellstr(var.time_str);
if ( nc.roms_grid == true )
  rec.Dimension(2) = cellstr('eta_rho');
  rec.Dimension(3) = cellstr('xi_rho');
else
  rec.Dimension(2) = cellstr('lat');
  rec.Dimension(3) = cellstr('lon');
end
rec.Attribute(1).Name = 'long_name';
rec.Attribute(1).Value = var.long_name;
rec.Attribute(2).Name = 'units';
rec.Attribute(2).Value = var.units;
rec.Attribute(3).Name = 'coordinates';
if ( nc.roms_grid == true )
  rec.Attribute(3).Value = 'eta_rho xi_rho';
else
  rec.Attribute(3).Value = 'lon lat';
end
rec.Attribute(4).Name = 'field';
rec.Attribute(4).Value = var.field;
rec.Attribute(5).Name = 'time';
rec.Attribute(5).Value = var.time_str;

nc_addvar( nc.output_file, rec );
