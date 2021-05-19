function obs = obs_sst_coamps( files, opt )

% obs = obs_sst_coamps( files, opt )
%
% This function generates ROMS observation files saving
%  from the given SST files and grid file. The SST file
%  is expected to be a COAMPS SST file.
%
% dir   -- The input file of SST data
% opt   -- Options for the processing
%   opt.grid     -- The grid file
%   opt.obs_out  -- The output file
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

% Load the grid information needed
grid = grid_read( opt.grid );
ocean = find(grid.maskr(1:opt.dj:end,1:opt.di:end));
opt.angle = grid.angle(1:opt.dj:end,1:opt.di:end);
opt.lat = grid.latr(1:opt.dj:end,1:opt.di:end);
opt.lon = grid.lonr(1:opt.dj:end,1:opt.di:end);
opt.angle = opt.angle(ocean);
opt.lat = opt.lat(ocean);
opt.lon = opt.lon(ocean);

for fcount=1:numel(files),
  file=char(files(fcount));
  clear obs sst;
  % Load the processed SST data
    disp(['process ' file]);
    sst_lat = nc_varget(file,'lat');
    sst_lon = nc_varget(file,'lon');
    sst.units = nc_attget(file,'sst_time','units');
    switch sst.units
      case 'days since 1968-05-23 00:00:00'
        sst_time = nc_varget(file,'sst_time') + datenum(1968,5,23);
      otherwise
        fprintf('sst.units=%s\n',sst.units);
        error('Unexpected time-units in coamps sst file.');
    end

  for t=1:length(sst_time)
    clear sst;
    % Load the SST data
    disp(['process sst day ' num2str(sst_time(t)-opt.epoch)]);
    sst.lon = sst_lon;
    sst.lat = sst_lat;
    sst.time = ones(size(sst_lon))*sst_time(t);
    sst.temp = squeeze(nc_varget(file,'SST',[t-1 0 0],[1 -1 -1]));
    %l=find(sst.temp<10 | sst.temp>40);
    %sst.temp(l)=nan;

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
    obs.epoch = opt.epoch;  % cae added
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
end
