function gfs = gfs_to_roms_grid( grid, gfs, mask )

% function gfs_to_roms_grid( grid, gfs, [ mask ] )
%
% Given a ROMS grid and an NCEP record, convert the NCEP
% data to the ROMS grid at the times specified in the record
% If mask is given true, then the grid mask is applied
% to the data.

if ( nargin < 3 )
  mask = false;
end

% Because some are composite, we won't use the vars, but rather calculate
% it ourselves
num_vars = length(gfs.var);
gfs.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  lon_list = find( gfs.var(v).lon >= min(grid.interp_lon(:)) & ...
                   gfs.var(v).lon <= max(grid.interp_lon(:)) );
  lat_list = find( gfs.var(v).lat >= min(grid.interp_lat(:)) & ...)
                   gfs.var(v).lat <= max(grid.interp_lat(:)) );
  if ( isempty(lon_list) | isempty(lat_list) )
    error([gfs.var(v).long_name ' does not span the grid region.']);
  end
  lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
  lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
  lon_list = lon_list(find( lon_list > 0 & lon_list <= length(gfs.var(v).lon) ));
  lat_list = lat_list(find( lat_list > 0 & lat_list <= length(gfs.var(v).lat) ));
  [lon, lat] = meshgrid( gfs.var(v).lon(lon_list), gfs.var(v).lat(lat_list) );
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( ~gfs.roms_grid )
    if ( v==1 & mask )
      % Create the grid land mask for the data
      gfs.land_mask = round(griddata(gfs.var(1).lon,gfs.var(1).lat,gfs.land_mask,...
                                grid.interp_lon,grid.interp_lat));
    end
    gfs.var(v).lat = grid.interp_lat(:,1);
    gfs.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    gfs.var(v).lat = gfs.var(v).lat(lat_list);
    gfs.var(v).lon = gfs.var(v).lon(lon_list);
    gfs.var(v).eta = size(grid.interp_lat,1);
    gfs.var(v).xi  = size(grid.interp_lat,2);
  end
  % If the ROMS Grid is +/- longitude, make the NCEP data similar
  list = find( gfs.var(v).lon > 180 );
  gfs.var(v).lon(list) = gfs.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
  end

  if ( isfield(gfs,'output_file') )
    if ( v==1 & isfield(gfs,'netcdf_overwrite') )
      create_netcdf( gfs );
    end
    create_netcdf_var( gfs, v );
  end
  
  idx = 0;
  for f=1:size(gfs.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process NCEP %s: %s\n', gfs.var(v).file(f,:), gfs.var(v).long_name);
    file_times = nc_varget( gfs.var(v).file(f,:), 'time' ) + 365;
    time_list=[1:length(file_times)]-1;
    % time_list = find( file_times >= gfs.time_start & file_times <= gfs.time_end ) - 1;
    % if ( isempty(time_list) )
    %   continue;
    % end
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( gfs.interp_grid == true )
      if ( gfs.var(v).level )
        data = squeeze(permute(nc_varget(gfs.var(v).file(f,:), gfs.var(v).variable_name, ...
                       [ time_list(1) gfs.var(v).level-1, lat_index(1) lon_index(1) ], ...
                       [ length(time_list) 1 lat_index(2) lon_index(2)]),[2 3 4 1]));
      else
        data = permute(nc_varget(gfs.var(v).file(f,:), gfs.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)]),[2 3 1]);
      end
      % Use the Mex routine to go through all times and grid up the results
      gfs.var(v).data(idx,:,:) = ...
          permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
                    grid.interp_lat, gfs.var(v).roms_scale, ...
                    gfs.var(v).roms_offset),[3 1 2]);
      % If we are using some special interp grid, store the lat/lon
    else
      gfs.var(v).data(idx,:,:) = ...
          nc_varget(gfs.var(v).file(f,:), gfs.var(v).variable_name, ...
                          [ 0 lat_index(1) lon_index(1) ], ...
                          [ -1 lat_index(2) lon_index(2)]) * ...
                          gfs.var(v).roms_scale + gfs.var(v).roms_offset;
      
    end
    if ( mask )
      m = reshape(grid.mask,[1 size(grid.mask)]);
      gfs.var(v).data(idx,:,:) = gfs.var(v).data(idx,:,:) .* ...
        m(ones(length(idx),1),:,:);
    end
    % Set the remaining parameters in the nc structure
    gfs.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % Clean up the data of NaN fields
    list = nanmean(reshape(gfs.var(v).data,size(gfs.var(v).data,1), ...
                           size(gfs.var(v).data,2)*size(gfs.var(v).data,3)),2);
    list=find(~isnan(list));
    
    % Make sure the time is sequential
    [tmp,srt] = sort( gfs.var(v).data_time(list) );
    gfs.var(v).data = gfs.var(v).data(list(srt),:,:);
    gfs.var(v).data_time = gfs.var(v).data_time(list(srt));

    % If we want to save it out now
    if ( isfield(gfs,'output_file') )
      clear ndata;
    end
  end
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
for v=1:num_vars,
  if ( isfield(gfs.var(v), 'operation') & ~isempty(gfs.var(v).operation) )
    gfs = gfs.var(v).operation( gfs, v, grid );
  end
end
return
