addpath(genpath('../ext/'))
addpath(genpath('../../conf/'))

set_default_options()

grid=grid_read(opt.grid_path_roms);

out = opt.inifile_name;
in='../../../../srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_clim_1994_1.nc';

tt=nc_varget(in,'zeta_time');
initime=opt.initime;

ini_write(grid, out, opt.epoch_roms, true);
times = nc_varget(in,'zeta_time')+opt.epoch_roms;
l=find(times==initime);
initime = (initime-opt.epoch_roms)*86400;
nc_varput(out,'ocean_time',initime);

vars={'zeta' 'ubar' 'vbar'};
for v=1:length(vars),
  var=char(vars(v));
  nc_varput(out,var,nc_varget(in,var,[l-1 0 0],[1 -1 -1 ]));
end
vars={'u' 'v' 'temp' 'salt'};
for v=1:length(vars),
  var=char(vars(v));
  nc_varput(out,var,nc_varget(in,var,[l-1 0 0 0],[1 -1 -1 -1]));
end
