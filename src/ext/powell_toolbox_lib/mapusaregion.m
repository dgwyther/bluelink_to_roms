function mapusaregion(reg, varargin)

% function mapusaregion([ minlat maxlat minlon maxlon ], plot_options)
%
% Given a latitude/longitude region (longitude may be +/- west),
% Plot a map of the coastlines

if ( nargin < 1 )
  error('You must specify a region');
end

if ( reg(1) > reg(2) | reg(3) > reg(4) ) 
  error('The bounding box is incorrect.');
end

if ( exist('usalo') ~= 1)
  load ~/matlab/usalo
end

% Grab the right dataset
if ( reg(3) > 0 | reg(4) > 0 )
  lon = usalo.lon;
else
  lon = usalo.neg_lon;
end
lat = usalo.lat;

% Find our region
l = find( lat <= reg(2) & lat >= reg(1) & lon <= reg(4) & lon >= reg(3) );
length(l);
gap = find( ( l(2:end) - l(1:end-1) ) > 1 );
if ( ~isempty(gap) )
  lat = insert( lat(l), gap+1, nan );
  lon = insert( lon(l), gap+1, nan );
end

% Plot it up
plot(lon, lat, varargin{:});
mapax(floor((max(lon)-min(lon))/8*60),-1,floor((max(lat)-min(lat))/8*60),-1);
