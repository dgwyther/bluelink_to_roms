function grid = roms_grid_info( file )

% function grid = roms_grid_info( file )
%
% Given a ROMS grid file, return the pertinent information
% for use in converting ncep files, etc.
%

if ( nargin ~= 1 | exist(file)~=2 )
	error('File is not found');
end

grid.latr = nc_varget(file,'lat_rho');
grid.lonr = nc_varget(file,'lon_rho');
grid.angle = nc_varget(file,'angle');
grid.mask = nc_varget(file,'mask_rho');
grid.mask(find(grid.mask==0))=nan;

% Check the longitudes
list = find( grid.lonr < 0 );
if ( ~isempty(list) )
  grid.lonr(list) = grid.lonr(list)+360;
  grid.neglons = 1;
end

% Interpolate to the same grid. If a different grid is wanted,
% it can be changed in user code.
grid.interp_lat = grid.latr;
grid.interp_lon = grid.lonr;
grid.interp_roms_grid = true;

return