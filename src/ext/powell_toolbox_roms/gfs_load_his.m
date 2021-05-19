function bad_list = gfs_load_his( grid, hisfile, day, epoch )

%
% Created by Brian Powell on 2008-12-29.
% Copyright (c)  powellb. All rights reserved.
%
% http://nomads.ncep.noaa.gov:9090/dods/gfs_hd/gfs_hd20090301/gfs_hd_00z
%

url='http://nomads.ncep.noaa.gov:9090/dods/gfs_hd/gfs_hd%s/gfs_hd_00z';

if (nargin < 4)
  epoch=datenum(1900,1,1);
end
if (nargin < 3)
  error('you must specify a grid, name of history file, day, epoch');
end

% Create the URL
gfsfile=sprintf(url,regexprep(datestr(day,29),'-',''));

% Create the grid to put the meteorology on
grid = create_roms_interp_grid( grid, 0.5 );

% The variables we need
vars = { 'wind' 'tair' 'qair' 'rain' 'pair' 'lwrad' 'swrad' };
gfs = gfs_nc_info(vars, gfsfile, true);

% Load and grid the data
gfs = gfs_to_roms_grid(grid, gfs, false);

% Save it out
write_netcdf(gfs, hisfile, epoch);
