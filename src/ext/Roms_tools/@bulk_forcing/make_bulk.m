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
%  Patrick Marchesiello, Pierrick Penven, IRD, 2004.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title - Grid file name - Forcing file name
%
title=['Bulk Forcing (COADS)'];
grdname='roms_grd.nc';
frcname='roms_bulk.nc';
%
bulkt = (15:30:345);  % time [days]
bulkc = 360;          % cycle [days]
as_consts             % load air-sea parameters

%    sat      : Surface atmospheric temperature
%    airdens  : Surface atmospheric density
%    w3       : Wind speed at 10 meters
%    qsea     : Sea level specific humidity
%    rh       : relative humidity
%    precip   : precipitation rate
%    shortrad : Short wave radiation 
%    longrade : Outgoing long wave radiation

sat_file     ='../COADS05/sat.cdf';
sat_name     ='sat';
airdens_file ='../COADS05/airdens.cdf';
airdens_name ='airdens';
w3_file      ='../COADS05/w3.cdf';
w3_name      ='w3';
qsea_file    ='../COADS05/qsea.cdf';
qsea_name    ='qsea';
rh_file      ='../COADS05/rh.cdf';
rh_name      ='rh';
precip_file  ='../COADS05/precip.cdf';
precip_name  ='precip';
srf_file     ='../COADS05/shortrad.cdf';
srf_name     ='shortrad';
lrf_file     ='../COADS05/longrad.cdf';
lrf_name     ='longrad';
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
result=close(nc);
%
% Create the forcing file
%
disp(' ')
disp(' Create the bulk forcing file...')
create_bulk(frcname,grdname,title,bulkt,bulkc);
%
% Loop on time
%
nc=netcdf(frcname,'write');
for tindex=1:length(bulkt)
  time=nc{'bulk_time'}(tindex);
  nc{'tair'}(tindex,:,:) = ext_data(sat_file,sat_name,tindex,...
                                        lon,lat,time);
%        percent -> fraction
  nc{'rhum'}(tindex,:,:) = 0.01*ext_data(rh_file,rh_name,tindex,...
                                        lon,lat,time);
%        mm/(3hour) -> centimeter day-1 
  nc{'prate'}(tindex,:,:)= 0.8*ext_data(precip_file,precip_name,tindex,...
                                        lon,lat,time);
  nc{'wspd'}(tindex,:,:) = ext_data(w3_file,w3_name,tindex,...
                                        lon,lat,time);
  nc{'radlw'}(tindex,:,:)= ext_data(lrf_file,lrf_name,tindex,...
                                        lon,lat,time);
  nc{'radsw'}(tindex,:,:)= ext_data(srf_file,srf_name,tindex,...
                                        lon,lat,time);
%  nc{'airdens'}(tindex,:,:)= ...
%            ext_data(airdens_file,airdens_name,tindex,lon,lat,time);
%  nc{'shum'}(tindex,:,:)= ...
%            0.001*ext_data(qsea_file,qsea_name,tindex,lon,lat,time);
end
close(nc)
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
test_bulk(frcname,grdname,'tair',[1 4 7 10],3)
figure
test_bulk(frcname,grdname,'rhum',[1 4 7 10],3)
figure
test_bulk(frcname,grdname,'prate',[1 4 7 10],3)
figure
test_bulk(frcname,grdname,'wspd',[1 4 7 10],3)
figure
test_bulk(frcname,grdname,'radlw',[1 4 7 10],3)
figure
test_bulk(frcname,grdname,'radsw',[1 4 7 10],3)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
