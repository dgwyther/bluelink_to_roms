function ext_tracers(oaname,seas_datafile,ann_datafile,...
                      dataname,vname,tname,zname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  pierrick 2002
%
%  Ext tracers in a ROMS climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    oaname      : roms oa file to process (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
%
% set the value of ro (oa decorrelation scale [m]) 
% and default (value if no data)
%
ro=1e8;
default=NaN;
disp([' Ext tracers: ro = ',num2str(ro/1000),...
      ' km - default value = ',num2str(default)])
%
% Open and Read the grid file  
% 
ng=netcdf(oaname);
lon=ng{'lon_rho'}(:);
lat=ng{'lat_rho'}(:);
close(ng);
[M,L]=size(lon);
%
%
%
dl=1;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Read in the datafile 
%
ncseas=netcdf(seas_datafile);
X=ncseas{'X'}(:);
Y=ncseas{'Y'}(:);
Zseas=-ncseas{'Z'}(:);
T=ncseas{'T'}(:);
tlen=length(T);
Nzseas=length(Zseas);
%
% get a subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
x=cat(1,X(i1)-360,X(i2),X(i3)+360);
y=Y(j);
%
% Open the OA file  
% 
nc=netcdf(oaname,'write');
Z=-nc{zname}(:);
Nz=length(Z);
%
% Check the time
%
tclim=nc{tname}(:); 
T=T*30; % if time in month in the dataset !!!
if (tclim~=T)
  error(['time mismatch  tclim = ',num2str(tclim),...
         '  t = ',num2str(T)])
end
%
% Read the annual dataset
%
if Nz > Nzseas
  ncann=netcdf(ann_datafile);
  zann=-ncann{'Z'}(1:Nz);
  if (Z~=zann)
    error('Vertical levels mismatch')
  end
%
% Interpole the annual dataset on the horizontal ROMS grid
%
  disp(' Ext tracers: horizontal interpolation of the annual data')
  if Zseas~=zann(1:length(Zseas)) 
    error('vertical levels dont match')
  end
  datazgrid=zeros(Nz,M,L);
  missval=ncann{dataname}.missing_value(:);
  for k=Nzseas+1:Nz
    if ~isempty(i2)
      data=squeeze(ncann{dataname}(k,j,i2));
    else
      data=[];
    end
    if ~isempty(i1)
      data=cat(2,squeeze(ncann{dataname}(k,j,i1)),data);
    end
    if ~isempty(i3)
      data=cat(2,data,squeeze(ncann{dataname}(k,j,i3)));
    end
    data=get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
  close(ncann);
end
%
% interpole the seasonal dataset on the horizontal roms grid
%
disp([' Ext tracers: horizontal interpolation of the seasonal data'])
%
% loop on time
%
missval=ncseas{dataname}.missing_value(:);
for l=1:tlen
%for l=1:1
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  if Nz <= Nzseas
    datazgrid=zeros(Nz,M,L);
  end
  for k=1:min([Nz Nzseas])
    if ~isempty(i2)
      data=squeeze(ncseas{dataname}(l,k,j,i2));
    else
      data=[];
    end
    if ~isempty(i1)
      data=cat(2,squeeze(ncseas{dataname}(l,k,j,i1)),data);
    end
    if ~isempty(i3)
      data=cat(2,data,squeeze(ncseas{dataname}(l,k,j,i3)));
    end
    data=get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
  nc{vname}(l,:,:,:)=datazgrid;
end
close(nc);
close(ncseas);
return
