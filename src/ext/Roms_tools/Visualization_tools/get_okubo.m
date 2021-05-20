function [lat,lon,mask,lambda2]=get_okubo(hisfile,gridfile,tindex,vlevel,coef)
%
% Get the grid parameters
%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
mask(2:end-1,2:end-1)=mask(1:end-2,1:end-2).*...
                      mask(1:end-2,2:end-1).*...
                      mask(1:end-2,3:end).*...
                      mask(2:end-1,1:end-2).*...
                      mask(2:end-1,2:end-1).*...
                      mask(2:end-1,3:end).*...
                      mask(3:end,1:end-2).*...
                      mask(3:end,2:end-1).*...
                      mask(3:end,3:end);
nc=netcdf(gridfile);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
close(nc);
%
% Get the currents
%
if vlevel==0
  u=get_hslice(hisfile,gridfile,'ubar',tindex,vlevel,'u');
  v=get_hslice(hisfile,gridfile,'vbar',tindex,vlevel,'v');
else
  u=get_hslice(hisfile,gridfile,'u',tindex,vlevel,'u');
  v=get_hslice(hisfile,gridfile,'v',tindex,vlevel,'v');
end
%
% Get vorticity at rho points
%
lambda2=coef.*mask.*okubo_roms(u,v,pm,pn);
