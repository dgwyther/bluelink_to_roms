function [lat,lon,mask,rho]=get_rho(hisfile,gridfile,tindex,vlevel,coef)
%
%
%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
temp=get_hslice(hisfile,gridfile,'temp',...
                tindex,vlevel,'r');
salt=get_hslice(hisfile,gridfile,'salt',...
                   tindex,vlevel,'r');
if vlevel < 0
  rho=coef.*mask.*rho_eos(temp,salt,vlevel);
elseif vlevel > 0
  z=get_depths(hisfile,gridfile,tindex,'r');
  rho=coef.*mask.*rho_eos(temp,salt,squeeze(z(vlevel,:,:)));
else
  error('RHO needs a vertical level ~= 0')
end
