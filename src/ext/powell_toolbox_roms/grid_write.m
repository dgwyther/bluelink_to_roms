function grid=grid_write( grid )
  
% Give a grid structure with the following data, construct
% a new ROMS grid file:
%
% grid.name        : string
% grid.latr        : rho-points latitute (Mp,Lp)
% grid.lonr        : rho-points longitude (Mp,Lp)
% grid.maskr       : rho-points mask (Mp,Lp)
% grid.h           : rho-points bath (Mp,Lp)
% grid.angle       : optional (default 0)
% hgrid.n          : optional (default 30)
% hgrid.theta_s    : optional (default 5)
% hgrid.theta_b    : optional (default 0.4)
% hgrid.tcline     : optional (default 50)
% hgrid.hc         : optional (default 0)


% Construct new grid file
Lm=size(grid.lonr,2);
Mm=size(grid.lonr,1);
c_grid(Lm,Mm,grid.name);
%ngrid.spheric='t';
ngrid.name=grid.name;
ngrid.rlat=grid.latr';
ngrid.rlon=grid.lonr';
ngrid.h=grid.h';
ngrid.rmask=grid.maskr';
w_grid(ngrid);
[pm,pn,dndx,dmde]=get_metrics(ngrid.name);
nc_varput(grid.name,'pm',pm);
nc_varput(grid.name,'pn',pn);
nc_varput(grid.name,'dndx',dndx);
nc_varput(grid.name,'dmde',dmde);

% Construct the dimensions
if ( ~isfield(grid,'angle') ) 
  grid.angle = ones(size(grid.maskr))*1e-14;
end
nc_varput(grid.name,'angle',grid.angle);
[x,y]=meshgrid([0:Lm-1],[0:Mm-1]);
x=x./pm;
y=y./pn;
ngrid.xl=max(x(:));
ngrid.el=max(y(:));
ngrid.rx=x';
ngrid.ry=y';
w_grid(ngrid);

% Construct the meta information
if ( ~isfield(grid,'n') ) 
  grid.n=30;
end
if ( ~isfield(grid,'theta_s') ) 
grid.theta_s=3;
  end
if ( ~isfield(grid,'theta_b') ) 
grid.theta_b=0.4;
  end
if ( ~isfield(grid,'tcline') ) 
  grid.tcline=0;
end
if ( ~isfield(grid,'hc') ) 
  grid.hc=0;
end
grid_meta_data(grid,grid.name);

grid=grid_read(grid.name);
