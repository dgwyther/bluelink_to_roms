function [lat,lon,mask,bvf]=get_bvf(hisfile,gridfile,tindex,vlevel,coef)
%
% get an horizontal slice of brunt vaissala frequency
%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
zr=get_depths(hisfile,gridfile,tindex,'r');
zw=get_depths(hisfile,gridfile,tindex,'r');
nc=netcdf(hisfile);
temp=squeeze(nc{'temp'}(tindex,:,:,:));
salt=squeeze(nc{'salt'}(tindex,:,:,:));
close(nc)
[N,M,L]=size(zw);
mask3d=tridim(mask,N);

bvf=coef.*mask3d.*bvf_eos(temp,salt,zr,zw,9.81,1025);
bvf=vinterp(bvf,zw,vlevel);
bvf(bvf<0)=0;
