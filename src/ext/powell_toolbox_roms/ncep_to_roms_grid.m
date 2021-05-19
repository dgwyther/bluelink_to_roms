function ncep = ncep_to_roms_grid( grid, ncep, mask )

% function ncep_to_roms_grid( grid, ncep, [ mask ] )
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
num_vars = length(ncep.var);
ncep.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  lon_list = find( ncep.var(v).lon >= min(grid.interp_lon(:)) & ...
                   ncep.var(v).lon <= max(grid.interp_lon(:)) );
  lat_list = find( ncep.var(v).lat >= min(grid.interp_lat(:)) & ...)
                   ncep.var(v).lat <= max(grid.interp_lat(:)) );
  if ( isempty(lon_list) | isempty(lat_list) )
    error([ncep.var(v).long_name ' does not span the grid region.']);
  end
  lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
  lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
  lon_list = lon_list(find( lon_list > 0 & lon_list <= length(ncep.var(v).lon) ));
  lat_list = lat_list(find( lat_list > 0 & lat_list <= length(ncep.var(v).lat) ));
  [lon, lat] = meshgrid( ncep.var(v).lon(lon_list), ncep.var(v).lat(lat_list) );
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( ncep.interp_grid )
    if ( v==1 & mask )
      % Create the grid land mask for the data
      ncep.land_mask = round(griddata(ncep.var(1).lon,ncep.var(1).lat,ncep.land_mask,...
                                grid.interp_lon,grid.interp_lat));
    end
    ncep.var(v).lat = grid.interp_lat(:,1);
    ncep.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    ncep.var(v).lat = ncep.var(v).lat(lat_list);
    ncep.var(v).lon = ncep.var(v).lon(lon_list);
    ncep.var(v).eta = size(grid.interp_lat,1);
    ncep.var(v).xi  = size(grid.interp_lat,2);
  end

  % If the ROMS Grid is +/- longitude, make the NCEP data similar
  list = find( ncep.var(v).lon > 180 );
  ncep.var(v).lon(list) = ncep.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
    if ~ncep.interp_grid
      list=find(ncep.var(v).lon>=min(grid.interp_lon(:)) & ...
                          ncep.var(v).lon<=max(grid.interp_lon(:)));
      [ncep.var(v).lon,ix]=sort(ncep.var(v).lon(list));
      gwhichix=list(ix);
    end
  end

  if ( isfield(ncep,'output_file') )
    if ( v==1 & isfield(ncep,'netcdf_overwrite') )
      create_netcdf( ncep );
    end
    create_netcdf_var( ncep, v );
  end
  
  idx = 0;

  for f=1:size(ncep.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process NCEP file: %s\n', ncep.var(v).file(f,:));
    file_times = nc_varget( ncep.var(v).file(f,:), 'time' ) / 24 + datenum(1800,1,1);
    time_list = find( file_times >= ncep.time_start & file_times <= ncep.time_end ) - 1;
    time_stride=1;
    if ( isempty(time_list) )
      continue;
    end
    time_list=[time_list(1):time_stride:time_list(end)];
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( ncep.interp_grid == true )
      % data = permute(nc_varget(ncep.var(v).file(f,:), ncep.var(v).variable_name, ...
      %                  [ time_list(1) lat_index(1) lon_index(1) ], ...
      %                  [ length(time_list) lat_index(2) lon_index(2)],  ...
      %                  [ time_stride 1 1]),[2 3 1]);
      % % Use the Mex routine to go through all times and grid up the results
      % ncep.var(v).data(idx,:,:) = ...
      %     permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
      %               grid.interp_lat, ncep.var(v).roms_scale, ...
      %               ncep.var(v).roms_offset),[3 1 2]);
      data = nc_varget(ncep.var(v).file(f,:), ncep.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)],  ...
                       [ time_stride 1 1]);
      % Use the Mex routine to go through all times and grid up the results
      ncep.var(v).data(idx,:,:) = ...
          roms_interp(lon, lat, data, grid.interp_lon, ...
                    grid.interp_lat)*ncep.var(v).roms_scale + ...
                    ncep.var(v).roms_offset;
    else
      data = ...
          nc_varget(ncep.var(v).file(f,:), ncep.var(v).variable_name, ...
                          [ time_list(1) lat_index(1) lon_index(1) ], ...
                          [ length(time_list) lat_index(2) lon_index(2)],  ...
                          [ time_stride 1 1]) * ...
                          ncep.var(v).roms_scale + ncep.var(v).roms_offset;
      if ~isempty(gwhichix)
        % We have to stitch together if everything is out of whack
        data=data(:,:,gwhichix);
      end
      ncep.var(v).data(idx,:,:)=data;
    end
    if ( mask )
      m = reshape(ncep.land_mask,[1 size(ncep.land_mask)]);
      ncep.var(v).data(idx,:,:) = ncep.var(v).data(idx,:,:) .* ...
        m(ones(length(idx),1),:,:);
    end
    % Set the remaining parameters in the nc structure
    ncep.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % If we want to save it out now
    if ( isfield(ncep,'output_file') )
      clear ndata;
    end
  end
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
for v=1:num_vars,
  if ( isfield(ncep.var(v), 'operation') & ~isempty(ncep.var(v).operation) )
    ncep = ncep.var(v).operation( ncep, v, grid );
  end
end
return
