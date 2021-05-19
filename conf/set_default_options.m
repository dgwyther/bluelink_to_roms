function opt = set_default_options()

% Set the default ocean operational system options for matlab

opt = [];


% % Set directories
% opt.home_dir = getenv('HOME');
% opt.root_dir = [opt.home_dir '/npal/RUNS'];
% opt.grid_dir = [opt.root_dir '/grid'];



% global grid directories
opt.grid_path_roms='/home/z3097808/eac/grid/EACouter_varres_grd_mergedBLbry.nc';
opt.grid_path_bluelink='../grid/EACouter_BL_grid.nc';

% global time settings
opt.epoch_roms=datenum(2000,1,1);                           % epoch for data
opt.years=[1994:2016];                                      % set time coverage



% processing BRAN directories
opt.outpath='/srv/scratch/z3097808/bluelink_new/20years/';  % set output path
opt.outfile=[opt.outpath,'EAC_BlueLink_his_1994_2016.nc'];      % set output file name
opt.path='/srv/scratch/z3097808/bluelink_new/files/20years/'; % set path to BRAN2020 data

% making climatology directories
opt.climfile_path =  '/srv/scratch/z3097808/bluelink_new/20years/';
opt.climfile_prefix = 'EAC_BRAN_clim_';

% making bry settings
opt.bryfile_path = '/srv/scratch/z3097808/bluelink_new/20years/';
opt.bryfile_prefix = 'EAC_BRAN_bry_';

% making ini settings
opt.initime=datenum(1994,1,1,12,0,0);
opt.inifile_name = '../../../../srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_1994Jan1_ini.nc';
