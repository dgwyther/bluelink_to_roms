function cora = cora_to_roms_grid( grid, cora, mask )

% function cora_to_roms_grid( grid, cora )
%
% Given a ROMS grid and an cora record, convert the cora
% data to the ROMS grid at the times specified in the record
% If mask is given true, then the grid mask is applied
% to the data.

if ( nargin < 3 )
  mask = false;
end

load cora_mask

cora.roms_grid = grid.interp_roms_grid;
% Figure out which region to grab
lon_list = find( cora.var(1).def_lon >= min(grid.interp_lon(:)) & ...
                 cora.var(1).def_lon <= max(grid.interp_lon(:)) );
lat_list = find( cora.var(1).def_lat >= min(grid.interp_lat(:)) & ...
                 cora.var(1).def_lat <= max(grid.interp_lat(:)) );
if ( isempty(lon_list) | isempty(lat_list) )
  error([cora.var(1).long_name ' does not span the grid region.']);
end
lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
lon_list = lon_list(find( lon_list > 0 & lon_list <= length(cora.var(1).def_lon) ));
lat_list = lat_list(find( lat_list > 0 & lat_list <= length(cora.var(1).def_lat) ));
[lon, lat] = meshgrid( cora.var(1).def_lon(lon_list), cora.var(1).def_lat(lat_list) );

cmask = reshape( cora_mask.mask(lat_list,lon_list), 1, length(lat_list), length(lon_list));

idx = 0;
for f=1:size(cora.var(1).file,1),
  % Figure out which times to grab
  fprintf(1,'Process cora file: %s\n', cora.var(1).file(f,:));
  
  % Load the file
  winds = cora_read_winds(cora, f, lat_list, lon_list);
  % Grab the times we want
  time_list = find( winds.time >= cora.time_start & winds.time <= cora.time_end );
  if ( isempty(time_list) )
    continue;
  end
  idx=[idx(end)+1:idx(end)+length(time_list)]';

  % Apply the mask to the data
%   winds.u = winds.u(time_list,:,:) .* cmask(ones(length(time_list),1),:,:);
%   winds.v = winds.v(time_list,:,:) .* cmask(ones(length(time_list),1),:,:);
  winds.u = winds.u(time_list,:,:);
  winds.v = winds.v(time_list,:,:);
  
  % Go through and get everything
  if ( cora.interp_grid == true )
    % Use the Mex routine to go through all times and grid up the results
    cora.var(1).data(idx,:,:) = ...
        permute(roms_mexgridder(permute(winds.u,[2 3 1]), ...
                  lon, lat, grid.interp_lon, ...
                  grid.interp_lat, cora.var(1).roms_scale, ...
                  cora.var(1).roms_offset),[3 1 2]);
    cora.var(2).data(idx,:,:) = ...
        permute(roms_mexgridder(permute(winds.v,[2 3 1]), ...
                  lon, lat, grid.interp_lon, ...
                  grid.interp_lat, cora.var(2).roms_scale, ...
                  cora.var(2).roms_offset),[3 1 2]);
    % If we are using some special interp grid, store the lat/lon
    cora.var(1).lat = grid.interp_lat(:,1);
    cora.var(1).lon = grid.interp_lon(1,:);
  else
    cora.var(1).data(idx,:,:) = winds.u *  ...
      cora.var(1).roms_scale + cora.var(1).roms_offset;
    cora.var(2).data(idx,:,:) = winds.v *  ...
        cora.var(2).roms_scale + cora.var(2).roms_offset;
    cora.var(1).lat = cora.var(1).def_lat(lat_list);
    cora.var(1).lon = cora.var(1).def_lon(lon_list);
  end
  if ( mask )
    m = reshape(cora.land_mask,[1 size(cora.land_mask)]);
    cora.var(1).data(idx,:,:) = cora.var(1).data(idx,:,:) .* ...
      m(ones(length(idx),1),:,:);
    cora.var(2).data(idx,:,:) = cora.var(2).data(idx,:,:) .* ...
        m(ones(length(idx),1),:,:);
  end
  % If the ROMS Grid is +/- longitude, make the NCEP data similar
  list = find( cora.var(1).lon > 180 );
  cora.var(1).lon(list) = cora.var(1).lon(list) - 360;

  % Set the remaining parameters in the nc structure
  cora.var(1).data_time(idx) = winds.time(time_list);
  cora.var(2).data_time(idx) = winds.time(time_list);
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
if ( isfield(cora.var(1), 'operation') )
  cora = cora.var(1).operation( cora, grid );
end

return
