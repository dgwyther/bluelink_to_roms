function nest_weight_matrix(parent_grid,child_grid,weighting)

% function nest_weight_matrix(parent_grid,child_grid,gridsize)
%
% Given two grids and the decorrelation weighting size in cell number
% (default 10), create a mapping for OI between the two and save the file.
%
% This function is for use with roms_nest_clim and roms_z_clim

if nargin<2
  error('You must specify two grids');
  return
end
if nargin<3
  weighting=10;
end

parent_name=regexprep(regexprep(regexprep(parent_grid.filename,'.*/',''),'\.nc',''), ...
                  '(roms|grid)[-_]*','');
child_name=regexprep(regexprep(regexprep(child_grid.filename,'.*/',''),'\.nc',''), ...
                  '(roms|grid)[-_]*','');
pmapname=[parent_name '-' child_name '_pmap.mat'];
pmapr=rnt_oapmap(parent_grid.lonr',parent_grid.latr',parent_grid.maskr', ...
                 child_grid.lonr',child_grid.latr',weighting);
pmapu=rnt_oapmap(parent_grid.lonu', ...
                 parent_grid.latu', ...
                 parent_grid.masku', ...
                 child_grid.lonu',child_grid.latu',weighting);
pmapv=rnt_oapmap(parent_grid.lonv', ...
                 parent_grid.latv', ...
                 parent_grid.maskv', ...
                 child_grid.lonv',child_grid.latv',weighting);
evalc(['save ' pmapname ' pmapr pmapu pmapv']);
