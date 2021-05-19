function levitus_to_roms_ini( grid, levitus, outfile, epoch )

%
% Created by Brian Powell on 2007-10-16.
% Copyright (c)  powellb. All rights reserved.
%

if (nargin < 3)
  error('you must specify a grid, levitus structure, and output file');
end

try
% First, create the initialization file
ini_write(grid,outfile,epoch);

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
vars={'temp' 'salt'};
% Go over each variable and create the data
% for t=1:length(ltime),
  rec=[];
  rec.ocean_time=ltime(1);
  rec.zeta=zeros([1  size(grid.maskr)]);
  rec.ubar=zeros([1  size(grid.masku)]);
  rec.vbar=zeros([1  size(grid.maskv)]);
  rec.u=zeros([1 grid.n size(grid.masku)]);
  rec.v=zeros([1 grid.n size(grid.maskv)]);
  for v=1:length(vars),
    var=char(vars(v));
    svar=char(levitus.var(v));
    disp(var);
    % First, handle the horizontal
    inidat  = nc_varget(outfile,var);
    if (ndims(inidat)<4)
      inidat=reshape(inidat,[1 size(inidat)]);
    end

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
                        [0 0 lat_list(1) lon_list(1)], ...
                        [1 -1 lat_list(2) lon_list(2)]));
    bad = nc_attget(char(levitus.file(v)),svar,'missing_value');
    ldat(ldat==bad)=nan;
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
    if (v==1)
      stemp = newdat;
    else
      ssalt = newdat;
    end
    % % SLOW, now go to EACH point, and interpolate in the vertical. Because
    % % ROMS uses terrain-following coords, we have to do this at each point
    % % This must be done AFTER the horizontal because of the terrain-following
    % % coordinates. A bummer.
    % for i=1:size(inidat,3)*size(inidat,4),
    %   l=find(newdat(:,i)~=0);
    %   m=find(newdat(:,i)==0);
    %   if ( length(l) < 2 ) continue; end
    %   newdat(m,i)=newdat(max(l),i);
    %   inidat(1,:,i) = spline(ldepth,newdat(:,i),depths(:,i));
    % end
    % eval(sprintf('rec.%s=inidat;',var));
    % nc_varput(outfile,var,inidat);
  end
  % nc_addnewrecs(outfile,rec,'ocean_time');
% end

% Now that we are done, we need to clean up the density structure
% temp=nc_varget(outfile,'temp');
% salt=nc_varget(outfile,'salt');
% depths=grid_depth(grid);
[temp,salt]=interp_density(stemp,ssalt,ldepth,grid);

% [temp, salt] = interp_density(squeeze(temp),squeeze(salt),depths,grid);
nc_varput(outfile,'temp',temp);
nc_varput(outfile,'salt',salt);

catch
  err=lasterror;
  disp(['ERROR: ' err.message]);
  keyboard
end
