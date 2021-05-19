function data = cora_read_winds( cora, fidx, lat_list, lon_list )

% function wind = read_winds( year, lat, lon )
%
% Read the NCEP/Scatterometer blended winds from the CORA data files
% file is the filename to load
% lat is a vector containing the extents of the latitude range
% lon is a vector containing the extents of the longitude range

fid = fopen(cora.var(1).file(fidx,:),'rb','ieee-le');
if ( fid == -1 )
  error('File not found');
end

lon_len = length(cora.var(1).def_lon);
lat_len = length(cora.var(1).def_lat);

count = 1;
fseek(fid,0,1);
len = ftell(fid);
fseek(fid,0,-1);
while ( ftell(fid)+4 < len )
  fseek(fid, 4, 'cof');
  data.time(count) = fread(fid,1,'real*4');
  fseek(fid, 8, 'cof');
  temp_u = reshape(fread(fid,lon_len*lat_len,'real*4'), lon_len, lat_len)';
  fseek(fid, 8, 'cof');
  temp_v = reshape(fread(fid,lon_len*lat_len,'real*4'), lon_len, lat_len)';
  fseek(fid, 4, 'cof');
  data.u(count,:,:)=reshape(temp_u(lat_list,lon_list), length(lat_list), length(lon_list));
  data.v(count,:,:)=reshape(temp_v(lat_list,lon_list), length(lat_list), length(lon_list));
  count = count + 1;
end

% Convert the day of the year CORA record to matlab
data.time = datenum(cora.var(1).epoch_year(fidx),1,1)+data.time;

