function bad_list = soda_load_his( grid, hisfile, histime, epoch )

%
% Created by Brian Powell on 2008-12-29.
% Copyright (c)  powellb. All rights reserved.
%

vars={'zeta' 'u' 'v' 'temp' 'salt'};
dims=[3 4 4 4 4];
soda={'ssh' 'u' 'v' 'temp' 'salt'};
% url='http://iridl.ldeo.columbia.edu/SOURCES/.CARTON-GIESE/.SODA/.v2p0p2-4/.%s/dods';
url='http://apdrc.soest.hawaii.edu:80/dods/public_data/SODA/soda_pop2.2.4';

if (nargin < 4)
  epoch=datenum(1900,1,1);
end
if (nargin < 3)
  error('you must specify a grid, name of history file, time period, epoch');
end
if (length(histime)<2)
  error('You must specify a starting and ending time ([start end]).');
end

% Time records
time=[histime(1):histime(2)];

% Grab the region of interest
sodafile=sprintf(url,'temp');
sodalon=nc_varget(sodafile,'lon');
sodalat=nc_varget(sodafile,'lat');
% sodadepth=nc_varget(sodafile,'depth');
sodadepth=nc_varget(sodafile,'lev');
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

% Look for the correct time period
timelist = find(sodatime >= histime(1) & sodatime <= histime(2));
if ( isempty(timelist) )
  error('no times could be found in soda');
end

lon_list = find( sodalon >= min(grid.lonr(:)) & ...
                 sodalon <= max(grid.lonr(:)) );
lat_list = find( sodalat >= min(grid.latr(:)) & ...)
                 sodalat <= max(grid.latr(:)) );
zgrid.lon = sodalon(lon_list);
zgrid.lat = sodalat(lat_list);
[slon,slat]=meshgrid(zgrid.lon,zgrid.lat);
lon_list = [lon_list(1)-1 length(lon_list)];
lat_list = [lat_list(1)-1 length(lat_list)];
zgrid.time = sodatime(timelist) - epoch;
zgrid.depth = sodadepth;
if ( ~isempty(gwhich) )
  % We need to put everything into the new coordinate system
  grid.lonr(gwhich)=grid.lonr(gwhich)-360;
  l=find(slon>180);
  slon(l)=slon(l)-360;
  lnlist=find( slon(1,:) >= min(grid.lonr(:)) &  ...
               slon(1,:) <= max(grid.lonr(:)) );
  ltlist=find( slat(:,1) >= min(grid.latr(:)) &  ...
               slat(:,1) <= max(grid.latr(:)) );
  [nlon,i]=sort(slon(1,lnlist));
  lnlist=lnlist(i);
  [nlat,i]=sort(slat(ltlist,1));
  ltlist=ltlist(i);
  [slon,slat]=meshgrid(nlon,nlat);
  zgrid.lon = nlon;
  zgrid.lat = nlat;
end

% First, create the history file
if (~exist(hisfile,'file'))
  disp(['create history file: ' hisfile]);
  zgrid_write(zgrid,hisfile,epoch);
  % Fill it with zeros
  rec.zeta = nan([1 size(slon)]);
  rec.u    = nan([1 length(sodadepth) size(slon)]);
  rec.v    = nan([1 length(sodadepth) size(slon)]);
  rec.temp = nan([1 length(sodadepth) size(slon)]);
  rec.salt = nan([1 length(sodadepth) size(slon)]);
  progress(0,0,1);
  for t=1:length(timelist),
    progress(length(timelist),t,1);
    rec.time=sodatime(timelist(t))-epoch;
    nc_addnewrecs(hisfile,rec,'time');
  end
end

for v=1:length(vars),
  var=char(vars(v));
  svar=char(soda(v));
  disp(svar);
  sodafile=sprintf(url,svar);

  % First, find all empty records
  if ( dims(v) == 3 )
    curdat = nc_varget(hisfile,var);
  else
    curdat = squeeze(nc_varget(hisfile,var,[0 0 0 0], [-1 1 -1 -1]));
  end
  curdat = reshape(curdat,[size(curdat,1) size(curdat,2)*size(curdat,3)]);
  curdat = nanmean(curdat,2);
  list = find(isnan(curdat) | curdat > 1e30);
  if ( isempty(list) ) continue; end
  
  progress(0,0,1);
  for t=1:length(list),
    progress(length(list),t,1);
    try 
      if ( dims(v) == 3 )
        sodadat = nc_varget(sodafile, svar, ...
                   [timelist(list(t))-1 lat_list(1) lon_list(1)], ...
                   [1 lat_list(2) lon_list(2)]);
        if ( ~isempty(gwhich) )
          sodadat=sodadat(:,ltlist,lnlist);
        end
        nc_varput(hisfile,var,sodadat,[list(t)-1 0 0],size(sodadat))
      else
        sodadat = nc_varget(sodafile,svar, ...
                        [timelist(list(t))-1 0 lat_list(1) lon_list(1)], ...
                        [1 -1 lat_list(2) lon_list(2)]);
        if ( ~isempty(gwhich) )
          sodadat=sodadat(:,:,ltlist,lnlist);
        end
        nc_varput(hisfile,var,sodadat,[list(t)-1 0 0 0],size(sodadat))
      end
    catch
      fprintf(1,'X');
      continue;
    end
  end
end
