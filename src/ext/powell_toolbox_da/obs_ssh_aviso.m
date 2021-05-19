function obs = obs_ssh_aviso( files, opt, velocity )

% obs = obs_ssh_aviso( files, opt )
%
% This function generates ROMS observation files saving 
%  from the given SST files and grid file. The SST file
%  is expected to be a PFEL-processed SST file.
%
% dir   -- The input file of SST data
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
if ( nargin < 3 )
  velocity=false;
end

% Set our definitions
roms_defs

% Load the grid and steric information needed
grid = grid_read( opt.grid );
[dlatx,dlaty]=gradient(grid.latr);
[dlonx,dlony]=gradient(grid.lonr);
grid.dx = reshape(earth_distance([vector(grid.lonr(:)) ...
                                  vector(grid.lonr(:)+dlonx(:)) ...
                                  vector(grid.latr(:)) ...
                                  vector(grid.latr(:)+dlatx(:))]), ...
                                  [size(grid.maskr)]) * 1000;
grid.dy = reshape(earth_distance([vector(grid.lonr(:)) ...
                                  vector(grid.lonr(:)+dlony(:)) ...
                                  vector(grid.latr(:)) ...
                                  vector(grid.latr(:)+dlaty(:))]), ...
                                  [size(grid.maskr)]) * 1000;
% Generate the g/f term
grid.ratio = 9.80665 ./ ( 2 * (2*pi/86400) .* sin(deg2rad(grid.latr)));
                          
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
  ssh_time = nc_varget(file,'TIME') + datenum(1950,1,1);
  ssh_lon = nc_varget(file,opt.aviso_lon_var);
  l = find(ssh_lon > 180);
  if ( ~isempty(l) )
    ssh_lon(l) = ssh_lon(l) - 360;
  end
  ssh_lat = nc_varget(file,opt.aviso_lat_var);
  [ssh_lon,ssh_lat]=meshgrid(ssh_lon,ssh_lat);
    
  for t=1:length(ssh_time),
    clear ssh;
    % Load the raw SSH data
    disp(['process ssh day ' num2str(ssh_time(t)-opt.epoch)]);
    ssh.lon = ssh_lon;
    ssh.lat = ssh_lat;
    ssh.time = ones(size(ssh_lon))*ssh_time(t);
    ssh.zeta = squeeze(nc_varget(file,'GRID_0001',[t-1 0 0],[1 -1 -1])) / 100;

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
    season = datestr(ssh.time(t),18);
    season = str2num(season(2));
    [y,m]=datevec(ssh_time(t));
    mss = squeeze(mean_ssh(m,:,:));
    ssh.zeta = ssh.zeta + ...
       mss(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1)) + ...
       tsteric(season,sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1))';
    
    if (velocity)
      % Now that we have a sea surface height, calculate surface velocity
      h = mss*nan;
      h(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1)) = ssh.zeta;
    
      % Calculate dh/dx, dh/dy
      u = h * nan;
      v = h * nan;
      u(2:end,:) = grid.ratio(2:end,:) .* -diff(h) ./ grid.dy(2:end,:);
      v(:,2:end) = grid.ratio(:,2:end) .* ctranspose(diff(h')) ./ ...
                                              grid.dx(:,2:end);
      l=find(isnan(u) | isnan(v));
      u(l)=nan;
      v(l)=nan;
      u=u(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1));
      v=v(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1));
      
      erru=h*nan;
      erru(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1)) = ssh.zeta_v.^2;
      erru=max(opt.varinfo(isFsur), erru);
      erru(2:end,:) = abs(grid.ratio(2:end,:) ./ grid.dy(2:end,:)) .* ...
                      sqrt(erru(1:end-1,:)+erru(2:end,:));
      erru(1,:)=nan;
      errv=h*nan;
      errv(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1)) = ssh.zeta_v.^2;
      errv=max(opt.varinfo(isFsur), errv);
      errv(:,2:end) = abs(grid.ratio(:,2:end) ./ grid.dy(:,2:end)) .* ...
                      sqrt(errv(:,1:end-1)+errv(:,2:end));
      errv(:,1)=nan;
      erru=erru(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1));
      errv=errv(sub2ind(size(mss),round(ssh.y)+1,round(ssh.x)+1));
    end

    % Create the observation structure
    clear obs;
    obs.survey = 0;
    obs.variance = opt.varinfo;
    len = length(ssh.zeta);
    if ( len )
      obs.survey = 1;
      obs.survey_time = round(ssh_time(t) - opt.epoch);
      obs.nobs = len;

      % Build vectors
      maxerror=max( opt.varinfo(isFsur), ...
                  nanmean(ssh.zeta_v)-nanstd(ssh.zeta_v) );
      obs.error=max(ssh.zeta_v,maxerror);
      obs.type=ones(len,1)*isFsur;
      obs.time=ones(len,1)*obs.survey_time;
      obs.depth=ones(len,1)*opt.surface_layer;
      obs.x=ssh.x;
      obs.y=ssh.y;
      obs.z=zeros(len,1);
      obs.lat=ssh.lat;
      obs.lon=ssh.lon;
      obs.value=ssh.zeta;
      obs.spherical = repmat(spherical, obs.survey, 1);
      if (velocity)
        obs.error = [obs.error; erru; errv];
        obs.type=[obs.type; ones(len,1)*isUvel; ones(len,1)*isVvel];
        obs.time=ones(len*3,1)*obs.survey_time;
        obs.depth=ones(len*3,1)*opt.surface_layer;
        obs.x=[ssh.x; ssh.x; ssh.x;];
        obs.y=[ssh.y; ssh.y; ssh.y;];
        obs.z=zeros(len*3,1);
        obs.value = [obs.value; u; v];
        l = find(~isnan(obs.value));
        obs=delstruct(obs,l,length(obs.value));
      end
    end  

    % Save it out
    if ( obs.survey )
      obs.filename = regexprep(opt.obs_out,'#*',num2str(round(obs.survey_time)));
      disp(['write ' obs.filename]);
      obs_write(obs);
    end
  end
end
