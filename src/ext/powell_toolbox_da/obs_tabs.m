function obs = obs_tabs( files, opt )

% obs = obs_tabs( files, opt )
%
% This function generates ROMS observation files saving 
%  from the given TABS files and grid file. 
%
% dir    -- The input directory of tabs data
% opt   -- Options for the processing
%   opt.grid     -- The grid file
%   opt.obs_out  -- The output file
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
for fcount=1:numel(files),
  file=char(files(fcount));
  clear obs;

    disp(['process ' file]);
    % Load the TABS file
    % The first row is the buoy name, lat, lon, depth -- USER MUST CREATE THIS LINE!
    % This is an ASCII file with a columns consisting of:
    %  1 - Date
    %  2 - Time (UTC)
    %  3 - u (cm/s)
    %  4 - v (cm/s)
    %  5 - speed (cm/s)
    %  6 - dir (deg)
    %  7 - Temp (degC)
    fid = fopen(file);
    if ( fid == -1 )
      error(['File not found: ' file]);
    end
    [tabs.name, tabs.lat, tabs.lon, tabs.z] = strread(fgets(fid),'%s %n %n %n');
    data = textscan(fid,'%s%s%n%n%n%n%n', ...
                     'treatAsEmpty',{'---'});
    fclose(fid);
    tabs.z = repmat(tabs.depth,length(data{1}),1);
    tabs.lat = repmat(tabs.lat,length(data{1}),1);
    tabs.lon = repmat(tabs.lon,length(data{1}),1);
    tabs.time = datenum([char(data{1}) repmat([' '],length(data{1}),1) char(data{2})]);
    tabs.u = lowpass_filter(data{3} * 100, 0.5, opt.filter_length);
    tabs.v = lowpass_filter(data{4} * 100, 0.5, opt.filter_length);
    tabs.temp = data{7};
    clear data

  % Put the tabs information onto the grid
    opt.angle = grid.angle(1:opt.di:end,1:opt.dj:end);
    opt.lat = grid.latr(1:opt.di:end,1:opt.dj:end);
    opt.lon = grid.lonr(1:opt.di:end,1:opt.dj:end);
    opt.vars = {'u' 'v'};
    opt.is3d = false;
    [tabs.x, tabs.y] = latlon_grid(opt.grid,tabs.lon,tabs.lat);
    % convert to layers from depth in meters
    %    tabs.z = depth_grid( tabs, opt );
    l = find( tabs.u_v < opt.maxvarinfo(isUvel) & ...
              tabs.v_v < opt.maxvarinfo(isVvel) & ...
              ~isnan(tabs.u) & ~isnan(tabs.v) & ~isnan( tabs.x ) & ...
             ~isnan( tabs.y ) & ~isnan( tabs.z ));
    tabs = delstruct(tabs,l);

  % Create the observation structure
  obs.survey = 0;
  obs.variance = opt.varinfo;
  if ( length(tabs.temp) )
    [l,idi,idj] = unique( tabs.time - opt.epoch);
    obs.survey = length(l);
    obs.survey_time = l;
    for i=1:length(l),
      obs.nobs(i) = length(find(idj==i))*2;
    end

    % Build vectors
    maxerror=max( opt.varinfo(isUvel), ...
                  nanmean(tabs.u_v)-nanstd(tabs.u_v) );
    obs.error=vector(max([ tabs.u_v'; tabs.v_v'],maxerror));
    obs.type=vector([ ones(1,length(tabs.u))*isUvel; ones(1,length(tabs.v))*isVvel]);
    obs.time=vector([ tabs.time'; tabs.time']) - opt.epoch;
    obs.depth=vector([ tabs.z'; tabs.z']);
    obs.x=vector([ tabs.x'; tabs.x']);
    obs.y=vector([ tabs.y'; tabs.y']);
    obs.z=zeros(size(obs.x(:)));
    obs.lat=tabs.lat;
    obs.lon=tabs.lon;
    obs.value=vector([ tabs.u'; tabs.v' ]);
    obs.spherical = repmat(spherical, obs.survey, 1);
  end  

  % Save it out
  if ( obs.survey )
    obs.filename = regexprep(opt.obs_out,'#*',num2str(round(obs.survey_time(1))));
    disp(['write ' obs.filename]);
    obs_write(obs);
  end
end
