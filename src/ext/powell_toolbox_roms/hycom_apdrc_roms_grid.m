function grid=hycom_roms_grid(grid,filename)

% Given a ROMS gridfile, extract the region in HYCOM, and construct a 
% pseudo-ROMS grid file for HYCOM data. 
% This will be used for interpolation later.

% url='http://tds.hycom.org/thredds/dodsC/GLBa0.08/expt_90.6/2009?%s';
% url='http://tds.hycom.org/thredds/dodsC/GLBa0.08/expt_90.8/2011?%s';
url='http://apdrc.soest.hawaii.edu:80/dods/public_data/Model_output/HYCOM/hycom_ncoda_hawaii_0.08';
hycomfile=url;
hycomlat=nc_varget(hycomfile,'lat');
hycomlat=hycomlat(:,1);
hycomlon=nc_varget(hycomfile,'lon');
l=find(hycomlon>360);
hycomlon(l)=hycomlon(l)-hycomlon(1);
hycomdepth=-nc_varget(hycomfile,'lev');
% Are we crossing Greenwich?
gwhich=[];
if ( min(grid.lonr(:))<0 & max(grid.lonr(:))>0 )
  gwhich=find(grid.lonr<0);
  grid.lonr(gwhich)=grid.lonr(gwhich)+360;
end
% See if our grid uses + or - longitudes
if ( ~isempty(find(grid.lonr<0)) )
  l=find(hycomlon>180);
  hycomlon(l)=hycomlon(l)-360;
end
lon_list = find( hycomlon > min(grid.lonr(:))-0.2 & ...
                 hycomlon < max(grid.lonr(:))+0.2 );
lat_list = find( hycomlat > min(grid.latr(:))-0.2 & ...)
                 hycomlat < max(grid.latr(:))+0.2 );
[slon,slat]=meshgrid(hycomlon(lon_list),hycomlat(lat_list));

lon_list = [lon_list(1)-1 length(lon_list)];
lat_list = [lat_list(1)-1 length(lat_list)];
hycomfile=sprintf(url,'temp');
hycomdat = squeeze(nanmean(nc_varget(hycomfile,'temp', ...
                    [0 0 lat_list(1) lon_list(1)], ...
                    [1 -1 lat_list(2) lon_list(2)])));
if ( ~isempty(gwhich) )
  % We need to put everything into the new coordinate system
  grid.lonr(gwhich)=grid.lonr(gwhich)-360;
  l=find(slon>180);
  slon(l)=slon(l)-360;
  lon_list=find( slon(1,:) >= min(grid.lonr(:))-0.2 &  ...
                 slon(1,:) <= max(grid.lonr(:))+0.2 );
  lat_list=find( slat(:,1) >= min(grid.latr(:))-0.2 &  ...
                 slat(:,1) <= max(grid.latr(:))+0.2 );
  [nlon,i]=sort(slon(1,lon_list));
  lon_list=lon_list(i);
  [nlat,i]=sort(slat(lat_list,1));
  lat_list=lat_list(i);
  [slon,slat]=meshgrid(nlon,nlat);
  hycomdat=hycomdat(:,lat_list,lon_list);
end
hycomgridd=ones(size(hycomdat,2),size(hycomdat,3))*min(hycomdepth);
for d=1:length(hycomdepth),
  l=find(isnan(hycomdat(d,:)));
  if (~isempty(l))
    hycomgridd(l)=max(hycomgridd(l),hycomdepth(max(d-1,1)));
  end
end

hgrid.name = filename;
hgrid.latr = slat;
hgrid.lonr = slon;
hgrid.h = -hycomgridd;
hgrid.maskr = ones(size(slon));
hgrid.maskr(isnan(hycomdat(1,:,:)))=0;
hgrid.n=grid.n;
hgrid.theta_s=grid.theta_s;
hgrid.theta_b=grid.theta_b;
hgrid.tcline=grid.tcline;
hgrid.hc=grid.hc;
grid=grid_write(hgrid);
