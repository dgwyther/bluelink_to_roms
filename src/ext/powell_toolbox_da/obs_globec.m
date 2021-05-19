function obs = obs_globec( files, opt )

% obs = obs_globec( files, opt )
%
% This function generates ROMS observation files saving 
%  from the given globec files.
%
% dir    -- The input directory of globec data
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
  % Load the GLOBEC file
  % This is an ASCII file with a single header record consisting of:
  %  2 - year
  %  5 - day
  %  6 - month
  %  7 - time
  %  8 - depth
  %  9 - lat
  % 10 - lon
  % 11 - PRES
  % 12 - TEMP
  % 13 - SALT
  % 14 - POT_T
  % 15 - SIGMA_THETA
  fid = fopen(file);
  if ( fid == -1 )
    error(['File not found: ' file]);
  end
  data = textscan(fid,'%s%n%s%s%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n', ...
                   'headerLines',1,'treatAsEmpty',{'nd'});
  fclose(fid);
  globec.lon = data{10};
  globec.lat = data{9};
  data{7} = data{7}/100;
  globec.time = datenum(data{2},data{6},data{5}) + ...
     (floor(data{7}) + (data{7}-floor(data{7}))*10/6)/24;
  globec.pres = data{11};
  globec.temp = data{12};
  globec.salt = data{13};
  globec.sigmat = data{15};
    
  % Must create a meter depth for the data to be gridded
  globec.depth = -sw_dpth(globec.pres, globec.lat);
  clear data

  % Put the globec information onto the grid
  opt.angle = grid.angle(1:opt.di:end,1:opt.dj:end);
  opt.lat = grid.latr(1:opt.di:end,1:opt.dj:end);
  opt.lon = grid.lonr(1:opt.di:end,1:opt.dj:end);
  opt.vars = {'temp' 'salt'};
  opt.is3d = true;
  globec = obs_gridder(globec, opt);
  [globec.x, globec.y] = latlon_grid(opt.grid,globec.lon,globec.lat);
  % convert to layers from depth in meters
  %    globec.z = depth_grid( globec, opt );
  globec.z = globec.depth;
  l = find( globec.temp_v < opt.maxvarinfo(isTemp) & ...
            globec.salt_v < opt.maxvarinfo(isSalt) & ...
            ~isnan(globec.temp) & ~isnan(globec.salt) & ...
            ~isnan( globec.x ) & ~isnan( globec.y ) & ...
            ~isnan( globec.z );
  globec = delstruct(globec,l);

  % Create the observation structure
  obs.survey = 0;
  obs.variance = opt.varinfo;
  if ( length(globec.temp) )
    [l,idi,idj] = unique( globec.time - opt.epoch);
    obs.survey = length(l);
    obs.survey_time = l;
    for i=1:length(l),
      obs.nobs(i) = length(find(idj==i))*2;
    end

    % Build vectors
    obs.error=vector(max(globec.temp_v), opt_varinfo(isTemp));
    obs.error=[obs.error'; vector(max(globec.salt_v,opt.varinfo(isSalt)))];
    obs.type=vector([ ones(1,length(globec.temp))*isTemp; ones(1,length(globec.salt))*isSalt]);
    obs.time=vector([ globec.time'; globec.time']) - opt.epoch;
    obs.depth=vector([ globec.z'; globec.z']);
    obs.x=vector([ globec.x'; globec.x']);
    obs.y=vector([ globec.y'; globec.y']);
    obs.z=zeros(size(obs.x(:)));
    obs.lat=globec.lat;
    obs.lon=globec.lon;
    obs.value=vector([ globec.temp'; globec.salt' ]);
    obs.spherical = repmat(spherical, obs.survey, 1);
  end  

  % Save it out
  if ( obs.survey )
    obs.filename = regexprep(opt.obs_out,'#*',num2str(round(obs.survey_time(1))));
    disp(['write ' obs.filename]);
    obs_write(obs);
  end
end
