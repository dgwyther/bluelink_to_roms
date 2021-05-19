function maphawaii(color)

if nargin==0
  color='k';
end

load coastline_hawaii.mat
 
fillseg(coast,color,color);
%plot(lon,lat,color);
hold on
