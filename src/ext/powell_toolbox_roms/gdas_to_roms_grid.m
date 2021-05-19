function gdas = gdas_to_roms_grid( grid, gdas, mask )

% function gdas_to_roms_grid( grid, gdas, [ mask ] )
%
% Given a ROMS grid and an NCEP record, convert the NCEP
% data to the ROMS grid at the times specified in the record
% If mask is given true, then the grid mask is applied
% to the data.
%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if ( nargin < 3 )
  mask = false;
end

% Because some are composite, we won't use the vars, but rather calculate
% it ourselves
num_vars = length(gdas.var);
gdas.roms_grid = grid.interp_roms_grid;
for v=1:num_vars,
  % Are we crossing Greenwich?
  gwhich=[];
  if ( min(grid.interp_lon(:))<0 & max(grid.interp_lon(:))>0 )
    gwhich=find(grid.interp_lon<0);
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)+360;
  end
  % Figure out which region to grab
  lon_list = find( gdas.var(v).lon >= min(grid.interp_lon(:)) & ...
                   gdas.var(v).lon <= max(grid.interp_lon(:)) );
  lat_list = find( gdas.var(v).lat >= min(grid.interp_lat(:)) & ...)
                   gdas.var(v).lat <= max(grid.interp_lat(:)) );
  if ( isempty(lon_list) | isempty(lat_list) )
    error([gdas.var(v).long_name ' does not span the grid region.']);
  end
  lon_list = [ lon_list(1)-1; lon_list; lon_list(end)+1 ];
  lat_list = [ lat_list(1)-1; lat_list; lat_list(end)+1 ];
  lon_list = lon_list(find( lon_list > 0 & lon_list <= length(gdas.var(v).lon) ));
  lat_list = lat_list(find( lat_list > 0 & lat_list <= length(gdas.var(v).lat) ));
  [lon, lat] = meshgrid( gdas.var(v).lon(lon_list), gdas.var(v).lat(lat_list) );
  lon_index = [ lon_list(1)-1 length(lon_list) ];
  lat_index = [ lat_list(1)-1 length(lat_list) ];

  if ( ~gdas.roms_grid )
    if ( v==1 & mask )
      % Create the grid land mask for the data
      gdas.land_mask = round(griddata(gdas.var(1).lon,gdas.var(1).lat,gdas.land_mask,...
                                grid.interp_lon,grid.interp_lat));
    end
    gdas.var(v).lat = grid.interp_lat(:,1);
    gdas.var(v).lon = grid.interp_lon(1,:);
  else
    % Store the lat/lon used for this variable
    gdas.var(v).lat = gdas.var(v).lat(lat_list);
    gdas.var(v).lon = gdas.var(v).lon(lon_list);
    gdas.var(v).eta = size(grid.interp_lat,1);
    gdas.var(v).xi  = size(grid.interp_lat,2);
  end
  % If the ROMS Grid is +/- longitude, make the NCEP data similar
  list = find( gdas.var(v).lon > 180 );
  gdas.var(v).lon(list) = gdas.var(v).lon(list) - 360;
  if ( ~isempty(gwhich) )
    grid.interp_lon(gwhich)=grid.interp_lon(gwhich)-360;
    l=find(lon>180);
    lon(l)=lon(l)-360;
  end

  if ( isfield(gdas,'output_file') )
    if ( v==1 & isfield(gdas,'netcdf_overwrite') )
      create_netcdf( gdas );
    end
    create_netcdf_var( gdas, v );
  end
  
  idx = 0;
  for f=1:size(gdas.var(v).file,1),
    % Figure out which times to grab
    fprintf(1,'Process NCEP %s: %s\n', gdas.var(v).file(f,:), gdas.var(v).long_name);
    if ( ~exist( gdas.var(v).file(f,:), 'file') ) continue; end
    file_times = nc_varget( gdas.var(v).file(f,:), 'valtime' ) / 24 + datenum(1992,1,1);
    time_list = find( file_times >= gdas.time_start & file_times <= gdas.time_end ) - 1;
    if ( isempty(time_list) )
      continue;
    end
    idx=[idx(end)+1:idx(end)+length(time_list)]';

    % Go through and get everything
    if ( gdas.interp_grid == true )
      if ( gdas.var(v).level )
        data = squeeze(permute(nc_varget(gdas.var(v).file(f,:), gdas.var(v).variable_name, ...
                       [ time_list(1) gdas.var(v).level-1, lat_index(1) lon_index(1) ], ...
                       [ length(time_list) 1 lat_index(2) lon_index(2)]),[2 3 4 1]));
      else
        data = permute(nc_varget(gdas.var(v).file(f,:), gdas.var(v).variable_name, ...
                       [ time_list(1) lat_index(1) lon_index(1) ], ...
                       [ length(time_list) lat_index(2) lon_index(2)]),[2 3 1]);
      end
      % Use the Mex routine to go through all times and grid up the results
      gdas.var(v).data(idx,:,:) = ...
          permute(roms_mexgridder(data, lon, lat, grid.interp_lon, ...
                    grid.interp_lat, gdas.var(v).roms_scale, ...
                    gdas.var(v).roms_offset),[3 1 2]);
      % If we are using some special interp grid, store the lat/lon
    else
      gdas.var(v).data(idx,:,:) = ...
          nc_varget(gdas.var(v).file(f,:), gdas.var(v).variable_name, ...
                          [ time_list(1) lat_index(1) lon_index(1) ], ...
                          [ length(time_list) lat_index(2) lon_index(2)]) * ...
                          gdas.var(v).roms_scale + gdas.var(v).roms_offset;
      
    end
    if ( mask )
      m = reshape(grid.mask,[1 size(grid.mask)]);
      gdas.var(v).data(idx,:,:) = gdas.var(v).data(idx,:,:) .* ...
        m(ones(length(idx),1),:,:);
    end
    % Set the remaining parameters in the nc structure
    gdas.var(v).data_time(idx) = ...
      file_times(time_list+1);
    
    % If we want to save it out now
    if ( isfield(gdas,'output_file') )
      clear ndata;
    end
  end
  % Clean up the data of NaN fields
  list = nanmean(reshape(gdas.var(v).data,size(gdas.var(v).data,1), ...
                         size(gdas.var(v).data,2)*size(gdas.var(v).data,3)),2);
  list=find(~isnan(list));
  
  % Make sure the time is sequential
  [tmp,srt] = sort( gdas.var(v).data_time(list) );
  gdas.var(v).data = gdas.var(v).data(list(srt),:,:);
  gdas.var(v).data_time = gdas.var(v).data_time(list(srt));
end

% If there is an operation to perform on all of the fields, then do that
% saving the data in the first field and deleting the other data
for v=1:num_vars,
  if ( isfield(gdas.var(v), 'operation') & ~isempty(gdas.var(v).operation) )
    gdas = gdas.var(v).operation( gdas, v, grid );
  end
end
return
