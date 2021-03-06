%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a ROMS forcing file
%
%  Extrapole and interpole surface data to get surface boundary
%  conditions for ROMS (forcing netcdf file)
%
%  Data input format (netcdf):
%     taux(T, Y, X)
%     T : time [Months]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library 
%                (Atlas of Surface Marine Data 1994)
%
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.DASILVA/
%
%  Pierrick Penven, IRD, 2002.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title - Grid file name - Forcing file name
%
title=['Forcing (COADS)'];
grdname='roms_grd.nc';
frcname='roms_frc.nc';
%
%  Wind stress
%
taux_file='../COADS05/taux.cdf';
taux_name='taux';
tauy_file='../COADS05/tauy.cdf';
tauy_name='tauy';
smst = (15:30:345);  % time for wind stress [days]
smsc = 360;          % cycle for wind stress [days]
%
%  Heat fluxes w3
%
shf_file='../COADS05/netheat.cdf';
shf_name='netheat';
shft = smst;         % time for heat flux
shfc = smsc;         % cycle length for heat flux 
%
%  Fresh water fluxes (evaporation - precipitation)
%
swf_file='../COADS05/emp.cdf';
swf_name='emp';
swft = smst;         % time for fresh water flux 
swfc = smsc;         % cycle length for fresh water flux
%
%  Sea surface temperature and heat flux sensitivity to the
%  sea surface temperature (dQdSST).
%  To compute dQdSST we need:
%    sat     : Surface atmospheric temperature
%    airdens : Surface atmospheric density
%    w3      : Wind speed at 10 meters
%    qsea    : Sea level specific humidity
%
sst_file='../COADS05/sst.cdf';
sst_name='sst';
sat_file='../COADS05/sat.cdf';
sat_name='sat';
airdens_file='../COADS05/airdens.cdf';
airdens_name='airdens';
w3_file='../COADS05/w3.cdf';
w3_name='w3';
qsea_file='../COADS05/qsea.cdf';
qsea_name='qsea';
sstt = smst;         % time for sst
sstc = smsc;         % cycle length for sst
%
%  Sea surface salinity
%
sss_file='../COADS05/sss.cdf';
sss_name='salinity';
ssst = smst;         % time for sss
sssc = smsc;         % cycle length for sss
%
%  Short wave radiation
%
srf_file='../COADS05/shortrad.cdf';
srf_name='shortrad';
srft = smst;         % time for short wave radiation
srfc = smsc;         % cycle length for short wave radiation
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp(title)
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
% Create the forcing file
%
disp(' ')
disp(' Create the forcing file...')
create_forcing(frcname,grdname,title,smst,...
               shft,swft,srft,sstt,ssst,smsc,...
               shfc,swfc,srfc,sstc,sssc)
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
for tindex=1:length(shft)
  time=nc{'shf_time'}(tindex);
  nc{'shflux'}(tindex,:,:)=ext_data(shf_file,shf_name,tindex,...
                                    lon,lat,time);
end
for tindex=1:length(swft)
  time=nc{'swf_time'}(tindex);
%
% coeff = mm/(3hour) -> centimeter day-1 (!!!!!)
%
  nc{'swflux'}(tindex,:,:)=0.8*ext_data(swf_file,swf_name,tindex,...
                                        lon,lat,time);
%  nc{'swflux'}(tindex,:,:)=0.8*(ext_data(evap_file,evap_name,...
%                                         tindex,lon,lat,time)-...
%			        ext_data(precip_file,precip_name,...
%                                         tindex,lon,lat,time));
end
for tindex=1:length(sstt)
  time=nc{'sst_time'}(tindex);
  sst=ext_data(sst_file,sst_name,tindex,lon,lat,time);
  sat=ext_data(sat_file,sat_name,tindex,lon,lat,time);
  airdens=ext_data(airdens_file,airdens_name,tindex,lon,lat,time);
  w3=ext_data(w3_file,w3_name,tindex,lon,lat,time);
  qsea=0.001*ext_data(qsea_file,qsea_name,tindex,lon,lat,time);
  dqdsst=get_dqdsst(sst,sat,airdens,w3,qsea);
  nc{'SST'}(tindex,:,:)=sst;
  nc{'dQdSST'}(tindex,:,:)=dqdsst;
end
for tindex=1:length(ssst)
  time=nc{'sss_time'}(tindex);
  nc{'SSS'}(tindex,:,:)=ext_data(sss_file,sss_name,tindex,...
                                 lon,lat,time);			 
end
for tindex=1:length(srft)
  time=nc{'srf_time'}(tindex);
  nc{'swrad'}(tindex,:,:)=ext_data(srf_file,srf_name,tindex,...
                                  lon,lat,time);
end
close(nc)
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
test_forcing(frcname,grdname,'spd',[1 4 7 10],3)
figure
test_forcing(frcname,grdname,'shflux',[1 4 7 10],3)
figure
test_forcing(frcname,grdname,'swflux',[1 4 7 10],3)
figure
test_forcing(frcname,grdname,'SST',[1 4 7 10],3)
figure
test_forcing(frcname,grdname,'SSS',[1 4 7 10],3)
figure
test_forcing(frcname,grdname,'dQdSST',[1 4 7 10],3)
figure
test_forcing(frcname,grdname,'swrad',[1 4 7 10],3)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
