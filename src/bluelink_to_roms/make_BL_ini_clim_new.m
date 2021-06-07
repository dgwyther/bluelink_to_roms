clear all; close all
addpath(genpath('../ext/'))
addpath(genpath('../../conf/'))

opt = set_default_options()

grid=grid_read(opt.grid_path_roms);

out = opt.inifile_name;
inName = opt.inifile_clim; 

disp(['start making ini file at ',datestr(now)])
tt=nc_varget(inName,'zeta_time');
initime=opt.initime;

ini_write(grid, out, opt.epoch_roms, true);
times = nc_varget(inName,'zeta_time')+opt.epoch_roms;
l=find(times==initime);
initime = (initime-opt.epoch_roms)*86400;
nc_varput(out,'ocean_time',initime);

disp('do 3d vars')
vars={'zeta' 'ubar' 'vbar'};
for v=1:length(vars),
  var=char(vars(v));
  nc_varput(out,var,nc_varget(inName,var,[l-1 0 0],[1 -1 -1 ]));
end

disp('do 4d vars')
vars={'u' 'v' 'temp' 'salt'};
for v=1:length(vars),
  var=char(vars(v));
  nc_varput(out,var,nc_varget(inName,var,[l-1 0 0 0],[1 -1 -1 -1]));
end

disp(['done at ',datestr(now)])
