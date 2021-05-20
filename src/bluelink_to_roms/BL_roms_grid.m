function ngrid=BL_roms_grid(grid,newgridname,hisfile)

% Given a ROMS gridfile, extract the region in BlueLink, and construct a 
% pseudo-ROMS grid file for BlueLink data. 
% This will be used for interpolation later.

% takes any history file that has already been created by bluelink_load_his as input

%grid=grid_read('/home/z3097808/eac/grid/EACouter_varres_grd_mergedBLbry.nc')
%hisfile='/srv/scratch/z3097808/bluelink/EAC_BRAN_his_2002.nc';
%newgridname='EACouter_BL_grid.nc';


lat=nc_varget(hisfile,'lat');
lon=nc_varget(hisfile,'lon');
depth=nc_varget(hisfile,'depth');
[slon,slat]=meshgrid(lon,lat);
dat=squeeze(nc_varget(hisfile,'temp',[0 0 0 0],[1 -1 -1 -1]));

% find the depths from where dat is nans
BLdepth=nan(size(dat,2),size(dat,3));
for i=1:size(dat,2)
 for j=1:size(dat,3)
col=dat(:,i,j);
ind=find(isnan(col));
 if isempty(ind)
   BLdepth(i,j)=depth(end);
 elseif length(ind)==length(depth)
   BLdepth(i,j)=nan;
 else
   BLdepth(i,j)=depth(ind(1)-1);
 end
 end
end

hgrid.name = newgridname;
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
