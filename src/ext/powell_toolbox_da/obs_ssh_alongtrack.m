function obs = obs_ssh_aviso( files, opt )

% obs = obs_ssh_alongtrack( files, opt )
%
% This function generates ROMS observation file saving 
%  from the given Alongtrack files and grid file. The SSH file
%  is expected to be a GDR-processed SSH file.
%
% files   -- The alongtrack files of SSH data
% opt   -- Options for the processing
%   opt.grid     -- The grid file
%   opt.obs_out      -- The output file
%   opt.di       -- Sampling in the i-direction of the ROMS grid
%   opt.dj       -- Sampling in the j-direction of the ROMS grid
%   opt.dz       -- Sampling in the z-direction of the ROMS grid
%   opt.average  -- The file with the model mean fields
%   opt.epoch    -- The datenum of the model epoch
%   opt.dlon     -- The zonal size to use for gridding data (km)
%   opt.dlat     -- The meridional size to use for gridding data (km)
%   opt.ddepths  -- The depth grids to use for gridding data (m)
%   opt.varinfo  -- The variance information for the types of data
%
% The observation structure is returned
if ( nargin < 2 )
  error('You must specify at least two arguments');
end

% Set our definitions
roms_defs

% Load the grid and steric information needed
grid = grid_read( opt.grid );
ocean = find(grid.maskr(1:opt.dj:end,1:opt.di:end));
opt.angle = grid.angle(1:opt.dj:end,1:opt.di:end);
opt.lat = grid.latr(1:opt.dj:end,1:opt.di:end);
opt.lon = grid.lonr(1:opt.dj:end,1:opt.di:end);

% Load the mean sea surface height
mean_ssh = nc_varget(opt.average,'zeta');

% Load & Configure the steric height adjustment
load('steric.mat');
l = find( steric.lon > 180 );
steric.lon(l) = steric.lon(l) - 360;
lat_list = find( steric.lat <= max( opt.lat(:) + 1 ) & ...
                 steric.lat >= min( opt.lat(:) - 1 ));
lon_list = find( steric.lon <= max( opt.lon(:) + 1 ) & ...
                 steric.lon >= min( opt.lon(:) - 1 ));
steric.lon=steric.lon(lon_list);
steric.lat=steric.lat(lat_list);
steric.mean=steric.mean(:,lat_list,lon_list);
temp = convolve_land(steric.mean, squeeze(steric.mean(1,:,:)), 7);
for i=1:size(temp,1),
  [lon,lat]=meshgrid(steric.lon,steric.lat);
  tsteric(i,:,:) = griddata(lon,lat,squeeze(temp(i,:,:)),opt.lon,opt.lat) .* grid.maskr;
end

% Restrict to ocean points
opt.angle=opt.angle(ocean);
opt.lat=opt.lat(ocean);
opt.lon=opt.lon(ocean);

for fcount=1:numel(files),
  file=char(files(fcount));
  
  % Load the SSH information
  clear ssh;
  fid=fopen(file,'rb');
  if (fid == -1) continue; end
  alongtrack=fread(fid,inf,'real*8');
  fclose(fid);
  alongtrack=reshape(alongtrack,4,length(alongtrack)/4)';
  good=find(alongtrack(:,4)~=-999999999999);
  ssh.time = alongtrack(good,1)/86400+datenum(1992,1,1);
  ssh.lon = alongtrack(good,3);
  ssh.lat = alongtrack(good,2);
  ssh.zeta = alongtrack(good,4)/1000;
  clear alongtrack
  
  % Find the points within our domain
  glon = opt.lon;
  l=find(glon<0);
  if ( ~isempty(l) ) glon(l)=glon(l)+360; end
  good = find( ssh.lat <= max(opt.lat)+1 & ssh.lat >= min(opt.lat)-1 & ...
               ssh.lon <= max(glon)+1 & ssh.lon >= min(glon)-1);
  ssh=delstruct(ssh,good,length(ssh.lat));
  l = find(ssh.lon > 180);
  if ( ~isempty(l) )
    ssh.lon(l) = ssh.lon(l) - 360;
  end

  % Put the SSH information onto the grid
  opt.vars = {'zeta'};
  opt.is3d = false;
  ssh = obs_gridder(ssh, opt);
  [ssh.x, ssh.y] = latlon_grid(opt.grid,ssh.lon,ssh.lat);

  % Remove masking
  l = find(~isnan( ssh.x ) & ~isnan( ssh.y ));
  ssh.zeta(l(find( ~ grid.maskr(sub2ind(size(grid.maskr),floor(ssh.y(l)+1),floor(ssh.x(l)+1)))))) = nan;

  % Remove unknown points and duplicates
  [tmp, l] = uniquerows(round([ssh.x ssh.y]));
  l = l(find( (ssh.zeta_v(l) < opt.maxvarinfo(isFsur)) & ...
              ~isnan(ssh.zeta(l)) & ~isnan( ssh.x(l) ) & ...
              ~isnan( ssh.y(l) )));
  ssh = delstruct(ssh,l);

  % Add the model mean and the steric height
  t=mean(ssh.time);
  season = datestr(t,18);
  season = str2num(season(2));
  [y,m]=datevec(t);
  mss = squeeze(nanmean(mean_ssh));
  ssh.zeta = ssh.zeta + ...
     mss(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1)) + ...
     tsteric(season,sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1))';
  
  % Create the observation structure
  clear obs;
  obs.survey = 0;
  obs.variance = opt.varinfo;
  len = length(ssh.zeta);
  if ( len )
    [l,idi,idj] = unique( ssh.time - opt.epoch);
    obs.survey = length(l);
    obs.survey_time = l;
    for i=1:length(l),
      obs.nobs(i) = length(find(idj==i));
    end

    % Build vectors
    maxerror=max( opt.varinfo(isFsur), ...
                nanmean(ssh.zeta_v)-nanstd(ssh.zeta_v) );
    obs.error=max(ssh.zeta_v,maxerror);
    obs.type=ones(len,1)*isFsur;
    obs.time=vector(ssh.time) - opt.epoch;
    obs.depth=ones(len,1)*opt.surface_layer;
    obs.x=ssh.x;
    obs.y=ssh.y;
    obs.z=zeros(len,1);
    obs.lat=ssh.lat;
    obs.lon=ssh.lon;
    obs.value=ssh.zeta;
    obs.spherical = repmat(spherical, obs.survey, 1);
  end  

  % Save it out
  if ( obs.survey )
    obs.filename = regexprep(opt.obs_out,'#*',num2str(round(min(obs.survey_time))));
    disp(['write ' obs.filename]);
    obs_write(obs);
  end
end
