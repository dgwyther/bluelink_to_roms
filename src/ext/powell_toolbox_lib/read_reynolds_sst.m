function sst = read_reynolds_sst( file, region )

% function sst = read_reynolds_sst( file, region )
%
% This function will read a Reynold's SST Weekly file and return
% only the data in the region specified by [ minlat maxlat minlon maxlon ]

nlon = 360;
nlat = 180;
sst = [];
sst.lon = [ 0.5:359.5 ];
sst.lat = [ -89.5:89.5 ];

if ( nargin < 2 )
  region = [ -90 90 0 360 ];
end
l = find(region(3:4) < 0);
if ( ~isempty(l) )
  region(l) = region(l) + 360;
end

% Grab the region
lon_list = find( sst.lon >= region(3) & sst.lon <= region(4) );
lat_list = find( sst.lat >= region(1) & sst.lat <= region(2) );
if ( isempty(lon_list) | isempty(lat_list) )
  error('region cannot be found');
end
sst.lon = sst.lon(lon_list);
sst.lat = sst.lat(lat_list);

% Open up the file
fid = fopen(file, 'rb', 'ieee-be');
if ( fid == -1 )
  error([file ' could not be opened']);
end

% Read the header info
header = fread(fid,11,'integer*4');
sst.sst = reshape(fread(fid,nlon*nlat,'real*4'), nlon, nlat)';
sst.sst = sst.sst(lat_list,lon_list);
sst.var = reshape(fread(fid,nlon*nlat,'real*4'), nlon, nlat)';
sst.var = sst.var(lat_list,lon_list);
sst.mask = reshape(fread(fid,nlon*nlat,'integer*1'), nlon, nlat)';
sst.mask = sst.mask(lat_list,lon_list);
sst.mask(find(sst.mask ~= 0))=nan;
sst.mask(find(~isnan(sst.mask)))=1;
keyboard
fclose(fid);

% Set up the headers
sst.start = datenum(header(2),header(3),header(4));
sst.end = datenum(header(5),header(6),header(7));
if ( sst.end - sst.start + 1 ~= header(8) )
  error('days and duration do not match.')
end

return