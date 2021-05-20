function [lat,lon,mask,rho]=get_pot(hisfile,gridfile,tindex,vlevel,coef)
%
% get potential density
%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
temp=get_hslice(hisfile,gridfile,'temp',...
                tindex,vlevel,'r');
salt=get_hslice(hisfile,gridfile,'salt',...
                   tindex,vlevel,'r');
rho=coef.*mask.*rho_pot(temp,salt);
