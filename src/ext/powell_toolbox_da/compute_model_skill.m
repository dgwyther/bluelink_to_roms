function skill = compute_model_skill( files, grid, region, mss, model_error )

% skill = compute_model_skill( files, grid, region, mss, model_error )
%
% This function calculates the skill of the assimilated model
%   Pass a cell array of directories, a grid structure, and
%   an array of region vertices.
%

if ( nargin < 5 )
  ref_file=0;
end

[grid_x, grid_y] = meshgrid([1:size(grid.lonr,2)],[1:size(grid.lonr,1)]);

numstats = length(calc_stats( 1, 2, 3, 4 ));

% Go through the directories and create the stats
progress(0,0,1);
for d=1:length(files.mod),
  progress(length(files.mod)+1,d,1);
  mod_file = strtrim(char(files.mod(d)));
  obs_file = strtrim(char(files.obs(d)));
  mod = nc_varget(mod_file,'NLmodel_value');
  try
    ref = nc_varget(mod_file,'NLmodel_initial');
    tl = nc_varget(mod_file,'TLmodel_value');
  catch
    ref = mod;
    tl = zeros(size(ref));
  end
  nobs = length(nc_varget(obs_file,'obs_variance'));
  obs = nc_varget(obs_file,'obs_value');
  obs_err = nc_varget(obs_file,'obs_error');
  time = nc_varget(obs_file,'obs_time');
  type = nc_varget(obs_file,'obs_type');
  x = nc_varget(obs_file,'obs_Xgrid') + 1;
  y = nc_varget(obs_file,'obs_Ygrid') + 1;
  z = nc_varget(obs_file,'obs_depth');
  prov = nc_varget(obs_file,'obs_provenance');
  
  % Remove points that ROMS eliminated
  reject = nc_varget(mod_file,'obs_scale');

  % Try to eliminate zeroed out land points from the stats
  l=find(mod==0 | reject==0);
  mod(l) = nan;
  ref(l) = nan;
  tl(l) = nan;
  obs(l) = nan;
  
  if ( nargin > 3 )
    % Remove the MSS from the SSH
    l = find( type==1 );
    nmss = interp2(grid_x,grid_y,mss,x(l),y(l));
    mod(l) = mod(l) - nmss;
    ref(l) = ref(l) - nmss;
    obs(l) = obs(l) - nmss;
  end
  

%  numstats = size(calc_stats( ref(1), ref(1), ref(1) ));

  % Loop over all regions
  for reg=1:length(region),
    % If we have a spatial region, extract it
    if ( isfield(region(reg), 'vert') & ~isempty(region(reg).vert))
      cur_region = find(inpolygon( x, y, ...
                      region(reg).vert(1,:), region(reg).vert(2,:)));
    else
      cur_region = [1:length(x)]';
    end

    % If we have specific depths, extract them
    if ( isfield(region(reg), 'depth') & ~isempty(region(reg).depth))
      l = find(z(cur_region) >= region(reg).depth(1) & ...
               z(cur_region) <= region(reg).depth(end));
      cur_region = cur_region(l);
    end
    
    % If we want particular provenance
    if ( isfield(region(reg), 'provenance') )
      if ( ~isempty(region(reg).provenance) )
        l=[];
        for p=1:length(region(reg).provenance),
          l = [l; find(prov(cur_region) == region(reg).provenance(p))];
        end
        cur_region = cur_region(l);
      end
    end

    % If we don't have any data, move on
    if ( isempty(cur_region) )
      skill(d,reg).misfit = ones(1,8)*nan;
      skill(d,reg).ref_misfit = ones(1,8)*nan;
      skill(d,reg).cost = ones(1,8)*nan;
      skill(d,reg).num_obs = ones(1,8)*nan;
      for v=[1:7],
        skill(d,reg).var(v).time = nan;
        skill(d,reg).var(v).ref = ones(1,numstats)*nan;
        skill(d,reg).var(v).global = ones(1,numstats)*nan;
        skill(d,reg).var(v).day = ones(1,numstats)*nan;
        skill(d,reg).var(v).ref_day = ones(1,numstats)*nan;
      end
      continue;
    end
    
    skill(d,reg).misfit(1) = nansum( (mod(cur_region)-obs(cur_region)).^2 ./ ...
                                     obs_err(cur_region));
    skill(d,reg).ref_misfit(1) = nansum( (ref(cur_region)-obs(cur_region)).^2 ./ ...
                                     obs_err(cur_region));
    skill(d,reg).cost(1) = 0.5 * nansum( (ref(cur_region)+tl(cur_region)-obs(cur_region)).^2 ./ ...
                                     obs_err(cur_region));
    skill(d,reg).num_obs(1) = length(find(~isnan(cur_region)));

    % Next, the observations and observations by day
    vars = unique(type(cur_region))';
    for v=[1:nobs],
      l = cur_region(find( type(cur_region) == v ));
      if ( isempty(l) )
        skill(d,reg).misfit(v+1) = nan;
        skill(d,reg).ref_misfit(v+1) = nan;
        skill(d,reg).cost(v+1) = nan;
        skill(d,reg).num_obs(v+1) = nan;
        skill(d,reg).var(v).ref = ones(numstats)*nan;
        skill(d,reg).var(v).global = ones(numstats)*nan;
      else
        skill(d,reg).misfit(v+1) = nansum((mod(l)-obs(l)).^2 ./ ...
                                          obs_err(l));
        skill(d,reg).ref_misfit(v+1) = nansum((ref(l)-obs(l)).^2 ./ ...
                                              obs_err(l));
        skill(d,reg).cost(v+1) = 0.5 * nansum((ref(l)+tl(l)-obs(l)).^2 ./ ...
                                          obs_err(l));
        skill(d,reg).num_obs(v+1) = length(find(~isnan(l)));
        skill(d,reg).var(v).ref = calc_stats( ref(l), obs(l), ref(l), obs_err(l));
        skill(d,reg).var(v).global = calc_stats( mod(l), obs(l), ref(l), obs_err(l));
      end
      t = unique(time);
      skill(d,reg).var(v).time = t;
      for n=1:length(t),
        m = l(find( time(l) == t(n)));
        if ( isempty(m) )
          skill(d,reg).var(v).day(n,:) = ones(1,numstats)*nan;
          skill(d,reg).var(v).ref_day(n,:) = ones(1,numstats)*nan;
        else
          skill(d,reg).var(v).day(n,:) = calc_stats(mod(m), obs(m), ref(m), obs_err(m));
          skill(d,reg).var(v).ref_day(n,:) = calc_stats(ref(m), obs(m), ref(m), obs_err(m));
        end
      end
    end
  end
end
progress(length(files.mod)+1,d+1,1);

