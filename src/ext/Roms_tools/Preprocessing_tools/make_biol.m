clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a ROMS climatology file
%
%  Extrapole and interpole bioi
%
%  Data source : IRI/LDEO Climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA2001/
%
%  Pierrick Penven, IRD, 2003.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
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
clmname='roms_clm.nc';
ininame='roms_ini.nc';
oaname ='roms_oa.nc';
%
%  Day of initialisation
%
tini=15;  
%
% Set times and cycles: monthly climatology for all data
%
cycle=360;           % cycle 
%
%  Data climatologies file names:
%
%    no3_seas_data : seasonal NO3 climatology
%    no3_ann_data  : annual NO3 climatology
%    chla_seas_data : seasonal Chlorophylle climatology
%
no3_seas_data='../WOA2001/no3_seas.cdf';
no3_ann_data='../WOA2001/no3_ann.cdf';
chla_seas_data='../WOA2001/chla_seas.cdf';
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Add variables in the files
%
add_no3(oaname,clmname,ininame,grdname,no3_seas_data,...
        no3_ann_data,cycle,makeoa,makeclim)
%
% Horizontal extrapolation of NO3
%
if (makeoa)
  ext_tracers(oaname,no3_seas_data,no3_ann_data,...
              'nitrate','NO3','no3_time','Zno3');
end
%
% Vertical interpolations 
%
if (makeclim)
  disp(' ')
  disp(' Vertical interpolations')
  disp(' ')
  disp(' NO3...')
  vinterp_clm(clmname,grdname,oaname,'NO3','no3_time','Zno3',0,'r');
%
%  CHla
%		 
  disp(' ')
  disp(' CHla...')
  add_chla(clmname,grdname,chla_seas_data,cycle);
%
%  Phyto
%		 
  disp(' ')
  disp(' Phyto...')
  add_phyto(clmname);
end
%
% Initial file
%
if (makeini)
  disp(' ')
  disp(' Initial')
  disp(' ')
  disp(' NO3...')
  add_ini_no3(ininame,grdname,oaname,cycle);
%
%  CHla
%		 
  disp(' ')
  disp(' CHla...')
  add_ini_chla(ininame,grdname,chla_seas_data,cycle);
%
%  Phyto
%		 
  disp(' ')
  disp(' Phyto...')
  add_ini_phyto(ininame);
end
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
test_clim(clmname,grdname,'NO3',1)
figure
test_clim(clmname,grdname,'CHLA',1)
figure
test_clim(clmname,grdname,'PHYTO',1)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











