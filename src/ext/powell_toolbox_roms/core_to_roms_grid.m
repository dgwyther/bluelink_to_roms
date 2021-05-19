function core = core_to_roms_grid( grid, core, mask )

% function core_to_roms_grid( grid, core, [ mask ] )
%
% Given a ROMS grid and an core record, convert the core
% data to the ROMS grid at the times specified in the record
% If mask is given true, then the grid mask is applied
% to the data.

if ( nargin < 3 )
  mask = false;
end

% Because some are composite, we won't use the vars, but rather calculate
% it ourselves
num_vars = length(core.var);
core.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  lon_list = find( core.var(v).lon >= min(grid.interp_lon(:)) & ...
                   core.var(v).lon <= max(grid.interp_lon(:)) );
  lat_list = find( core.var(v).lat >= min(grid.interp_lat(:)) & ...)
                   core.var(v).lat <= max(grid.interp_lat(:)) );
  if ( isempty(lon_list) | isempty(lat_list) )
    error([core.var(v).long_name ' does not span the grid region.']);
  end
  lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
  lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
  lon_list = lon_list(find( lon_list > 0 & lon_list <= length(core.var(v).lon) ));
  lat_list = lat_list(find( lat_list > 0 & lat_list <= length(core.var(v).lat) ));
  [lon, lat] = meshgrid( core.var(v).lon(lon_list), core.var(v).lat(lat_list) );
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( ~core.roms_grid )
    core.var(v).lat = grid.interp_lat(:,1);
    core.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    core.var(v).lat = core.var(v).lat(lat_list);
    core.var(v).lon = core.var(v).lon(lon_list);
    core.var(v).eta = size(grid.interp_lat,1);
    core.var(v).xi  = size(grid.interp_lat,2);
  end
  % If the ROMS Grid is +/- longitude, make the core data similar
  list = find( core.var(v).lon > 180 );
  core.var(v).lon(list) = core.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
  end

  if ( isfield(core,'output_file') )
    if ( v==1 & isfield(core,'netcdf_overwrite') )
      create_netcdf( core );
    end
    create_netcdf_var( core, v );
  end
  
  idx = 0;
  for f=1:size(core.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process core file: %s\n', core.var(v).file(f,:));
    % CORE Uses 365 day years no matter what. This will scale the time vector
    % into the appropriate time length for the year we are in.
    file_times = ( nc_varget( core.var(v).file(f,:), core.var(v).variable_time ) - ...
                    ( ( core.var(v).year(f) - 1948 ) * 365 )) * ...
                    ( ( datenum(core.var(v).year(f)+1,1,1) - ... 
                        datenum(core.var(v).year(f),1,1) )/365 ) + ...
                    datenum(core.var(v).year(f),1,1);
    
    time_list = find( file_times >= core.time_start & file_times <= core.time_end ) - 1;
    if ( isempty(time_list) )
      continue;
    end
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( core.interp_grid == true )
      data = permute(nc_varget(core.var(v).file(f,:), core.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)]),[2 3 1]);
      % Use the Mex routine to go through all times and grid up the results
      core.var(v).data(idx,:,:) = ...
          permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
                    grid.interp_lat, core.var(v).roms_scale, ...
                    core.var(v).roms_offset),[3 1 2]);
      % If we are using some special interp grid, store the lat/lon
    else
      core.var(v).data(idx,:,:) = ...
          nc_varget(core.var(v).file(f,:), core.var(v).variable_name, ...
                          [ time_list(1) lat_index(1) lon_index(1) ], ...
                          [ length(time_list) lat_index(2) lon_index(2)]) * ...
                          core.var(v).roms_scale + core.var(v).roms_offset;
      
    end
    if ( mask )
      m = reshape(grid.mask,[1 size(grid.mask)]);
      core.var(v).data(idx,:,:) = core.var(v).data(idx,:,:) .* ...
        m(ones(length(idx),1),:,:);
    end
    % Set the remaining parameters in the nc structure
    core.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % If we want to save it out now
    if ( isfield(core,'output_file') )
      clear ndata;
    end
  end
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
for v=1:num_vars,
  if ( isfield(core.var(v), 'operation') & ~isempty(core.var(v).operation) )
    core = core.var(v).operation( core, v, grid );
  end
end
return
