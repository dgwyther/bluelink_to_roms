function [lat,lon,mask]=read_latlonmask(fname,type);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
% function [lat,lon,mask]=read_latlonmask(fname,type);
%
% read the latitude, the longitude and the mask from a
% netcdf ROMS file 
%
% input:
%
%  fname    ROMS file name
%  type    type of the variable (character):
%             r for 'rho'
%             w for 'w'
%             u for 'u'
%             v for 'v'
%
% output:
%
%  lat      Latitude  (2D matrix) 
%  lon      Longitude (2D matrix) 
%  mask     Mask (2D matrix) (1:sea - nan:land)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
nc=netcdf(fname);
lat=nc{'lat_rho'}(:);
lon=nc{'lon_rho'}(:);
mask=nc{'mask_rho'}(:);
close(nc);
%
[Mp,Lp]=size(mask);
%
if (type=='u')
  lat=rho2u_2d(lat);
  lon=rho2u_2d(lon);
  mask=mask(:,1:Lp-1).*mask(:,2:Lp);
end
if (type=='v')
  lat=rho2v_2d(lat);
  lon=rho2v_2d(lon);
  mask=mask(1:Mp-1,:).*mask(2:Mp,:);
end
%
mask(mask==0)=NaN;
return
