function r = earth_distance(lon1,lon2,lat1,lat2);

% Compute the distance between points
%
%  earth_distance(lon1, lon2, lat1, lat2)

if ( nargin == 1 )
  lon2=lon1(:,2);
  lat1=lon1(:,3);
  lat2=lon1(:,4);
  lon1=lon1(:,1);
end

epsilon = 0.99664718940443;  % This is Sqrt(1-epsilon^2)
radius = 6378.137; % Radius in kilometers

% Using trig identities of tan(atan(b)), cos(atan(b)), sin(atan(b)) for 
% working with geocentric where lat_gc = atan(epsilon * tan(lat))
tan_lat = epsilon .* tand(lat1);
cos_lat = 1 ./ sqrt(1+tan_lat.^2);
sin_lat = tan_lat ./ sqrt(1+tan_lat.^2);
tan_lat = epsilon .* tand(lat2);
cos_latj = 1 ./ sqrt(1+tan_lat.^2);
sin_latj = tan_lat ./ sqrt(1+tan_lat.^2);
clear tan_lat

r = radius.*sqrt(2*(1-cos_lat.*cos_latj.*cosd(lon1-lon2)-sin_lat.*sin_latj));
