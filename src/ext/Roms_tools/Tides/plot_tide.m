function plot_tide(grdname,frcname,k,cff,skp)
%clear all
%close all
%grdname='/home/penven/Roms_tools/Run/roms_grd.nc';
%frcname='/home/penven/Roms_tools/Run/roms_frc.nc';
%k=1;
%cff=0.1;
%skp=1;
%
rad=pi/180.0;
deg=180.0/pi;


nc=netcdf(grdname);
rlon=nc{'lon_rho'}(:);
rlat=nc{'lat_rho'}(:);
rmask=nc{'mask_rho'}(:);
rangle=nc{'angle'}(:);
close(nc)
[M,L]=size(rlat);

nc=netcdf(frcname);
tide_Eamp(:,:)=nc{'tide_Eamp'}(k,:,:);
tide_Cmax(:,:)=nc{'tide_Cmax'}(k,1:skp:M,1:skp:L);
tide_Cmin(:,:)=nc{'tide_Cmin'}(k,1:skp:M,1:skp:L);
tide_Cangle(:,:)=rad*nc{'tide_Cangle'}(k,1:skp:M,1:skp:L);
cmpt=nc.components(:);
disp(['Plot tidal component : ',cmpt(3*k-2:3*k)])
close(nc)
slon=rlon(1:skp:M,1:skp:L);
slat=rlat(1:skp:M,1:skp:L);
smask=rmask(1:skp:M,1:skp:L);

rmask(rmask==0)=NaN;


pcolor(rlon,rlat,rmask.*tide_Eamp)
shading flat
colorbar
hold on
ellipse(cff*smask.*tide_Cmax,cff*smask.*tide_Cmin,smask.*tide_Cangle,slon,slat,'k');
axis([min(min(rlon)) max(max(rlon)) min(min(rlat)) max(max(rlat))])
title(['Amplitude [m] of tide : ',cmpt(3*k-2:3*k)])
hold off

