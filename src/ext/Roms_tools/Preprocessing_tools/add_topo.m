function h=add_topo(grdname,toponame)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% add a topography (here etopo2) to a ROMS grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%
%  read grid
%
nc=netcdf(grdname);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
result=close(nc);
%
dl=1;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
%  open the topo file
%
nc=netcdf(toponame);
tlon=nc{'lon'}(:);
tlat=nc{'lat'}(:);
%
%  get a subgrid
%
j=find(tlat>=latmin & tlat<=latmax);
i1=find(tlon-360>=lonmin & tlon-360<=lonmax);
i2=find(tlon>=lonmin & tlon<=lonmax);
i3=find(tlon+360>=lonmin & tlon+360<=lonmax);
x=cat(1,tlon(i1)-360,tlon(i2),tlon(i3)+360);
y=tlat(j);
%
%  Read data
%
if ~isempty(i2)
  topo=-nc{'topo'}(j,i2);
else
  topo=[];
end
if ~isempty(i1)
  topo=cat(2,-nc{'topo'}(j,i1),topo);
end
if ~isempty(i3)
  topo=cat(2,topo,-nc{'topo'}(j,i3));
end
result=close(nc);
%
%  interpole topo
%
h=interp2(x,y,topo,lon,lat,'cubic');
return
