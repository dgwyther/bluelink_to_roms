function [lat,lon,mask,pv]=get_pv(hisfile,gridfile,tindex,vlevel,coef)
%
%
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
if vlevel==0
%
% [xi+f]/(h+zeta)
%
  nc=netcdf(hisfile);
  ubar(:,:)=nc{'ubar'}(tindex,:,:);
  vbar(:,:)=nc{'vbar'}(tindex,:,:);
  zeta(:,:)=nc{'zeta'}(tindex,:,:);
  close(nc)
  nc=netcdf(gridfile);
  f=nc{'f'}(:);
  h=nc{'h'}(:);
  pm=nc{'pm'}(:);
  pn=nc{'pn'}(:);
  close(nc)
  xi=psi2rho(vorticity(ubar,vbar,pm,pn)); 
  pv=mask.*coef.*(xi+f)./(h+zeta);
else
  epv = ertel(hisfile,gridfile,'rho',tindex);  
  if vlevel >0
    pv=coef.*mask.*squeeze(epv(vlevel,:,:));
  else
    z=get_depths(hisfile,gridfile,tindex,'w');
    pv = coef.*mask.*vinterp(epv,z,vlevel);
  end
end
