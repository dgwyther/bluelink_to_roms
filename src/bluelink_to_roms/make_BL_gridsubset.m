clear all; close all;

addpath(genpath('../ext/'))
addpath(genpath('../../conf/'))

opt = set_default_options()


grid=grid_read(opt.grid_path_roms);

hisfile=[opt.BRAN2020_path,'ocean_temp_mth_',num2str(opt.years(1)),'_01.nc'];

bldepth=nc_varget(opt.grid_path_branNative,'st_ocean');
bllat=nc_varget(opt.grid_path_branNative,'yt_ocean');
bllon=nc_varget(opt.grid_path_branNative,'xt_ocean');
lon_list = find( bllon >= min(grid.lonr(:))-0.2 & ...
                 bllon <= max(grid.lonr(:))+0.2 );
lat_list = find( bllat >= min(grid.latr(:)-0.2) & ...)
                 bllat <= max(grid.latr(:))+0.2 );
lons = bllon(lon_list);
lats = bllat(lat_list);

[slon,slat]=meshgrid(lons,lats);

dat=squeeze(nc_varget(hisfile,'temp',[0 0 0 0],[1 Inf Inf Inf]));

dat = dat(:,min(lat_list):max(lat_list),min(lon_list):max(lon_list));

% find the depths from where dat is nans
BLdepth=nan(size(dat,2),size(dat,3));
for i=1:size(dat,2)
 for j=1:size(dat,3)
col=dat(:,i,j);
ind=find(isnan(col));
 if isempty(ind)
   BLdepth(i,j)=bldepth(end);
 elseif length(ind)==length(bldepth)
   BLdepth(i,j)=nan;
 else
   BLdepth(i,j)=bldepth(ind(1)-1);
 end
 end
end

hgrid.name = opt.grid_path_bluelink;
hgrid.latr = slat;
hgrid.lonr = slon;
hgrid.h = -BLdepth;
hgrid.maskr = ones(size(slon));
hgrid.maskr(isnan(BLdepth))=0;
hgrid.n=grid.n;
hgrid.theta_s=grid.theta_s;
hgrid.theta_b=grid.theta_b;
hgrid.tcline=grid.tcline;
hgrid.hc=grid.hc;
ngrid=grid_write(hgrid);

