function grid_trace(grid, varargin)
% Draw an outline box around a grid
%   Created by Brian Powell on 2010-06-29.
%   Copyright (c)  Univ. of Hawaii. All rights reserved.

lon = [ grid.lonr(1,:) grid.lonr(:,end)' fliplr(grid.lonr(end,:)) flipud(grid.lonr(:,1))' ];
lat = [ grid.latr(1,:) grid.latr(:,end)' fliplr(grid.latr(end,:)) flipud(grid.latr(:,1))' ];

plot(lon,lat,varargin{:})

end %  function