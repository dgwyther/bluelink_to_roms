function add_ini_chla(inifile,gridfile,seas_datafile,cycle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,chla]=add_ini_chla(inifile,gridfile,...
%                                             seas_datafile,...
%                                             cycle);
%
%  pierrick 2001
%
%  Add chlorophyll in a ROMS initial file.
%  take seasonal data for the surface levels and extrapole 
%  using Morel and Berthon (1989) parameterization for the
%  lower levels. warning ! the unit is (micro mole/l) in the
%  dataset.
%  do a temporal interpolation to have values at initial
%  time.
%
%  ref:  Morel and Berthon, Surface pigments, algal biomass
%        profiles, and potential production of the euphotic layer:
%        Relationships reinvestigated in view of remote-sensing 
%        applications. Limnol. Oceanogr., 34, 1989, 1545-1562.
%
%  input:
%    
%    inifile       : roms initial file to process (netcdf)
%    gridfile      : roms grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,chla] : surface field to plot (as an illustration)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('Add_ini_chla: creating variable and attribute')
ro=1e8;
default=NaN;
%
% read in the datafile 
%
ncseas=netcdf(seas_datafile);
x=ncseas{'X'}(:);
y=ncseas{'Y'}(:);
datatime=ncseas{'T'}(:);
datatime=datatime*30;  % !!! if the time in the dataset is in months !!!
tlen=length(datatime);
%
% open the grid file  
% 
%
% open the grid file  
% 
ng=netcdf(gridfile);
lon=ng{'lon_rho'}(:);
%lon(lon<0)=lon(lon<0)+360;
lat=ng{'lat_rho'}(:);
h=ng{'h'}(:);
close(ng);
[M,L]=size(lon);
dl=0.5;
minlon=min(min(lon))-dl;
maxlon=max(max(lon))+dl;
minlat=min(min(lat))-dl;
maxlat=max(max(lat))+dl;
imin=max(find(x<=minlon));
imax=min(find(x>=maxlon));
jmin=max(find(y<=minlat));
jmax=min(find(y>=maxlat));
x=x(imin:imax);
y=y(jmin:jmax);
%
% open the initial file  
% 
nc=netcdf(inifile,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
Tcline  =  nc{'Tcline'}(:);
N =  length(nc('s_rho'));
scrum_time = nc{'scrum_time'}(:);
scrum_time = scrum_time / (24*3600);
tinilen = length(scrum_time);
redef(nc);
nc{'CHLA'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'CHLA'}.long_name = ncchar('Chlorophyll');
nc{'CHLA'}.long_name = 'Chlorophyll';
nc{'CHLA'}.units = ncchar('mg C');
nc{'CHLA'}.units = 'mg C';
nc{'CHLA'}.fields = ncchar('CHLA, scalar, series');
nc{'CHLA'}.fields = 'CHLA, scalar, series';
%
endef(nc);
%
% Get the missing values
%
missval=ncseas{'chlorophyll'}.missing_value(:);
%
% loop on time
%
for l=1:tinilen
  disp(['time index: ',num2str(l),' of total: ',num2str(tinilen)])
%
%  get data time indices and weights for temporal interpolation
%
  if cycle~=0
    modeltime=mod(scrum_time(l),cycle);
  else
    modeltime=scrum_time;
  end
  l1=find(modeltime==datatime);
  if isempty(l1)
    disp('temporal interpolation')
    l1=max(find(datatime<modeltime));
    time1=datatime(l1);
    if isempty(l1)
      if cycle~=0
        l1=tlen;
        time1=datatime(l1)-cycle;
      else
        error('No previous time in the dataset')
      end
    end
    l2=min(find(datatime>modeltime));
    time2=datatime(l2);
    if isempty(l2)
      if cycle~=0
        l2=1;
        time2=datatime(l2)+cycle;
      else
        error('No posterious time in the dataset')
      end
    end
    cff1=(modeltime-time2)/(time1-time2);
    cff2=(time1-modeltime)/(time1-time2);
  else
    cff1=1;
    l2=l1;
    cff2=0;
  end
%
% interpole the annual dataset on the horizontal roms grid
%
  disp('Add_ini_chla: horizontal extrapolation of surface data')
  surfchla=squeeze(ncseas{'chlorophyll'}(l1,jmin:jmax,imin:imax));
  surfchla=get_missing_val(x,y,surfchla,missval,ro,default);
  surfchla2=squeeze(ncseas{'chlorophyll'}(l2,jmin:jmax,imin:imax));
  surfchla2=get_missing_val(x,y,surfchla2,missval,ro,default);
  surfchla=cff1*surfchla + cff2*surfchla2;
  surfchlaroms=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zeta = squeeze(nc{'zeta'}(l,:,:));
  zroms=zlevs(h,zeta,theta_s,theta_b,Tcline,N,'r');
  disp(['Add_ini_chla: vertical ',...
  'extrapolation of chlorophyll'])
  chlaroms=extr_chlo(surfchlaroms,zroms);
  nc{'CHLA'}(l,:,:,:)=chlaroms;
end
close(nc);
close(ncseas);
return
