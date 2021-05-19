function ssh = ssh_to_roms_grid( grid, ssh )

% function ssh_to_roms_grid( grid, ssh, raw_data )
%
% Given a ROMS grid, an SSH record, and the altimetry data,
% convert the altimetry data to the ROMS grid at the times 
% specified in the record

ssh.roms_grid = grid.interp_roms_grid;

% Figure out which region to grab
lon_list = find( ssh.var(1).lon >= min(grid.interp_lon(:)) & ...
                 ssh.var(1).lon <= max(grid.interp_lon(:)) );
lat_list = find( ssh.var(1).lat >= min(grid.interp_lat(:)) & ...)
                 ssh.var(1).lat <= max(grid.interp_lat(:)) );
if ( isempty(lon_list) | isempty(lat_list) )
  error([ssh.var(1).long_name ' does not span the grid region.']);
end
lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
lon_list = lon_list(find( lon_list > 0 & lon_list <= length(ssh.var(1).lon) ));
lat_list = lat_list(find( lat_list > 0 & lat_list <= length(ssh.var(1).lat) ));
[lon, lat] = meshgrid( ssh.var(1).lon(lon_list), ssh.var(1).lat(lat_list) );

idx = 0;
% Figure out which times to grab
fprintf(1,'Process ssh\n');
time_list = find( ssh.var(1).raw_time >= ssh.time_start & ...
                  ssh.var(1).raw_time <= ssh.time_end );
if ( isempty(time_list) )
  return;
end
idx=[idx(end)+1:idx(end)+length(time_list)]';

% Go through and get everything
if ( ssh.interp_grid == true )
  % Use the Mex routine to go through all times and grid up the results
  ssh.var(1).data(idx,:,:) = ...
      permute(roms_mexgridder( ...
                permute(ssh.var(1).raw_data(time_list,lat_list,lon_list),[2 3 1]), ...
                lon, lat, grid.interp_lon, grid.interp_lat, ssh.var(1).roms_scale, ...
                ssh.var(1).roms_offset), ...
        [3 1 2]);
  % If we are using some special interp grid, store the lat/lon
  if ( ~ssh.roms_grid )
    ssh.var(1).lat = grid.interp_lat(:,1);
    ssh.var(1).lon = grid.interp_lon(1,:);
  end
else
  ssh.var(1).data(idx,:,:) = ...
       ssh.var(1).raw_data(time_list,lat_list,lon_list) * ...
       ssh.var(1).roms_scale + ssh.var(1).roms_offset;
  
  % Store the lat/lon used for this variable
  ssh.var(1).lat = ssh.var(1).lat(lat_list);
  ssh.var(1).lon = ssh.var(1).lon(lon_list);
end

% If the ROMS Grid is +/- longitude, make the ssh data similar
list = find( ssh.var(1).lon > 180 );
ssh.var(1).lon(list) = ssh.var(1).lon(list) - 360;

% Set the remaining parameters in the nc structure
ssh.var(1).data_time(idx) = ssh.var(1).raw_time(time_list+1);

return