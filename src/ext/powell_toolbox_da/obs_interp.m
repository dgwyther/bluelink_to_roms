function [obs] = obs_interp(obs, grid1, grid2)

% OBS_INTERP   Convert obs from one grid to the other
%
% Given observations on grid1, convert them to grid2
% 
% SYNTAX
%   [OBS] = OBS_INTERP(OBS, GRID1, GRID2)
% 

%
% Created by Brian Powell on 2006-12-19.
% Copyright (c)  powellb. All rights reserved.
%

if ( nargin<3 )
  error(['You must specify both grids']);
end

% Set up the geographic arrays
lat = obs.x*0;
lon = lat;

% First the 'rho' grid
l=find(obs.type==1 | obs.type==6 | obs.type==7 );
if ( ~isempty(l) )
  [i,j]=meshgrid([0:size(grid1.maskr,2)-1],[0:size(grid1.maskr,1)-1]);
  lat(l) = griddata(i,j,grid1.latr,obs.x(l),obs.y(l));
  lon(l) = griddata(i,j,grid1.lonr,obs.x(l),obs.y(l));
end

% Next, the 'u' grid
l=find(obs.type==2 | obs.type==4 );
if ( ~isempty(l) )
  [i,j]=meshgrid([0:size(grid1.masku,2)-1],[0:size(grid1.masku,1)-1]);
  lat(l) = griddata(i,j,grid1.latu,obs.x(l),obs.y(l),'linear',{'QJ'});
  lon(l) = griddata(i,j,grid1.lonu,obs.x(l),obs.y(l),'linear',{'QJ'});
end

% Finally, the 'v' grid
l=find(obs.type==3 | obs.type==5 );
if ( ~isempty(l) )
  [i,j]=meshgrid([0:size(grid1.maskv,2)-1],[0:size(grid1.maskv,1)-1]);
  lat(l) = griddata(i,j,grid1.latv,obs.x(l),obs.y(l),'linear',{'QJ'});
  lon(l) = griddata(i,j,grid1.lonv,obs.x(l),obs.y(l),'linear',{'QJ'});
end

% Convert lat/lon to the new grid
[obs.x,obs.y] = latlon_grid(grid2.filename,lon,lat);
l=find(~isnan(obs.x));
obs=delstruct(obs,l,length(obs.x));


