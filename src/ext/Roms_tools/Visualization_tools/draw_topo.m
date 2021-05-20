function [C,h]=draw_topo(fname,npts,levs,options)
hold_state = ishold;
%
% Defaults values
%

if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  disp('Default level: 500 m')
  levs=[500 500];
end
if nargin < 3
  disp('Default option: k')
  options='k';
end

nc=netcdf(fname);
lat=nc{'lat_rho'}(:);
lon=nc{'lon_rho'}(:);
mask=nc{'mask_rho'}(:);
topo=nc{'h'}(:);
close(nc);
lat=rempoints(lat,npts);
lon=rempoints(lon,npts);
mask=rempoints(mask,npts);
topo=rempoints(topo,npts);
warning off
mask=mask./mask;
warning on

[C,h]=m_contour(lon,lat,mask.*topo,levs,options);

if ~hold_state, hold off; 
end
return
