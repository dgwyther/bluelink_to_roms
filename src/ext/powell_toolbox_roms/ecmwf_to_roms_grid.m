function ecmwf = ecmwf_to_roms_grid( grid, ecmwf, local_time )

% function ecmwf_to_roms_grid( grid, ecmwf, local_time )
%
% Given a ROMS grid and an ecmwf record, convert the ecmwf
% data to the ROMS grid at the times specified in the record
% Offset of local_time from UTC in days

% Because some are composite, we won't use the vars, but rather calculate
% it ourselves
num_vars = length(ecmwf.var);
ecmwf.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  lon_list = find( ecmwf.var(v).lon >= min(grid.interp_lon(:)) & ...
                   ecmwf.var(v).lon <= max(grid.interp_lon(:)) );
  lat_list = find( ecmwf.var(v).lat >= min(grid.interp_lat(:)) & ...)
                   ecmwf.var(v).lat <= max(grid.interp_lat(:)) );
  if ( isempty(lon_list) | isempty(lat_list) )
    error([ecmwf.var(v).long_name ' does not span the grid region.']);
  end
  lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
  lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
  lon_list = lon_list(find( lon_list > 0 & lon_list <= length(ecmwf.var(v).lon) ));
  lat_list = lat_list(find( lat_list > 0 & lat_list <= length(ecmwf.var(v).lat) ));
  [lon, lat] = meshgrid( ecmwf.var(v).lon(lon_list), ecmwf.var(v).lat(lat_list) );
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( ecmwf.interp_grid )
    ecmwf.var(v).lat = grid.interp_lat(:,1);
    ecmwf.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    ecmwf.var(v).lat = ecmwf.var(v).lat(lat_list);
    ecmwf.var(v).lon = ecmwf.var(v).lon(lon_list);
    ecmwf.var(v).eta = size(grid.interp_lat,1);
    ecmwf.var(v).xi  = size(grid.interp_lat,2);
  end

  % If the ROMS Grid is +/- longitude, make the ecmwf data similar
  list = find( ecmwf.var(v).lon > 180 );
  ecmwf.var(v).lon(list) = ecmwf.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
    if ~ecmwf.interp_grid,
      list=find(ecmwf.var(v).lon>=min(grid.interp_lon(:)) & ...
                          ecmwf.var(v).lon<=max(grid.interp_lon(:)));
      [ecmwf.var(v).lon,ix]=sort(ecmwf.var(v).lon(list));
      gwhichix=list(ix);
    end
  end

  if ( isfield(ecmwf,'output_file') )
    if ( v==1 & isfield(ecmwf,'netcdf_overwrite') )
      create_netcdf( ecmwf );
    end
    create_netcdf_var( ecmwf, v );
  end
  idx = 0;
  for f=1:size(ecmwf.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process ecmwf file: %s\n', ecmwf.var(v).file(f,:));
    file_times = nc_varget( ecmwf.var(v).file(f,:), 'reftime' ) / 24 + datenum(1992,1,1) - local_time;
    time_list = find( file_times >= ecmwf.time_start & file_times <= ecmwf.time_end ) - 1;
    if ( isempty(time_list) )
      continue;
    end
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( ecmwf.interp_grid == true )
      % data = permute(nc_varget(ecmwf.var(v).file(f,:), ecmwf.var(v).variable_name, ...
      %                  [ time_list(1) lat_index(1) lon_index(1) ], ...
      %                  [ length(time_list) lat_index(2) lon_index(2)]),[2 3 1]);
      % % Use the Mex routine to go through all times and grid up the results
      % ecmwf.var(v).data(idx,:,:) = ...
      %     permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
      %               grid.interp_lat, ecmwf.var(v).roms_scale, ...
      %               ecmwf.var(v).roms_offset),[3 1 2]);
      data = nc_varget(ecmwf.var(v).file(f,:), ecmwf.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)]);
      % Use the Mex routine to go through all times and grid up the results
      ecmwf.var(v).data(idx,:,:) = ...
          roms_interp(lon, lat, data, grid.interp_lon, ...
                    grid.interp_lat)*ecmwf.var(v).roms_scale + ...
                    ecmwf.var(v).roms_offset;
    else
      data = ...
          nc_varget(ecmwf.var(v).file(f,:), ecmwf.var(v).variable_name, ...
                          [ time_list(1) lat_index(1) lon_index(1) ], ...
                          [ length(time_list) lat_index(2) lon_index(2)]) * ...
                          ecmwf.var(v).roms_scale + ecmwf.var(v).roms_offset;
      if ~isempty(gwhichix)
        % We have to stitch together if everything is out of whack
        data=data(:,:,gwhichix);
      end
      ecmwf.var(v).data(idx,:,:) = data;
    end
    % Set the remaining parameters in the nc structure
    ecmwf.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % If we want to save it out now
    if ( isfield(ecmwf,'output_file') )
      clear ndata;
    end
  end
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
for v=1:num_vars,
  if ( isfield(ecmwf.var(v), 'operation') & ~isempty(ecmwf.var(v).operation) )
    ecmwf = ecmwf.var(v).operation( ecmwf, v, grid );
  end
end
return
