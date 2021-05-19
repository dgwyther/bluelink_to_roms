function[r] = latlon2ecef(lat, lon, height)

% USAGE: [r] = latlon2ecef(lat, lon, height)
%\===============================================/
%| Description:  Function used to determine the  |
%|   ECEF coordinates from lat, lon, height      |
%\===============================================/

rlat = lat*pi/180;
rlon = lon*pi/180;
alt = 6378.137 + height;

r=[NaN NaN NaN];

r(1) = alt * cos(rlat) * cos(rlon);
r(2) = alt * cos(rlat) * sin(rlon);
r(3) = alt * sin(rlat);