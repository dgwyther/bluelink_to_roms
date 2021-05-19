function tlm_write(file, tlm, grid, rec)

% TLM_WRITE   Write TLM vector back out
%
% Given a vector of TLM values, write it back into the netcdf structure
% That it originally came from
% 
% SYNTAX
%   TLM_WRITE(FILE, TLM, GRID, REC)
% 

if ( nargin < 3 )
  error('You must supply filename, tlm, and options');
end
if ( nargin < 4 )
  rec = 1;
end

% Grab the grid
% g = grid_read( grid );
% g.maskr(find(~g.maskr))=nan;
% g.masku(find(~g.masku))=nan;
% g.maskv(find(~g.maskv))=nan;

% Load the data from the TLM file
% u    = nc_varget(file,'u',[rec-1 0 0 0],[1 -1 -1 -1]) * 0;
% v    = nc_varget(file,'v',[rec-1 0 0 0],[1 -1 -1 -1]) * 0;
% temp = nc_varget(file,'temp',[rec-1 0 0 0],[1 -1 -1 -1]) * 0;
% salt = nc_varget(file,'salt',[rec-1 0 0 0],[1 -1 -1 -1]) * 0;

% Make the grids useful
% g.maskr = reshape( g.maskr, [1 1 size(g.maskr)]);
% g.masku = reshape( g.masku, [1 1 size(g.masku)]);
% g.maskv = reshape( g.maskv, [1 1 size(g.maskv)]);

% Fill a full netcdf record with our data
% data = [ zeta(:); u(:); v(:); temp(:); salt(:); ];
% mask = [ g.maskr(:); 
%          vector(g.masku(:,ones(size(u,2),1),:,:));
%          vector(g.maskv(:,ones(size(v,2),1),:,:));
%          vector(g.maskr(:,ones(size(temp,2),1),:,:));
%          vector(g.maskr(:,ones(size(salt,2),1),:,:));
%        ];
% data(find(~isnan(mask))) = tlm;

% Save each variable
count = 1;

% Zeta
var = nc_varget(file,'zeta',[rec-1 0 0],[1 -1 -1]) * 0;
len = length(var(:));
var(1,:) = tlm(count:count+len-1);
nc_varput(file,'zeta',var,[rec-1 0 0],size(var));
count = count+len;

% Remaining
vars={ 'u' 'v' 'temp' 'salt' };
for i=1:length(vars),
  v = char(vars(i));
  var = nc_varget(file,v,[rec-1 0 0 0],[1 -1 -1 -1]) * 0;
  len = length(var(:));
  var(1,:) = tlm(count:count+len-1);
  nc_varput(file,v,var,[rec-1 0 0 0],size(var));
  % eval(sprintf('len = length(%s(:));',var));
  % eval(sprintf('%s(1,:) = tlm(count:count+len-1);',var));
  % eval(sprintf('nc_varput(file,char(vars(i)),%s,[rec-1 0 0 0],size(%s));',var,var));
  count = count + len;
end

        