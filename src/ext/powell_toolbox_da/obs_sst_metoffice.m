function obs = obs_sst_metoffice( files, opt )

% obs = obs_sst_metoffice( files, opt )
%
% This function generates ROMS observation files saving
%  from the given SST files and grid file. The SSH file
%  is expected to be a CCAR-processed UK Metoffice file.
%
% dir   -- The input file of SST data
% opt   -- Options for the processing
%   opt.grid     -- The grid file
%   opt.obs_out      -- The output file
%   opt.di       -- Sampling in the i-direction of the ROMS grid
%   opt.dj       -- Sampling in the j-direction of the ROMS grid
%   opt.dz       -- Sampling in the z-direction of the ROMS grid
%   opt.dlon     -- The zonal size to use for gridding data (km)
%   opt.dlat     -- The meridional size to use for gridding data (km)
%   opt.ddepths  -- The depth bins to use for gridding data (m)
%   opt.varinfo  -- The variance information for the types of data
%
% The observation structure is returned
if ( nargin < 2 )
  error('You must specify two arguments');
end

% Set our definitions
roms_defs

% Load the grid and steric information needed
grid = grid_read( opt.grid );
ocean = find(grid.maskr(1:opt.dj:end,1:opt.di:end));
opt.angle = grid.angle(1:opt.dj:end,1:opt.di:end);
opt.lat = grid.latr(1:opt.dj:end,1:opt.di:end);
opt.lon = grid.lonr(1:opt.dj:end,1:opt.di:end);

for fcount=1:numel(files),
  file=char(files(fcount));
  clear obs sst;
  % Load the raw SST data
    disp(['process ' file]);
    t=regexp(file,'ghrsst_(?<year>\d{4})(?<day>\d+)\.txt','names');
    [sst.lon,sst.lat,sst.temp]=textread(file,'%f %f %f %*[^\n]','headerlines',2);
    l = find( sst.lon > 180 );
    sst.lon(l) = sst.lon(l) - 360;
    list = find( sst.lat <= max( opt.lat(:) + 1 ) & ...
                 sst.lat >= min( opt.lat(:) - 1 ) & ...
                 sst.lon <= max( opt.lon(:) + 1 ) & ...
                 sst.lon >= min( opt.lon(:) - 1 ));
    sst.lon=sst.lon(list);
    sst.lat=sst.lat(list);
    sst.temp=sst.temp(list) / 100;
    sst.time = ones(size(list)) * (datenum(str2num(t.year),1,1) + str2num(t.day));

  % Put the SST information onto the grid
    opt.vars = {'temp'};
    opt.is3d = false;
    sst = obs_gridder(sst, opt);
    [sst.x, sst.y] = latlon_grid(opt.grid,sst.lon,sst.lat);
    l = find(~isnan( sst.x ) & ~isnan( sst.y ));
    sst.temp(l(find( ~ grid.maskr(sub2ind(size(grid.maskr),floor(sst.y(l)+1),floor(sst.x(l)+1))))))=nan;
    [tmp, l] = uniquerows(round([sst.x sst.y]));
    l = l(find(sst.temp_v(l) < opt.maxvarinfo(isTemp) & ...
                 ~isnan(sst.temp(l)) & ~isnan( sst.x(l) ) & ...
                 ~isnan( sst.y(l) )));
    sst = delstruct(sst,l);

  % Create the observation structure
  obs.survey = 0;
  obs.variance = opt.varinfo;
  len = length(sst.temp);
  if ( len )
    obs.survey = 1;
    obs.survey_time = round(sst.time(1) - opt.epoch);
    obs.nobs = len;

    % Build vectors
    maxerror=max( opt.varinfo(isTemp), ...
                  nanmean(sst.temp_v)-nanstd(sst.temp_v) );
    obs.error=max(sst.temp_v,maxerror);
    obs.type=ones(len,1)*isTemp;
    obs.time=ones(len,1)*obs.survey_time;
    obs.depth=ones(len,1)*opt.surface_layer;
    obs.x=sst.x;
    obs.y=sst.y;
    obs.z=zeros(len,1);
    obs.lat=sst.lat;
    obs.lon=sst.lon;
%     obs.z=sst.num;
    obs.value=sst.temp;
    obs.spherical = repmat(spherical, obs.survey, 1);
  end  

  % Save it out
  if ( obs.survey )
    obs.filename = regexprep(opt.obs_out,'#*',num2str(obs.survey_time(1)));
    disp(['write ' obs.filename]);
    obs_write(obs);
  end
end
