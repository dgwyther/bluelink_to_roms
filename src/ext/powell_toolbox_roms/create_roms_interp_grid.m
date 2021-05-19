function grid = create_roms_interp_grid( grid, dlat, dlon )

% function grid = create_roms_interp_grid( grid, dlat, dlon )
%
% Create a rectalinear grid of dlon/dlat around the given ROMS grid

if ( nargin < 3 )
  dlon = dlat;
end

min_latr = min( grid.latr(:) );
max_latr = max( grid.latr(:) );
lat = [floor(min_latr)-dlat:dlat:ceil(max_latr)+dlat];
min_lonr = min( grid.lonr(:) );
max_lonr = max( grid.lonr(:) );
lon = [floor(min_lonr)-dlon:dlon:ceil(max_lonr)+dlon];
[grid.interp_lon, grid.interp_lat] = meshgrid(lon, lat);

% Mask out the regions that we aren't interested in
%grid.mask = griddata( grid.lonr, grid.latr, grid.mask, grid.interp_lon, grid.interp_lat);
%grid.mask(find(~isnan(grid.mask)))=1;

% Don't interp to the strict grid for this ROMS (let the model handle it)
grid.interp_roms_grid = false;
