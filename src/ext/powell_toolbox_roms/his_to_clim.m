function his_to_clim( hisgrid, hisfile, climfile )
  
% Given a history grid, a history file, the climatology grid, 
% and the name of a climate file,
% create the climatology file from the history file data

if nargin < 3
  error('You must specify the arguments')
end

histime=nc_varget(hisfile,'ocean_time')/86400;
epoch=get_epoch(hisfile);

% Create the appropriately sized climatology file -- much faster using ncgen
disp(['create climatology file: ' climfile]);
unix([regexprep(which('clim_write'),'\.m$','\.sh') ' ' climfile ' '...
      num2str([hisgrid.lp hisgrid.mp hisgrid.n length(histime)])]);

% Make sure we have a file
if (~exist(climfile,'file'))
  error([climfile ' could not be created']);
end

% Copy the data
vars={'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt'};
timevars={'zeta_time' 'v2d_time' 'v2d_time' 'v3d_time' 'v3d_time' 'temp_time' 'salt_time'};
for v=1:length(vars),
  var=char(vars(v));
  disp(var);
  nc_varput(climfile,char(timevars(v)),histime);
  nc_varput(climfile,var,nc_varget(hisfile,var));
end
