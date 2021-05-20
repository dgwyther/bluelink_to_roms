function [lat,lon,mask,spd]=get_speed(hisfile,gridfile,tindex,vlevel,coef)
%
%
%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
if vlevel==0
  u=u2rho_2d(get_hslice(hisfile,gridfile,'ubar',...
             tindex,vlevel,'u'));
  v=v2rho_2d(get_hslice(hisfile,gridfile,'vbar',...
             tindex,vlevel,'v'));
else
  u=u2rho_2d(get_hslice(hisfile,gridfile,'u',...
             tindex,vlevel,'u'));
  v=v2rho_2d(get_hslice(hisfile,gridfile,'v',...
             tindex,vlevel,'v'));
end
spd=coef.*mask.*sqrt(u.^2+v.^2);
