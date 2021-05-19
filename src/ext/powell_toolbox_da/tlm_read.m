function [tlm, ocean, len] = tlm_read(file, grid, rec)

% TLM_READ   Load the tlm records from a time record
%
% Create a single state vector from the TLM file using the final time
% record and the given number of layers from the surface
% 
% SYNTAX
%   [TLM] = TLM_READ(FILE, GRID, REC)
% 

if ( nargin < 2 )
  error('You must supply filename and options');
end
if ( nargin < 3 )
  rec = 1;
end

type=1;
% Grab the grid
g = grid_read( grid );
g.maskr(find(~g.maskr))=nan;
g.masku(find(~g.masku))=nan;
g.maskv(find(~g.maskv))=nan;

% Load the data from the TLM file
zeta = squeeze(nc_varget(file,'zeta',[rec-1 0 0],[1 -1 -1]));
u    = squeeze(nc_varget(file,'u',[rec-1 0 0 0],[1 -1 -1 -1]));
v    = squeeze(nc_varget(file,'v',[rec-1 0 0 0],[1 -1 -1 -1]));
temp = squeeze(nc_varget(file,'temp',[rec-1 0 0 0],[1 -1 -1 -1]));
salt = squeeze(nc_varget(file,'salt',[rec-1 0 0 0],[1 -1 -1 -1]));

% Calculate the length of ocean points
zeta_len = length(find(~isnan(g.maskr)));
u_len = length(find(~isnan(g.masku))) * size(u,1);
v_len = length(find(~isnan(g.maskv))) * size(v,1);
ts_len = 2 * length(find(~isnan(g.maskr))) * size(temp,1);
ocean = zeta_len + u_len + v_len + ts_len;

% Make the grids useful
% g.maskr = reshape( g.maskr, [1 size(g.maskr)]);
% g.masku = reshape( g.masku, [1 size(g.masku)]);
% g.maskv = reshape( g.maskv, [1 size(g.maskv)]);

% Apply the grids
% zeta = zeta .* squeeze(g.maskr);
% u = u .* g.masku(ones(size(u,1),1),:,:);
% v = v .* g.maskv(ones(size(v,1),1),:,:);
% temp = temp .* g.maskr(ones(size(temp,1),1),:,:);
% salt = salt .* g.maskr(ones(size(salt,1),1),:,:);

% tlm = rmnan([ zeta(:); u(:); v(:); temp(:); salt(:); ]);
tlm = [ zeta(:); u(:); v(:); temp(:); salt(:); ];
len.zeta_idx = [1:length(zeta(:))];
len.zeta_len = zeta_len;
len.u_idx = [len.zeta_idx(end)+1:len.zeta_idx(end)+length(u(:))];
len.u_len = u_len;
len.v_idx = [len.u_idx(end)+1:len.u_idx(end)+length(v(:))];
len.v_len = v_len;
len.temp_idx = [len.v_idx(end)+1:len.v_idx(end)+length(temp(:))];
len.temp_len = ts_len/2;
len.salt_idx = [len.temp_idx(end)+1:len.temp_idx(end)+length(salt(:))];
len.salt_len = ts_len/2;

if ( isempty(tlm) ) 
  error(['The TLM file ' file ' is empty']);
end

