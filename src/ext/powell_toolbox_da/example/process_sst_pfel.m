opt = set_default_options();

if ( nargin < 1 )
  dir = opt.sst_dir;
end

% =========== PFEL SST ===============
opt.obs_out = './sst_pfel/ias_sst_#.nc';
files = ls_files(opt.sst_dir,'nc');
if ( ~isempty( files ) )
  obs = obs_sst_pfel(files, opt);
end
