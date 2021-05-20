function [lat,lon,mask,psi]=get_streamfunc(hisfile,gridfile,tindex,vlevel,coef)
%
% Get the grid parameters
%
[lat,lon,rmask]=read_latlonmask(gridfile,'r');
[umask,vmask,pmask]=uvp_mask(rmask);
nc=netcdf(gridfile);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
close(nc);
%
% Get the currents
%
if vlevel==0
  u=umask.*get_hslice(hisfile,gridfile,'ubar',tindex,vlevel,'u');
  v=vmask.*get_hslice(hisfile,gridfile,'vbar',tindex,vlevel,'v');
else
  u=umask.*get_hslice(hisfile,gridfile,'u',tindex,vlevel,'u');
  v=vmask.*get_hslice(hisfile,gridfile,'v',tindex,vlevel,'v');
end
umask=~isnan(u2rho_2d(u));
vmask=~isnan(v2rho_2d(v));
u(isnan(u))=0;
v(isnan(v))=0;
mask=umask.*vmask;

%
% Boundary conditions
%
[u,v]=get_obcvolcons(u,v,pm,pn,mask,[1 1 1 1]);
psi=coef.*psi2rho(get_psi(u,v,pm,pn,mask));
