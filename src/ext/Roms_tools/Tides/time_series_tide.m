function time_series_tide(gname,fname,lon0,lat0,Z0,Ntides)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     h(t,x) = h(x) cos [w (t - t0) + V0(t0)]
%
% where V0(t0) is the astronomical argument for the constituent at t0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear all; 
%close all;
%fname='/home/penven/Roms_tools/Run/roms_frc.nc';
%gname='/home/penven/Roms_tools/Run/roms_grd.nc';
PLOT_GAUGE=0;
%gauge_file='toto.dat';
%lat0=33.93; lon0=-118.71; % UCLA Mooring
%lat0=48.42; lon0=-4.60;   % Brest Harbour
%lat0=47.35; lon0=-3.13;   % BELLE-ILE_(LE_PALAIS)
%Z0=4; % Mean depth of the maregraphe
%Ntides=10;
%
% set time array
%
year=2000;
month=6;
day=1;
ndays = 7;                 % nb of days
res   = 24;                 % nb points a day
time0 = mjd(year,month,day);   
T    = res*ndays;
jul_off = 0;
for i=1:T;
  time(i)=time0+i/res;
end;  
%
% Read ROMS grid
%
nc=netcdf(gname);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
close(nc);
%
% Find j,i indices
%
[J,I]=find((lat(1:end-1,1:end-1)<lat0 & lat(2:end,2:end)>lat0 &...
            lon(2:end,1:end-1)<lon0 & lon(1:end-1,2:end)>lon0)==1);
disp(['I = ',int2str(I),' J = ',int2str(J)])
lon1=lon(J,I);
lat1=lat(J,I);
disp(['lon1 = ',num2str(lon1),' lat1 = ',num2str(lat1)])
%
% Read the tide
%
nc=netcdf(fname);
Tperiod=squeeze(nc{'tide_period'}(:,J,I)./24);     % days
Ephase =squeeze(nc{'tide_Ephase'}(:,J,I)*pi/180);  % deg
Eamp   =squeeze(nc{'tide_Eamp'}(:,J,I));           % m
cmpt=nc.components(:);
close(nc);
Nmax=length(Eamp); 
Ntides=min([Nmax Ntides]);
for i=1:Ntides
  components(3*i-2:3*i)=[cmpt(3*i-2:3*i-1),' '];
end
disp(['Ntides = ',num2str(Ntides)])
disp(['Tidal components : ',components])
%
% Compute the tides
%
ssh=Z0+0*(1:T);
for itime=1:T
  for itide=1:Ntides
    omega=2*pi/Tperiod(itide)*(time(itime)-jul_off); 
    ssh(itime)=ssh(itime) + ...
                   Eamp(itide).*cos(omega - Ephase(itide));
  end
end
%
% Get the Data
%
if PLOT_GAUGE
  tides=load(gauge_file) 
  y_data=tides(:,1);
  m_data=tides(:,2);
  d_data=tides(:,3);
  h_data=tides(:,4);
  mn_data=tides(:,5);
  ssh_data=tides(:,6)-.9;
  time_data=mjd(y_data,m_data,d_data,h_data);
end
%
% Plot
%
figure
time_m=time-time0;
a=plot(time_m,ssh,'r'); 
hold on;
if PLOT_GAUGE
  time_d=time_data-time0;
  b=plot(time_d,ssh_data,'b'); 
  legend([a b],'TPXO','Tidal Gauge');
end
hold off;
axis([time_m(1) time_m(T) 0 8]);
dX=1;
Xtime=[0:dX:ndays];
for i=1:length(Xtime)
  date=mjd2greg(Xtime(i)+time0);
%  mydate(i,1:length(date))=date;
  mydate(i,1:6)=date(1:6);

end
%set(gca,'Xtick',Xtime,'XtickLabel',mydate,'FontSize',7)
set(gca,'Xtick',Xtime,'XtickLabel',Xtime,'FontSize',7)
ylabel('Sea level [m]')
xlabel('Days since initialisation')

grid on
