function h=grid_frame(grid, varargin)
%   GRID_FRAME   Draw a frame around the grid region
%     GRID_FRAME(GRID, VARARGIN)
% 
%   Draws a frame around the edges of the grid
%   
%   Created by Brian Powell on 2010-01-27.
%   Copyright (c)  Univ. of Hawaii. All rights reserved.

h=plot([grid.lonr(1,:)'; grid.lonr(:,end); grid.lonr(end,end:-1:1)'; grid.lonr(end:-1:1,1)], ...
     [grid.latr(1,:)'; grid.latr(:,end); grid.latr(end,end:-1:1)'; grid.latr(end:-1:1,1)], ...
     varargin{:});

end %  function