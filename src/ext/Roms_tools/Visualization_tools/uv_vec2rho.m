function [ured,vred,lonred,latred,maskred]=...
         uv_vec2rho(u,v,lon,lat,angle,mask,skip,npts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pierrick 2001
%
%
% put a uv current field in the carthesian frame
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Boundaries
%
lat=rempoints(lat,npts);
lon=rempoints(lon,npts);
mask=rempoints(mask,npts);
angle=rempoints(angle,npts);
u=rempoints(u,npts);
v=rempoints(v,npts);
%
%  Values at rho points.
%
ur=u2rho_2d(u);
vr=v2rho_2d(v);
%
%  Rotation
%
cosa = cos(angle);
sina = sin(angle);
u = ur.*cosa - vr.*sina;
v = vr.*cosa + ur.*sina;
%
%  Skip
%
[M,L]=size(lon);
imin=floor(0.5+0.5*skip);
imax=floor(0.5+L-0.5*skip);
jmin=ceil(0.5+0.5*skip);
jmax=ceil(0.5+M-0.5*skip);
ured=u(jmin:skip:jmax,imin:skip:imax);
vred=v(jmin:skip:jmax,imin:skip:imax);
latred=lat(jmin:skip:jmax,imin:skip:imax);
lonred=lon(jmin:skip:jmax,imin:skip:imax);
maskred=mask(jmin:skip:jmax,imin:skip:imax);
%
%  Apply mask
%
ured=maskred.*ured;
vred=maskred.*vred;
lonred=maskred.*lonred;
latred=maskred.*latred;
return
