function levitus_to_roms( grid, levitus, outfile, epoch )

%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin < 3)
  error('you must specify a grid, levitus structure, and output file');
end
if (nargin < 4)
  epoch=datenum(1900,1,1);
end

try
vars={'temp' 'salt'};
% First, create the initialization file
clim_write(grid,outfile,vars,4);

% Make sure we have a file
if (~exist(outfile,'file'))
  error([outfile ' could not be created']);
end

% Grab the region of interest
llon=nc_varget(char(levitus.file(1)),'lon');
llat=nc_varget(char(levitus.file(1)),'lat');
ldepth=-nc_varget(char(levitus.file(1)),'depth');
ltime=nc_varget(char(levitus.file(1)),'time');

% See if our grid uses + or - longitudes
if ( ~isempty(find(grid.lonr<0)) )
  l=find(llon>180);
  llon(l)=llon(l)-360;
end

% Go over each variable and create the data
for v=1:length(vars),
  var=char(vars(v));
  svar=char(levitus.var(v));
  disp(var);
  inidat  = nc_varget(outfile,var);
  for t=1:length(ltime),
    % First, handle the horizontal
    % Grab the subregion
    lon=grid.lonr;
    lat=grid.latr;
    gmask=grid.maskr;
    lon_list = find( llon > min(lon(:))-1 & ...
                     llon < max(lon(:))+1 );
    lat_list = find( llat > min(lat(:))-1 & ...)
                     llat < max(lat(:))+1 );
    [slon,slat]=meshgrid(llon(lon_list),llat(lat_list));
    lon_list = [lon_list(1)-1 length(lon_list)];
    lat_list = [lat_list(1)-1 length(lat_list)];
  
    clear newdat
    ldat = squeeze(nc_varget(char(levitus.file(v)),svar, ...
                        [t-1 0 lat_list(1) lon_list(1)], ...
                        [1 -1 lat_list(2) lon_list(2)]));
    ldat(isnan(ldat))=0;
    depths=grid_depth(grid,'r');
    for d=1:size(ldat,1),
      % Convolve the land
      smask = squeeze(ldat(d,:,:));
      smask(smask~=0)=1;
      oldlevel = squeeze(convolve_land( squeeze(ldat(d,:,:)), smask, 9));
      oldlevel(oldlevel==0)=nan;
      level = interp2(slon,slat,oldlevel,lon,lat,'cubic');
      level(isnan(level))=0;
      level(level<min(oldlevel(:)))=min(oldlevel(:));
      level(level>max(oldlevel(:)))=max(oldlevel(:));
      newdat(d,:,:) = level .* gmask;
    end
    % SLOW, now go to EACH point, and interpolate in the vertical. Because
    % ROMS uses terrain-following coords, we have to do this at each point
    % This must be done AFTER the horizontal because of the terrain-following
    % coordinates. A bummer.
    for i=1:size(inidat,3)*size(inidat,4),
      nd=newdat(:,i);
      nl=ldepth;
      i1 = find(-diff([0;nl]) > 0.01 & nd ~= 0);
      if (isempty(i1)) continue; end
      nl=nl(i1); nd=nd(i1);
      if ( nl(end) < -4000 ) 
        nd(end)=nanmean(nd(end-1:end));
      end
      nl = [0.; nl; depths(1,i)-1000]; nd = [nd(1); nd; nd(end)*0.1];
      inidat(t,:,i) = interp1(nl,nd,depths(:,i),'linear');
    end
  end
  ntime=360/size(inidat,1);
  ntime=[ntime-floor(ntime/2):ntime:360];
  nc_varput(outfile,[var '_time'],ntime);
  nc_varput(outfile,var,inidat);
end


catch
  err=lasterror;
  disp(['ERROR: ' err.message]);
  keyboard
end
