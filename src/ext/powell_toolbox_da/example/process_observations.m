function process_observations( times )


opt = set_default_options();

% If no time was specified, do the last two weeks
if ( ~nargin )
  times=floor([now-opt.assim_period:opt.assim_period:now]) - opt.epoch;
end

opt.variance = cell(6,1);
opt.variance(1) = cellstr('ssh_monthly_var');
opt.variance(4) = cellstr('adcp_monthly_var_u');
opt.variance(5) = cellstr('adcp_monthly_var_v');
opt.variance(6) = cellstr('sst_monthly_var');
opt.dt_min = 0.05;
opt.dirs = {[opt.out '/adcp'] [opt.out '/sst_ccar'] [opt.out '/ccar']};
%opt.dirs = {[opt.out '/adcp'] [opt.out '/sst'] [opt.out '/ccar']};
opt.out = [opt.out '/roms_obs/ias_obs_#.nc'];
opt.times = times;

% Generate the observations
create_obs_assim(opt);
