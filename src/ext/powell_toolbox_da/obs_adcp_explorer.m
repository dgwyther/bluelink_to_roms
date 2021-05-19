function obs = obs_adcp_explorer( dirs, opt )

% obs = obs_adcp_explorer( dirs, opt )
%
% This function generates ROMS observation files saving 
%  from the given ADCP directories and grid file. The ADCP directory
%  is expected to be a RSMAS-processed Explorer directory.
%
% dir    -- The input directory of ADCP data
% opt   -- Options for the processing
%   opt.grid     -- The grid file
%   opt.out      -- The output file
%   opt.di       -- Sampling in the i-direction of the ROMS grid
%   opt.dj       -- Sampling in the j-direction of the ROMS grid
%   opt.dz       -- Sampling in the z-direction of the ROMS grid
%   opt.dlon     -- The zonal size to use for gridding data (km)
%   opt.dlat     -- The meridional size to use for gridding data (km)
%   opt.ddepths  -- The depth bins to use for gridding data (m)
%
% The observation structure is returned

if ( nargin < 2 )
  error('You must specify two arguments');
end

% Set our definitions
roms_defs

% Load the grid information needed
grid = grid_read( opt.grid );

% Loop over the files, creating observations for each file
for fcount=1:numel(dirs),
  dir=char(dirs(fcount));
  clear obs;

  % Load the raw ADCP data
  disp(['process ' dir]);
  load([dir '/contour/contour_xy.mat']);
  load([dir '/contour/contour_uv.mat']);
  adcp.name = dir;

  % Measure the bathymetry of the locations
  bath = bath_read( opt.etopo82, xyt(2,:), xyt(1,:) );
  bath = find( bath < opt.minbath );
  adcp.lat = xyt(2,bath);
  adcp.lon = xyt(1,bath);

  % Convert the lons and pare down the data
  l = find(adcp.lon > 180);
  adcp.lon(l) = adcp.lon(l) - 360;
  adcp.time = datenum(year_base,1,1)+xyt(3,bath);
  adcp.u = uv(:,(bath*2)-1);
  adcp.v = uv(:,bath*2);
  adcp.depth = -zc;
  l = find( sqrt(adcp.u.^2 + adcp.v.^2) > opt.max_speed );
  adcp.u(l)=nan;
  adcp.v(l)=nan;
  adcp.lat=vector(adcp.lat(ones(size(adcp.u,1),1),:));
  adcp.lon=vector(adcp.lon(ones(size(adcp.u,1),1),:));
  adcp.time=vector(adcp.time(ones(size(adcp.u,1),1),:));
  adcp.depth=vector(adcp.depth(:,ones(size(adcp.u,2),1)));
  adcp.u = adcp.u(:);
  adcp.v = adcp.v(:);
  l = find( ~isnan(adcp.u) & ~isnan(adcp.v) );
  adcp = delstruct(adcp,l,length(adcp.u));

  % Put the ADCP information onto the grid
  opt.angle = grid.angle(1:opt.di:end,1:opt.dj:end);
  opt.lat = grid.latr(1:opt.di:end,1:opt.dj:end);
  opt.lon = grid.lonr(1:opt.di:end,1:opt.dj:end);
  opt.vars = {'u' 'v'};
  opt.is3d = true;
  adcp = obs_gridder(adcp, opt );
  [adcp.x, adcp.y] = latlon_grid(opt.grid,adcp.lon,adcp.lat);
  adcp = validate_bath( adcp, grid.h );
  adcp.z = depth_grid( adcp, opt );
  l = find( ~isnan( adcp.y ) & ~isnan( adcp.x ));
  adcp.u(l(find( ~grid.masku(sub2ind(size(grid.masku),floor(adcp.y(l)+1),floor(adcp.x(l)+0.5)))))) = nan;
  adcp.v(l(find( ~grid.maskv(sub2ind(size(grid.maskv),floor(adcp.y(l)+0.5),floor(adcp.x(l)+1)))))) = nan;
  l = find( adcp.u_v < opt.maxvarinfo(isUvel) & ...
            adcp.v_v < opt.maxvarinfo(isVvel) & ...
            ~isnan(adcp.u) & ~isnan(adcp.v) & ~isnan( adcp.x ) & ...
            ~isnan( adcp.y ) & ~isnan( adcp.z ));
  adcp = delstruct(adcp,l);
  adcp.angle = grid.angle(sub2ind(size(grid.angle),floor(adcp.y)+1,floor(adcp.x)+1));

  % Rotate the vectors
  for i=1:length(adcp.u),
    R = [ [cos(adcp.angle(i)) sin(adcp.angle(i))]; 
          [-sin(adcp.angle(i)) cos(adcp.angle(i))]];
    nu = R * [ adcp.u(i); adcp.v(i) ];
    adcp.u(i) = nu(1);
    adcp.v(i) = nu(2);
  end
  
  % Create the observation structure
  obs.survey = 0;
  obs.variance = opt.varinfo;
  if ( length(adcp.u) )
    [l,idi,idj] = unique( adcp.time - opt.epoch);
    obs.survey = length(l);
    obs.survey_time = l;
    for i=1:length(l),
      obs.nobs(i) = length(find(idj==i))*2;
    end

    % Build vectors
    maxerror=max( opt.varinfo(isUvel), ...
                  nanmean(adcp.u_v)-nanstd(adcp.u_v) );
    obs.error=vector(max([ adcp.u_v'; adcp.v_v'],maxerror));
    obs.type=vector([ ones(1,length(adcp.u))*isUvel; ones(1,length(adcp.u))*isVvel]);
    obs.time=vector([ adcp.time'; adcp.time']) - opt.epoch;
    obs.depth=vector([ adcp.z'; adcp.z']);
    obs.x=vector([ adcp.x'-0.5; adcp.x']);
    obs.y=vector([ adcp.y'; adcp.y'-0.5]);
    obs.z=zeros(size(obs.x(:)));
    obs.lat=adcp.lat;
    obs.lon=adcp.lon;
    obs.value=vector([ adcp.u'; adcp.v' ]);
    obs.spherical = repmat(spherical, obs.survey, 1);
  end  

  % Save it out
  if ( obs.survey )
    obs.filename = regexprep(opt.obs_out,'#*',num2str(round(obs.survey_time(1))));
    disp(['write ' obs.filename]);
    obs_write(obs);
  end
end
