function h=add_speed_vec(fname,gname,tindex,level,skp,npts,...
                         scale,x0,y0,u_unit,units,...
                         fontsize)
hold_state = ishold;
%
% Defaults values
%

if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  disp('Default time index: 1')
  tindex=1;
end
if nargin < 3
  disp('Default level: -10 m')
  level= -10;
end
if nargin < 4
  disp('Default skip parameter: 1')
  skp=1;
end
if nargin < 5
  disp('Default boundary remove: [0 0 0 0]')
  npts=[0 0 0 0];
end
if nargin < 6
  disp('Default scale: 1')
  scale=1;
end

nc=netcdf(gname);
lat=nc{'lat_rho'}(:);
lon=nc{'lon_rho'}(:);
mask=nc{'mask_rho'}(:);
angle=nc{'angle'}(:);
if isempty(angle)
 disp('Warning: no angle found in history file')
 angle=0*lat;
end
close(nc);
warning off
mask=mask./mask;
warning on

if level==0
  level=-10;
end
if level==0
  u=get_hslice(fname,gname,'ubar',tindex,level,'u');
  v=get_hslice(fname,gname,'vbar',tindex,level,'v');
else
  u=get_hslice(fname,gname,'u',tindex,level,'u');
  v=get_hslice(fname,gname,'v',tindex,level,'v');
end
[u,v,lon,lat,mask]=uv_vec2rho(u,v,lon,lat,angle,mask,skp,npts);
  
if nargin < 8
  u=u*scale;
  v=v*scale;
  h=m_quiver(lon,lat,u,v,0,'k');
else
  h=m_quiver_fix(lon,lat,u,v,scale,x0,y0,u_unit,units,...
                         fontsize);
end
if ~hold_state, hold off; 
end
return
