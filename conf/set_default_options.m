function opt = set_default_options()

% Set the default ocean operational system options for matlab

opt = [];


% % Set directories
% opt.home_dir = getenv('HOME');
% opt.root_dir = [opt.home_dir '/npal/RUNS'];
% opt.grid_dir = [opt.root_dir '/grid'];



% global grid directories
opt.grid_path_roms='/g/data/fu5/deg581/grd/EACouter_varres_grd_mergedBLbry_uhroms.nc';
opt.grid_path_bluelink='../../data/out/EACouter_BL_grid.nc';	% BL grid for ROMS region

% global time settings
opt.epoch_roms=datenum(2000,1,1);                           	% epoch for data
opt.years=[1994:2019];                                      	% set time coverage

% BRAN grid settings
opt.grid_path_branNative = '/g/data/gb6/BRAN/BRAN2020/static/ocean_grid.nc';  	% BRAN2020 native grid

% processing BRAN directories
opt.outpath='../../data/out/';  	% set output path
opt.outfile=[opt.outpath,'EAC_BRAN2020_his_1994_2019.nc'];      % set output file name
opt.BRAN2020_path='/g/data/gb6/BRAN/BRAN2020/daily/'; 		% set path to BRAN2020 data
opt.bluelink_his_parallelise = 'yes' 				% Choose this to parallelise the gridding of BRAN u,v data to ROMS grid

% making climatology directories
opt.climfile_path =  '../../data/out/';
opt.climfile_prefix = 'EAC_BRAN2020_clim_';

% making bry settings
opt.bryfile_path = '../../data/final/';
opt.bryfile_prefix = 'EAC_BRAN_bry_';

% making ini settings
opt.initime=datenum(1994,1,1,12,0,0);
opt.inifile_name = '../../../../srv/scratch/z3097808/bluelink_new/20years/EAC_BRAN_1994Jan1_ini.nc';
