function [grid, x, y, pixx, pixy] = makegrid(locx, locy, z)

% function [grid, x, y, pixx, pixy] = makegrid(x, y, z)
%
% Given three vectors (paired), location x, location y, and value z,
% return a matrix, grid, and the labels, x and y for use
% with grids in interp2, etc.
% Assumptions are made that the locx and locy vectors are already
% fairly evenly spaced.  Irregular grids could return strange results.
tmp = unique(locx);
dx = median(tmp(2:end)-tmp(1:end-1));
tmp = unique(locy);
dy = median(tmp(2:end)-tmp(1:end-1));
pixx = floor(( locx - min(locx) )/dx) + 1;
pixy = floor(( locy - min(locy) )/dy) + 1;
x = [min(locx):dx:max(locx)];
y = [min(locy):dy:max(locy)];
grid = ones(length(y), length(x))*nan;
for i=1:length(pixx),
  grid(pixy(i),pixx(i))=z(i);
end