function grid=ncom_roms_grid(grid, filename)

% Given a ROMS gridfile, extract the region in NCOM, and construct a 
% pseudo-ROMS grid file for NCOM data. 
% This will be used for interpolation later.

url='http://powellb:beach_pier@apdrc.soest.hawaii.edu:80/dods/nrl_only/NCOM/%s';
ncomfile=sprintf(url,'ncom_temperature');
ncomlat=nc_varget(ncomfile,'lat');

ncomlon=nc_varget(ncomfile,'lon');
ncomdepth=-nc_varget(ncomfile,'lev');
% See if our grid uses + or - longitudes
% See if our grid uses + or - longitudes
if ( ~isempty(find(grid.lonr<0)) )
  l=find(ncomlon>180);
  ncomlon(l)=ncomlon(l)-360;
end
lon_list = find( ncomlon >= min(grid.lonr(:))-0.2 & ...
                 ncomlon <= max(grid.lonr(:))+0.2 );
lat_list = find( ncomlat >= min(grid.latr(:))-0.2 & ...)
                 ncomlat <= max(grid.latr(:))+0.2 );
[slon,slat]=meshgrid(ncomlon(lon_list),ncomlat(lat_list));
lon_list = [lon_list(1)-1 length(lon_list)];
lat_list = [lat_list(1)-1 length(lat_list)];
ncomdat = squeeze(nanmean(nc_varget(ncomfile,'temp',...
                      [0 0 lat_list(1) lon_list(1)], ...
                      [1 -1 lat_list(2) lon_list(2)])));
ncomgridd=ones(size(ncomdat,2),size(ncomdat,3))*min(ncomdepth);
for d=1:length(ncomdepth),
  l=find(isnan(ncomdat(d,:)));
  if (~isempty(l))
    ncomgridd(l)=max(ncomgridd(l),ncomdepth(max(d-1,1)));
  end
end

ngrid.name = filename;
ngrid.latr = slat;
ngrid.lonr = slon;
ngrid.h = -ncomgridd;
ngrid.maskr = ones(size(slon));
ngrid.maskr(isnan(ncomdat(1,:,:)))=0;
ngrid.n=grid.n;
ngrid.theta_s=grid.theta_s;
ngrid.theta_b=grid.theta_b;
ngrid.tcline=grid.tcline;
ngrid.hc=grid.hc;
grid=grid_write(ngrid);
