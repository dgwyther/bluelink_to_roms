function grid=soda_roms_grid(grid,filename)

% Given a ROMS gridfile, extract the region in SODA, and construct a 
% pseudo-ROMS grid file for SODA data. 
% This will be used for interpolation later.

% url='http://iridl.ldeo.columbia.edu/SOURCES/.CARTON-GIESE/.SODA/.v2p0p2-4/.%s/dods';
url='http://apdrc.soest.hawaii.edu:80/dods/public_data/SODA/soda_pop2.2.4';
sodafile=sprintf(url,'temp');
sodalon=nc_varget(sodafile,'lon');
sodalat=nc_varget(sodafile,'lat');
% sodadepth=-nc_varget(sodafile,'depth');
sodadepth=-nc_varget(sodafile,'lev');
% sodatime=datenum(1960,1+nc_varget(sodafile,'time'),1);
sodatime=datenum(1,1,1)+nc_varget(sodafile,'time')-2;
% Are we crossing Greenwich?
gwhich=[];
if ( min(grid.lonr(:))<0 & max(grid.lonr(:))>0 )
  gwhich=find(grid.lonr<0);
  grid.lonr(gwhich)=grid.lonr(gwhich)+360;
end
% See if our grid uses + or - longitudes
if ( ~isempty(find(grid.lonr<0)) )
  l=find(sodalon>180);
  sodalon(l)=sodalon(l)-360;
end
lon_list = find( sodalon >= min(grid.lonr(:))-0.5 & ...
                 sodalon <= max(grid.lonr(:))+0.5 );
lat_list = find( sodalat >= min(grid.latr(:))-0.5 & ...)
                 sodalat <= max(grid.latr(:))+0.5 );
[slon,slat]=meshgrid(sodalon(lon_list),sodalat(lat_list));
lon_list = [lon_list(1)-1 length(lon_list)];
lat_list = [lat_list(1)-1 length(lat_list)];
sodadat = squeeze(nc_varget(sodafile,'temp', ...
                    [0 0 lat_list(1) lon_list(1)], ...
                    [1 -1 lat_list(2) lon_list(2)]));
if ( ~isempty(gwhich) )
  % We need to put everything into the new coordinate system
  grid.lonr(gwhich)=grid.lonr(gwhich)-360;
  l=find(slon>180);
  slon(l)=slon(l)-360;
  lon_list=find( slon(1,:) >= min(grid.lonr(:))-0.5 &  ...
                 slon(1,:) <= max(grid.lonr(:))+0.5 );
  lat_list=find( slat(:,1) >= min(grid.latr(:))-0.5 &  ...
                 slat(:,1) <= max(grid.latr(:))+0.5 );
  [nlon,i]=sort(slon(1,lon_list));
  lon_list=lon_list(i);
  [nlat,i]=sort(slat(lat_list,1));
  lat_list=lat_list(i);
  [slon,slat]=meshgrid(nlon,nlat);
  sodadat=sodadat(:,lat_list,lon_list);
end
sodagridd=ones(size(sodadat,2),size(sodadat,3))*min(sodadepth);
for d=1:length(sodadepth),
  l=find(isnan(sodadat(d,:)));
  if (~isempty(l))
    sodagridd(l)=max(sodagridd(l),sodadepth(max(d-1,1)));
  end
end

hgrid.name = filename;
hgrid.latr = slat;
hgrid.lonr = slon;
hgrid.h = -sodagridd;
hgrid.maskr = ones(size(slon));
hgrid.maskr(isnan(sodadat(1,:,:)))=0;
hgrid.n=grid.n;
hgrid.theta_s=grid.theta_s;
hgrid.theta_b=grid.theta_b;
hgrid.tcline=grid.tcline;
hgrid.hc=grid.hc;
grid=grid_write(hgrid);
