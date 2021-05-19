function bath = bath_read( file, lat, lon )

% bath = bath_read( file, lat, lon )
%
% This function reads the Sandwell topo_8.2.img bathymetry file of 2min
%  resolution for the given lat/lon coordinates and returns the bathymetry
%  measure for the given points
%
% This function is modified from an original script by Sandwell

% determine the requested region
bath = zeros(size(lon));
lat=lat(:);
lon=lon(:);
l=find(lon<0);
if ( ~isempty(l) ) lon(l)=lon(l)+360; end

  
% Setup the parameters for reading Sandwell data
db_res         = 2/60;		% 2 minute resolution
db_resrad      = deg2rad(db_res);
db_loc         = [-72.006 72.006 0.0 360-db_res];
db_size        = [6336 10800];
nbytes_per_lat = db_size(2)*2;	% 2-byte integers
image_data     = [];

% Get the indices
lower_lat = log(tan(deg2rad(45 + db_loc(1)/2)));
y = fix( db_size(1)+ 1 - ((log(tan(deg2rad(45+lat./2))) - lower_lat) ./ db_resrad) );
x = fix( (lon - db_loc(3)) ./ db_res ) + 1;
data = y*db_size(2) + x;
% [offset,idx]=sort((data-1)*2);
% offset(2:end) = offset(2:end) - offset(1:end-1);
offset=(data-1)*2;
data = zeros(size(offset));

% Open the data file
fid = fopen(file, 'r', 'ieee-be');
if (fid < 0)
	error(['Could not open database: topo_8.2.img'],'Error');
end
% Go ahead and read the database
for i = 1:length(offset);
%  stats = fseek(fid, offset(i), 'cof');
  stats = fseek(fid, offset(i), 'bof');
  bath(i)=fread(fid,1,'integer*2');
end
% close the file
fclose(fid);	

% Use only the points requested
%bath(idx)=data;
