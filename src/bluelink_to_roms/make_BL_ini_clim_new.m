cd /home/z3097808/eac/bluelink

grid=grid_read('../grid/EACouter_varres_grd_mergedBLbry.nc');
epoch=datenum([2000,1,1,0,0,0]);

out='../../../../srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_1994Jan1_ini.nc';
in='../../../../srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_clim_1994_1.nc';

tt=nc_varget(in,'zeta_time');
initime=datenum(1994,1,1,12,0,0);

ini_write(grid, out, datenum(2000,1,1), true);
times = nc_varget(in,'zeta_time')+epoch;
l=find(times==initime);
initime = (initime-epoch)*86400;
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
