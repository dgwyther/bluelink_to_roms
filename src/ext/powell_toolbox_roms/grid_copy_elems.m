function grid_copy_elems(srcfile, dstfile)

% GRID_COPY_ELEMS(SRCFILE, DSTFILE)
%
% Copy the ROMS grid elements (s_rho, Cs_r, etc.) from one file
% to another


vars={'spherical' 'Vtransform' 'Vstretching' 'theta_s' 'theta_b' ...
      'Tcline' 'hc' 's_rho' 's_w' 'Cs_r' 'Cs_w' 'h' 'lon_rho' ...
      'lat_rho' 'lon_u' 'lat_u' 'lon_v' 'lat_v' 'angle' 'mask_rho' ...
      'mask_u' 'mask_v'};
      
for v=1:length(vars),
  try
    nc_varput(dstfile,char(vars(v)),nc_varget(srcfile,char(vars(v))));
  catch
    disp([char(vars(v)) ' is not valid.']);
  end
end
