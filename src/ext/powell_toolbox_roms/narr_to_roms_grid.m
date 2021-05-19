function narr = narr_to_roms_grid( grid, narr, mask )

% function narr_to_roms_grid( grid, narr, [ mask ] )
%
% Given a ROMS grid and an narr record, convert the narr
% data to the ROMS grid at the times specified in the record
% If mask is given true, then the grid mask is applied
% to the data.

if ( nargin < 3 )
  mask = false;
end

% Because some are composite, we won't use the vars, but rather calculate
% it ourselves
num_vars = length(narr.var);
narr.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  list = find( narr.var(v).lon >= min(grid.interp_lon(:))-0.5 & ...
               narr.var(v).lon <= max(grid.interp_lon(:))+0.5 & ...
               narr.var(v).lat >= min(grid.interp_lat(:))-0.5 & ...
               narr.var(v).lat <= max(grid.interp_lat(:))+0.5 );
  if ( isempty(list) )
    error([narr.var(v).long_name ' does not span the grid region.']);
  end
  [lat_list,lon_list]=ind2sub(size(narr.var(v).lon),list);
  lat_list=sort(unique(lat_list));
  lon_list=sort(unique(lon_list));
  lon=narr.var(v).lon(lat_list,lon_list);
  lat=narr.var(v).lat(lat_list,lon_list);
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( narr.interp_grid )
    if ( v==1 & mask )
      % Create the grid land mask for the data
      narr.land_mask = round(griddata(narr.var(1).lon,narr.var(1).lat,narr.land_mask,...
                                grid.interp_lon,grid.interp_lat));
    end
    narr.var(v).lat = grid.interp_lat(:,1);
    narr.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    narr.var(v).lat = narr.var(v).lat(lat_list);
    narr.var(v).lon = narr.var(v).lon(lon_list);
    narr.var(v).eta = size(grid.interp_lat,1);
    narr.var(v).xi  = size(grid.interp_lat,2);
  end

  % If the ROMS Grid is +/- longitude, make the narr data similar
  list = find( narr.var(v).lon > 180 );
  narr.var(v).lon(list) = narr.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
  end

  if ( isfield(narr,'output_file') )
    if ( v==1 & isfield(narr,'netcdf_overwrite') )
      create_netcdf( narr );
    end
    create_netcdf_var( narr, v );
  end
  
  idx = 0;
  for f=1:size(narr.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process narr file: %s\n', narr.var(v).file(f,:));
    file_times = nc_varget( narr.var(v).file(f,:), 'time' ) / 24 + datenum(1800,1,1);
    time_list = find( file_times >= narr.time_start & file_times <= narr.time_end ) - 1;
    % This is 3-hour data, but let's do like NCEP, 6-hour
    time_stride=2;
    time_list=[time_list(1):time_stride:time_list(end)];
    if ( isempty(time_list) )
      continue;
    end
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( narr.interp_grid == true )
      data = permute(nc_varget(narr.var(v).file(f,:), narr.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)],  ...
                       [ time_stride 1 1]),[2 3 1]);
      % Use the Mex routine to go through all times and grid up the results
      narr.var(v).data(idx,:,:) = ...
          permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
                    grid.interp_lat, narr.var(v).roms_scale, ...
                    narr.var(v).roms_offset),[3 1 2]);
    else
      narr.var(v).data(idx,:,:) = ...
          nc_varget(narr.var(v).file(f,:), narr.var(v).variable_name, ...
                          [ time_list(1) lat_index(1) lon_index(1) ], ...
                          [ length(time_list) lat_index(2) lon_index(2)],  ...
                          [ time_stride 1 1]) * ...
                          narr.var(v).roms_scale + narr.var(v).roms_offset;
      
    end
    if ( mask )
      m = reshape(narr.land_mask,[1 size(narr.land_mask)]);
      narr.var(v).data(idx,:,:) = narr.var(v).data(idx,:,:) .* ...
        m(ones(length(idx),1),:,:);
    end
    % Get rid of nan's
    nan_list=find(isnan(narr.var(v).data));
    if (~isempty(nan_list))
      narr.var(v).data(nan_list)=-999999.0;
      narr.var(v).bad=-999999.0;
    end
    % Set the remaining parameters in the nc structure
    narr.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % If we want to save it out now
    if ( isfield(narr,'output_file') )
      clear ndata;
    end
  end
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
for v=1:num_vars,
  if ( isfield(narr.var(v), 'operation') & ~isempty(narr.var(v).operation) )
    narr = narr.var(v).operation( narr, v, grid );
  end
end
return
