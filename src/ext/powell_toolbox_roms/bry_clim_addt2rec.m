function bry_clim_addt1rec(grid,climfile,climprev,bryfile,epoch)
%   BRY_CLIM   Create Boundaries from Climatology File
%     BRY_CLIM(GRID,CLIMFILE,BRYFILE)
% 
%   Given a climatology file, create boundary conditions
%   
%   Created by Brian Powell on 2008-12-29.
%   Copyright (c)  Univ. of Hawaii. All rights reserved.

% edited by Colette Kerry Jan 2018
% climprev is the previous clim file, adds a record at the start that is the last record of the previous clim file

dirs={'north' 'south' 'east' 'west'};
vars={'zeta' 'ubar' 'vbar' 'u' 'v' 'temp' 'salt'};
timevars={'zeta' 'v2d' 'v2d' 'v3d' 'v3d' 'temp' 'salt'};
climgroup=[1 2 2 3 3 4 5];
dims=[3 3 3 4 4 4 4];
mask={'r' 'u' 'v' 'u' 'v' 'r' 'r'};

if (nargin < 3)
  error('you must specify a grid, climatology file, and output boundary file');
end
if (nargin < 4)
  epoch = [];
end

% First, create the boundary file
bry_write(grid,bryfile,epoch);

% Make sure we have a file
if (~exist(bryfile,'file'))
  error([bryfile ' could not be created']);
end

% If we were given a cell array, loop through and process each file
flen=1;
if iscell(climfile),
  flen=length(climfile);
end

for i=1:flen,

if iscell(climfile)
  cfile=char(climfile(i));
else
  cfile=climfile;
end
disp(cfile);

rec=[];
tendprev=nc_varget(climprev,'temp_time');tendprev=tendprev(end-1:end);
rec.bry_time = [tendprev;nc_varget(cfile,'temp_time')];
len=length(rec.bry_time);

% Create the masks
r2north= collapse(repmat(grid.maskr(end,:),[len 1]));
r2south= collapse(repmat(grid.maskr(1,:),[len 1]));
r2east = collapse(repmat(grid.maskr(:,end)',[len 1]));
r2west = collapse(repmat(grid.maskr(:,1)',[len 1]));
u2north= collapse(repmat(grid.masku(end,:),[len 1]));
u2south= collapse(repmat(grid.masku(1,:),[len 1]));
u2east = collapse(repmat(grid.masku(:,end)',[len 1]));
u2west = collapse(repmat(grid.masku(:,1)',[len 1]));
v2north= collapse(repmat(grid.maskv(end,:),[len 1]));
v2south= collapse(repmat(grid.maskv(1,:),[len 1]));
v2east = collapse(repmat(grid.maskv(:,end)',[len 1]));
v2west = collapse(repmat(grid.maskv(:,1)',[len 1]));
r3north= repmat(grid.maskr(end,:),[grid.n 1]);
r3north= collapse(repmat(reshape(r3north,[1 size(r3north)]),[len 1]));
r3south= repmat(grid.maskr(1,:),[grid.n 1]);
r3south= collapse(repmat(reshape(r3south,[1 size(r3south)]),[len 1]));
r3east = repmat(grid.maskr(:,end)',[grid.n 1]);
r3east = collapse(repmat(reshape(r3east,[1 size(r3east)]),[len 1]));
r3west = repmat(grid.maskr(:,1)',[grid.n 1]);
r3west = collapse(repmat(reshape(r3west,[1 size(r3west)]),[len 1]));
u3north= repmat(grid.masku(end,:),[grid.n 1]);
u3north= collapse(repmat(reshape(u3north,[1 size(u3north)]),[len 1]));
u3south= repmat(grid.masku(1,:),[grid.n 1]);
u3south= collapse(repmat(reshape(u3south,[1 size(u3south)]),[len 1]));
u3east = repmat(grid.masku(:,end)',[grid.n 1]);
u3east = collapse(repmat(reshape(u3east,[1 size(u3east)]),[len 1]));
u3west = repmat(grid.masku(:,1)',[grid.n 1]);
u3west = collapse(repmat(reshape(u3west,[1 size(u3west)]),[len 1]));
v3north= repmat(grid.maskv(end,:),[grid.n 1]);
v3north= collapse(repmat(reshape(v3north,[1 size(v3north)]),[len 1]));
v3south= repmat(grid.maskv(1,:),[grid.n 1]);
v3south= collapse(repmat(reshape(v3south,[1 size(v3south)]),[len 1]));
v3east = repmat(grid.maskv(:,end)',[grid.n 1]);
v3east = collapse(repmat(reshape(v3east,[1 size(v3east)]),[len 1]));
v3west = repmat(grid.maskv(:,1)',[grid.n 1]);
v3west = collapse(repmat(reshape(v3west,[1 size(v3west)]),[len 1]));

for v=1:length(vars),
  var=char(vars(v));
  % Load the climatology information
  clim = nc_varget(cfile,var);
  ntime=length(nc_varget(climprev,'temp_time'));
   if dims(v)==3
  climp=nc_varget(climprev,var,[ntime-2 0 0],[2 -1 -1]);
   else
  climp=nc_varget(climprev,var,[ntime-2 0 0 0],[2 -1 -1 -1]);
   end

  s=size(clim);
  if (dims(v) == 3)
    % north
    eval(sprintf('rec.%s_north = squeeze([climp(:,end,:);clim(:,end,:)]).*%c2north;', var, char(mask(v))));
    % south
    eval(sprintf('rec.%s_south = squeeze([climp(:,1,:);clim(:,1,:)]).*%c2south;', var, char(mask(v))));
    % east
    eval(sprintf('rec.%s_east = collapse([climp(:,:,end);clim(:,:,end)]).*%c2east;', var, char(mask(v))));
    % west
    eval(sprintf('rec.%s_west = collapse([climp(:,:,1);clim(:,:,1)]).*%c2west;', var, char(mask(v))));
  else
    % north
    eval(sprintf('rec.%s_north = squeeze([climp(:,:,end,:);clim(:,:,end,:)]).*%c3north;', var, char(mask(v))));
    % south
    eval(sprintf('rec.%s_south = squeeze([climp(:,:,1,:);clim(:,:,1,:)]).*%c3south;', var, char(mask(v))));
    % east
    eval(sprintf('rec.%s_east = collapse([climp(:,:,:,end);clim(:,:,:,end)]).*%c3east;', var, char(mask(v))));
    % west
    eval(sprintf('rec.%s_west = collapse([climp(:,:,:,1);clim(:,:,:,1)]).*%c3west;', var, char(mask(v))));
  end
  clear clim
end
nc_addnewrecs(bryfile,rec,'bry_time');
end

end %  function
