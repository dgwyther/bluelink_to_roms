opt = set_default_options();

opt.obs_out = [opt.obs_out 'ssh_aviso/ias_aviso_#.nc'];
obs = obs_ssh_aviso({'/home/powellb/ias/ssh_aviso/aviso_2005-2006.nc'}, opt);
