function h=bounddomain(lon,lat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
% function h=bounddomain(lon,lat);
%
% draw a line along the boundaries of the model domain
%
% input:
%
%  lat      Latitude (2D matrix) 
%  lon      Longitude (2D matrix) 
%
% output:
%
%  h        line handle (scalar)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mp,Lp]=size(lon);
imin=1;
imax=Lp;
jmin=1;
jmax=Mp;
xsquare=cat(1,lon(jmin:jmax,imin),  ...
                lon(jmax,imin:imax)' ,...
                lon(jmax:-1:jmin,imax),...
                lon(jmin,imax:-1:imin)' );
ysquare=cat(1,lat(jmin:jmax,imin),  ...
                lat(jmax,imin:imax)' ,...
                lat(jmax:-1:jmin,imax),...
                lat(jmin,imax:-1:imin)' );
h=m_line(xsquare,ysquare);
return
