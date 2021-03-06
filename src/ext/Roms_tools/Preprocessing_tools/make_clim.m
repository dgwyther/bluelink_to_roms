%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a ROMS climatology file
%
%  Extrapole and interpole temperature and salinity from a
%  Climatology to get boundary and initial conditions for
%  ROMS (climatology and initial netcdf files) .
%  Get the velocities and sea surface elevation via a 
%  geostrophic computation.
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
%
%  Pierrick Penven, IRD, 2002.
%
%  Version of 10-Oct-2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title 
%
title='Climatology';
%
%  Switches for selecting what to process (1=ON)
%
makeclim=1; %1: process boundary data
makeoa=1;   %1: process oa data
makeini=1;  %1: process initial data
%
%  Grid file name - Climatology file name
%  Initial file name - OA file name
%
grdname='roms_grd.nc';
frcname='roms_frc.nc';
clmname='roms_clm.nc';
ininame='roms_ini.nc';
oaname ='roms_oa.nc';
%
%  Vertical grid parameters
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!   THESE MUST IDENTICAL IN THE .IN FILE   !!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
theta_s=7.;
theta_b=0.;
hc=5.;
N=20; % number of vertical levels (rho)
%
%  Open boundaries switches
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!   MUST BE CONFORM TO THE CPP SWITCHES    !!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
obc=[1 0 1 1]; % open boundaries (1=open , [S E N W])
%
%  Level of reference for geostrophy calculation
%
zref=-500; 
%
%  Day of initialisation
%
tini=15;  
%
% Set times and cycles: monthly climatology for all data
%
time=[15:30:345];    % time 
cycle=360;           % cycle 
%
%  Data climatologies file names:
%
%    temp_month_data : monthly temperature climatology
%    temp_ann_data   : annual temperature climatology
%    salt_month_data : monthly salinity climatology
%    salt_ann_data   : annual salinity climatology
%
temp_month_data='../WOA2001/temp_month.cdf';
temp_ann_data='../WOA2001/temp_ann.cdf';
insitu2pot=1;   %1: transform in-situ temperature to potential temperature
salt_month_data='../WOA2001/salt_month.cdf';
salt_ann_data='../WOA2001/salt_ann.cdf';
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making the clim: ',clmname])
disp(' ')
disp([' Title: ',title])
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
nc=netcdf(grdname);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
hmax=max(max(nc{'h'}(:)));
result=close(nc);
%
% Create the climatology file
%
if (makeclim)
  disp(' ')
  disp(' Create the climatology file...')
  create_climfile(clmname,grdname,title,...
                  theta_s,theta_b,hc,N,...
                  time,cycle,'clobber');
end
%
% Create the OA file
%
if (makeoa)
  disp(' ')
  disp(' Create the OA file...')
  nc=netcdf(temp_ann_data);
  Z=nc{'Z'}(:);
  kmax=max(find(Z<hmax))-1;
  Z=Z(1:kmax);
  close(nc)
  create_oafile(oaname,grdname,title,Z,...
                time,cycle,'clobber');
%
% Horizontal extrapolations 
%
  disp(' ')
  disp(' Horizontal extrapolations')
  disp(' ')
  disp(' Temperature...')
  ext_tracers(oaname,temp_month_data,temp_ann_data,...
              'temperature','temp','tclm_time','Z');
  disp(' ')
  disp(' Salinity...')
  ext_tracers(oaname,salt_month_data,salt_ann_data,...
              'salinity','salt','sclm_time','Z');
end
%
% Vertical interpolations 
%
if (makeclim)
  disp(' ')
  disp(' Vertical interpolations')
  disp(' ')
  disp(' Temperature...')
  vinterp_clm(clmname,grdname,oaname,'temp','tclm_time','Z',0,'r');
  disp(' ')
  disp(' Salinity...')
  vinterp_clm(clmname,grdname,oaname,'salt','sclm_time','Z',0,'r');
  if (insitu2pot)
    disp(' ')
    disp(' Compute potential temperature from in-situ...')
    getpot(clmname,grdname)
  end
%
% Geostrophy
%
  disp(' ')
  disp(' Compute geostrophic currents')
  geost_currents(clmname,grdname,oaname,frcname,zref,obc,0)
end
%
% Initial file
%
if (makeini)
  disp(' ')
  disp(' Initial')
  create_inifile(ininame,grdname,title,...
                 theta_s,theta_b,hc,N,...
                 tini,'clobber');
  disp(' ')
  disp(' Temperature...')
  vinterp_clm(ininame,grdname,oaname,'temp','tclm_time','Z',tini,'r');
  disp(' ')
  disp(' Salinity...')
  vinterp_clm(ininame,grdname,oaname,'salt','sclm_time','Z',tini,'r');
  if (insitu2pot)
    disp(' ')
    disp(' Compute potential temperature from in-situ...')
    getpot(ininame,grdname)
  end
end		 
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
test_clim(clmname,grdname,'temp',1)
figure
test_clim(clmname,grdname,'salt',1)
figure
test_clim(clmname,grdname,'temp',6)
figure
test_clim(clmname,grdname,'salt',6)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
