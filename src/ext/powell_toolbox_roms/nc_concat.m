function nc = nc_concat( nc1, nc2 )

% function nc = nc_concat( nc1, nc2 )
%
% This function takes two data structures and combines them into
% a single, concatening any shared variables, so that the single
% record can be written out to a single netcdf file

if ( nargin ~= 2 )
  error('you must specify two structures to join');
end

% Start with the source
nc = nc1;

% Go through the variables from the second and add or append to the source
max_time = nc.time_end;
for var=1:nc2.vars,
  % Look for an existing record
  found = 0;
  for src=1:nc.vars,
    if ( strcmp( nc2.var(var).roms_variable_name, nc.var(src).roms_variable_name ) )
      found = src;
      break;
    end
  end
  % We need to concatenate
  if ( found )
    % The dimensions must be the same size
    dims = ndims(nc.var(found).data);
    for d=2:dims, % Skip the first dimension (time)
      if ( size(nc.var(found).data, d) ~= size(nc2.var(var).data, d) )
        d=0;
        break;
      end
    end
    if ( ~dims )
      fprintf(1, '%s is not the same size. Skipping.\n', nc2.var(var).roms_variable_name );
      continue
    end
    % Make sure we have times after the source
    time_list = find( nc2.var(var).data_time > max(nc.var(found).data_time) );
    if ( isempty(time_list) )
      fprintf(1, '%s has no non-overlapping times. Skipping.\n', nc2.var(var).roms_variable_name );
      continue;
    end
    % Stick them together
    nc.var(found).data_time = horzcat( nc.var(found).data_time, nc2.var(var).data_time(time_list));
    s = size( nc2.var(var).data );
    s(1) = length(time_list);
    nc.var(found).data = vertcat( nc.var(found).data, ...
            reshape(nc2.var(var).data(time_list,:), s) );
    max_time = max( max_time, max(nc2.var(var).data_time(time_list)) );
  else
    % Just add this variable into the structure
    nc.vars = nc.vars+1;
    nc.var(nc.vars) = nc2.var(var);
    max_time = max( max_time, max(nc2.var(var).data_time) );
  end
end
nc.time_end = max_time;