function bad_list = ncom_load_his( grid, hisfile, histime, epoch )

% LOAD NCOM HISTORY DATA FROM AN NCOM GRID FILE
%
% Created by Brian Powell on 2008-12-29.
% Copyright (c)  powellb. All rights reserved.
%

vars={'zeta' 'u' 'v' 'temp' 'salt'};
dims=[3 4 4 4 4];
ncom={'ssh' 'uvel' 'vvel' 'temp' 'salt'};
files={'ncom_ssh' 'ncom_u' 'ncom_v' 'ncom_temperature' 'ncom_salinity'};
url='http://powellb:beach_pier@apdrc.soest.hawaii.edu:80/dods/nrl_only/NCOM/%s';

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
ncomfile=sprintf(url,'ncom_temperature');
ncomlat=nc_varget(ncomfile,'lat');
ncomlon=nc_varget(ncomfile,'lon');
ncomdepth=nc_varget(ncomfile,'lev');
ncomtime=nc_varget(ncomfile,'time')+365;

% See if our grid uses + or - longitudes
if ( ~isempty(find(grid.lonr<0)) )
  l=find(ncomlon>180);
  ncomlon(l)=ncomlon(l)-360;
end

% Look for the correct time period
timelist = find(ncomtime >= histime(1) & ncomtime <= histime(2));
if ( isempty(timelist) )
  error('no times could be found in ncom');
end

lon_list = find( ncomlon >= min(grid.lonr(:)) & ...
                 ncomlon <= max(grid.lonr(:)) );
lat_list = find( ncomlat >= min(grid.latr(:)) & ...)
                 ncomlat <= max(grid.latr(:)) );
zgrid.lon = ncomlon(lon_list);
zgrid.lat = ncomlat(lat_list);
[slon,slat]=meshgrid(zgrid.lon,zgrid.lat);
lon_list = [lon_list(1)-1 length(lon_list)];
lat_list = [lat_list(1)-1 length(lat_list)];
zgrid.time = ncomtime(timelist) - epoch;
zgrid.depth = ncomdepth;

% First, create the history file
if (~exist(hisfile,'file'))
  disp(['create history file: ' hisfile]);
  zgrid_write(zgrid,hisfile,epoch);
  % Fill it with zeros
  rec.zeta = nan([1 size(slon)]);
  rec.u    = nan([1 length(ncomdepth) size(slon)]);
  rec.v    = nan([1 length(ncomdepth) size(slon)]);
  rec.temp = nan([1 length(ncomdepth) size(slon)]);
  rec.salt = nan([1 length(ncomdepth) size(slon)]);
  progress(0,0,1);
  for t=1:length(timelist),
    progress(length(timelist),t,1);
    rec.time=ncomtime(timelist(t))-epoch;
    nc_addnewrecs(hisfile,rec,'time');
  end
end

% Don't keep checking too far into the future
timelist = timelist(find( ncomtime(timelist) <= (floor(now)+14) ));

% Load the data
for v=1:length(vars),
  var=char(vars(v));
  svar=char(ncom(v));
  disp(svar);
  ncomfile=sprintf(url,char(files(v)));
  ntime=nc_varget(hisfile,'time')+epoch;

  % First, find all empty records
  if ( dims(v) == 3 )
    curdat = nc_varget(hisfile,var);
  else
    curdat = squeeze(nc_varget(hisfile,var,[0 0 0 0], [-1 1 -1 -1]));
  end
  curdat = reshape(curdat,[size(curdat,1) size(curdat,2)*size(curdat,3)]);
  curdat = nanmean(curdat,2);
  % Find the empty records not to exceed the available data
  list = find((isnan(curdat) | curdat > 1e30) & ...
              ntime <= ncomtime(timelist(end)));
  % Merge the empty fields with the requested fields
  tlist=vecfind(ntime,ncomtime(timelist));
  list=unique([list; tlist']);
  timelist=vecfind(ncomtime,ntime(list));
  if ( isempty(list) ) continue; end
  
  progress(0,0,1);
  for t=1:length(list),
    progress(length(list),t,1);
    try 
      if ( dims(v) == 3 )
        ncomdat = nc_varget(ncomfile, svar, ...
                   [timelist(t)-1 lat_list(1) lon_list(1)], ...
                   [1 lat_list(2) lon_list(2)]);
        nc_varput(hisfile,var,ncomdat,[list(t)-1 0 0],size(ncomdat))
      else
        ncomdat = nc_varget(ncomfile,svar, ...
                        [timelist(t)-1 0 lat_list(1) lon_list(1)], ...
                        [1 -1 lat_list(2) lon_list(2)]);
        nc_varput(hisfile,var,ncomdat,[list(t)-1 0 0 0],size(ncomdat))
      end
    catch err
      fprintf(1,'X');
      continue;
    end
  end
end
