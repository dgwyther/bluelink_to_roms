function coads = coads_to_roms_grid( grid, coads )

% function coads_to_roms_grid( grid, coads )
%
% Given a ROMS grid and an coads record, convert the coads
% data to the ROMS grid at the times specified in the record

% Because some are composite, we won't use the vars, but rather calculate
% it ourselves
num_vars = length(coads.var);
coads.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  lon_list = find( coads.var(v).lon >= min(grid.interp_lon(:)) & ...
                   coads.var(v).lon <= max(grid.interp_lon(:)) );
  lat_list = find( coads.var(v).lat >= min(grid.interp_lat(:)) & ...)
                   coads.var(v).lat <= max(grid.interp_lat(:)) );
  if ( isempty(lon_list) | isempty(lat_list) )
    error([coads.var(v).long_name ' does not span the grid region.']);
  end
  lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
  lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
  lon_list = lon_list(find( lon_list > 0 & lon_list <= length(coads.var(v).lon) ));
  lat_list = lat_list(find( lat_list > 0 & lat_list <= length(coads.var(v).lat) ));
  [lon, lat] = meshgrid( coads.var(v).lon(lon_list), coads.var(v).lat(lat_list) );
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( ~coads.roms_grid )
    coads.var(v).lat = grid.interp_lat(:,1);
    coads.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    coads.var(v).lat = coads.var(v).lat(lat_list);
    coads.var(v).lon = coads.var(v).lon(lon_list);
    coads.var(v).eta = size(grid.interp_lat,1);
    coads.var(v).xi  = size(grid.interp_lat,2);
  end
  % If the ROMS Grid is +/- longitude, make the coads data similar
  list = find( coads.var(v).lon > 180 );
  coads.var(v).lon(list) = coads.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
  end

  if ( isfield(coads,'output_file') )
    if ( v==1 & isfield(coads,'netcdf_overwrite') )
      create_netcdf( coads );
    end
    create_netcdf_var( coads, v );
  end
  
  idx = 0;
  for f=1:size(coads.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process coads file: %s\n', coads.var(v).file(f,:));
    file_times = nc_varget( coads.var(v).file(f,:), 'TIME' )+datenum(0,12,30);
    time_list = find( file_times >= coads.time_start & file_times <= coads.time_end ) - 1;
    if ( isempty(time_list) )
      continue;
    end
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( coads.interp_grid == true )
      data = permute(nc_varget(coads.var(v).file(f,:), coads.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)]),[2 3 1]);
      % Use the Mex routine to go through all times and grid up the results
      coads.var(v).data(idx,:,:) = ...
          permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
                    grid.interp_lat, coads.var(v).roms_scale, ...
                    coads.var(v).roms_offset),[3 1 2]);
      % If we are using some special interp grid, store the lat/lon
    else
      coads.var(v).data(idx,:,:) = ...
          nc_varget(coads.var(v).file(f,:), coads.var(v).variable_name, ...
                          [ time_list(1) lat_index(1) lon_index(1) ], ...
                          [ length(time_list) lat_index(2) lon_index(2)]) * ...
                          coads.var(v).roms_scale + coads.var(v).roms_offset;
      
    end
    % Set the remaining parameters in the nc structure
    coads.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % If we want to save it out now
    if ( isfield(coads,'output_file') )
      clear ndata;
    end
  end
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
for v=1:num_vars,
  if ( isfield(coads.var(v), 'operation') & ~isempty(coads.var(v).operation) )
    coads = coads.var(v).operation( coads, v, grid );
  end
end
return
