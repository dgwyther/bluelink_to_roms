function [lat,lon,rmask,psi]=get_transfunc(hisfile,gridfile,tindex,coef)
%
% Get the grid parameters
%
nc=netcdf(gridfile);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
rmask=nc{'mask_rho'}(:);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
h=nc{'h'}(:);
close(nc);
[umask,vmask,pmask]=uvp_mask(rmask);
%
% Get the currents
%
ubar=get_hslice(hisfile,gridfile,'ubar',tindex,0,'u');
vbar=get_hslice(hisfile,gridfile,'vbar',tindex,0,'v');
zeta=get_hslice(hisfile,gridfile,'zeta',tindex,0,'r');
Du=ubar.*rho2u_2d(h+zeta);
Dv=vbar.*rho2v_2d(h+zeta);

%
% Boundary conditions
%
[Du,Dv]=get_obcvolcons(Du,Dv,pm,pn,rmask,[1 1 1 1]);
psi=coef.*psi2rho(get_psi(Du,Dv,pm,pn,rmask));
