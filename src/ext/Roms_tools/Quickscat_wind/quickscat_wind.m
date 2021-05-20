%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  quickscat_wind.m
%
%  Extrapole and interpole surface data to get surface boundary
%  conditions for ROMS (forcing netcdf file)
%
%  Interpolate QuickSCAT data on ROMS grid and write
%  into a ROMS netcdf forcing file
%
%  Penven - IRD 2004
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title - Grid file name - Forcing file name
%
grdname='roms_grd.nc';
frcname='roms_frc.nc';
datafile='../Quickscat_wind/sflux_global_clim.nc';
%
%  Wind stress
%
taux_file='../Quickscat_wind/sflux_global_clim.nc';
taux_name='taux';
tauy_file='../Quickscat_wind/sflux_global_clim.nc';
tauy_name='tauy';
smst = (1:12);  % time for wind stress [days]
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
nc=netcdf(grdname);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
angle=nc{'angle'}(:);
result=close(nc);
cosa = cos(angle);
sina = sin(angle);
%
% Loop on time
%
nc=netcdf(frcname,'write');
for tindex=1:length(smst)
  time=nc{'sms_time'}(tindex);
  u=ext_data(taux_file,taux_name,tindex,...
             lon,lat,time);
  v=ext_data(tauy_file,tauy_name,tindex,...
             lon,lat,time);
%
%  Rotation (if not rectangular lon/lat grid)
%
  nc{'sustr'}(tindex,:,:)=rho2u_2d(u.*cosa + v.*sina);
  nc{'svstr'}(tindex,:,:)=rho2v_2d(v.*cosa - u.*sina);
end
close(nc)
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
test_forcing(frcname,grdname,'spd',[1 4 7 10],3)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
