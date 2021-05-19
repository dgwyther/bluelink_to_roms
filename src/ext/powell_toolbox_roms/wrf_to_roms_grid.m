
function wrf = wrf_to_roms_grid( grid, wrf, mask )

% function wrf_to_roms_grid( grid, wrf, [ mask ] )
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
num_vars = length(wrf.var);
wrf.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  list = find( wrf.var(v).lon >= min(grid.interp_lon(:))-0.05 & ...
               wrf.var(v).lon <= max(grid.interp_lon(:))+0.05 & ...
               wrf.var(v).lat >= min(grid.interp_lat(:))-0.05 & ...
               wrf.var(v).lat <= max(grid.interp_lat(:))+0.05 );
  if ( isempty(list) )
    error([wrf.var(v).long_name ' does not span the grid region.']);
  end
  [lat_list,lon_list]=ind2sub(size(wrf.var(v).lon),list);
  lat_list=sort(unique(lat_list));
  lon_list=sort(unique(lon_list));
  lon=wrf.var(v).lon(lat_list,lon_list);
  lat=wrf.var(v).lat(lat_list,lon_list);
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( wrf.interp_grid )
    if ( v==1 & mask )
      % Create the grid land mask for the data
      wrf.land_mask = round(griddata(wrf.var(1).lon,wrf.var(1).lat,wrf.land_mask,...
                                grid.interp_lon,grid.interp_lat));
    end
    wrf.var(v).lat = grid.interp_lat(:,1);
    wrf.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    wrf.var(v).lat = wrf.var(v).lat(lat_list,lon_list);
    wrf.var(v).lon = wrf.var(v).lon(lat_list,lon_list);
    wrf.var(v).eta = size(grid.interp_lat,1);
    wrf.var(v).xi  = size(grid.interp_lat,2);
  end
  % If the ROMS Grid is +/- longitude, make the WRF data similar
  list = find( wrf.var(v).lon > 180 );
  wrf.var(v).lon(list) = wrf.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
  end
 
  if ( isfield(wrf,'output_file') )
    if ( v==1 & isfield(wrf,'netcdf_overwrite') )
      create_netcdf( wrf );
    end
    create_netcdf_var( wrf, v );
  end
  
  idx = 0;
  for f=1:size(wrf.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process WRF %s: %s\n', wrf.var(v).file(f,:), wrf.var(v).long_name);
    file_times = nc_varget( wrf.var(v).file(f,:), 'XTIME' )/1440 + wrf.epoch;
    time_list = find( file_times >= wrf.time_start & file_times <= wrf.time_end ) - 1;
    time_stride=1;
    time_list=[time_list(1):time_stride:time_list(end)];
    if ( isempty(time_list) )
      continue;
    end
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( wrf.interp_grid == true )
      if ( wrf.var(v).level )
        data = squeeze(permute(nc_varget(wrf.var(v).file(f,:), wrf.var(v).variable_name, ...
                       [ time_list(1) wrf.var(v).level-1, lat_index(1) lon_index(1) ], ...
                       [ length(time_list) 1 lat_index(2) lon_index(2)]),[2 3 4 1]));
      else
        data = permute(nc_varget(wrf.var(v).file(f,:), wrf.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)]),[2 3 1]);
      end
      % Use the Mex routine to go through all times and grid up the results
      wrf.var(v).data(idx,:,:) = ...
          permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
                    grid.interp_lat, wrf.var(v).roms_scale, ...
                    wrf.var(v).roms_offset),[3 1 2]);
      % If we are using some special interp grid, store the lat/lon
    else
      wrf.var(v).data(idx,:,:) = ...
          nc_varget(wrf.var(v).file(f,:), wrf.var(v).variable_name, ...
                          [ time_list(1) lat_index(1) lon_index(1) ], ...
                          [ length(time_list) lat_index(2) lon_index(2)],  ...
                          [ time_stride 1 1 ]) * ...
                          wrf.var(v).roms_scale + wrf.var(v).roms_offset;
    end
    if ( mask )
      m = reshape(grid.mask,[1 size(grid.mask)]);
      wrf.var(v).data(idx,:,:) = wrf.var(v).data(idx,:,:) .* ...
        m(ones(length(idx),1),:,:);
    end
    % Set the remaining parameters in the nc structure
    wrf.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % Clean up the data of NaN fields
    list = nanmean(reshape(wrf.var(v).data,size(wrf.var(v).data,1), ...
                           size(wrf.var(v).data,2)*size(wrf.var(v).data,3)),2);
    list=find(~isnan(list));
    
    % Make sure the time is sequential
    [tmp,srt] = sort( wrf.var(v).data_time(list) );
    wrf.var(v).data = wrf.var(v).data(list(srt),:,:);
    wrf.var(v).data_time = wrf.var(v).data_time(list(srt));

    % If we want to save it out now
    if ( isfield(wrf,'output_file') )
      clear ndata;
    end
  end
end

% Now that everything is loaded, see if there are any operations to perform
for v=1:num_vars,
  if ( isfield(wrf.var(v), 'operation') & ~isempty(wrf.var(v).operation) )
    wrf = wrf.var(v).operation( wrf, v, grid );
  end
end

return
