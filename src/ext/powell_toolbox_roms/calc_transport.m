function trans = calc_transport(grid,u,v,lon1,lat1,lon2,lat2,h)
%   CALC_TRANSPORT   Short description
%     [TRANS] = CALC_TRANSPORT(GRID,U,V,LON1,LAT1,LON2,LAT2,[H])
% 
% Calculate the time series of transport from the given velocity field
% and grid

if nargin<8,
  h=[];
end

if (ndims(u)<4)
  u=reshape(u,[1 size(u)]);
end
if (ndims(v)<4)
  v=reshape(v,[1 size(v)]);
end
dx=1./grid.pm;
dy=1./grid.pn;
[z,zw,hz]=grid_depth(grid);
trans=nan;

% Calculate the points
[x,y]=latlon_grid(grid.filename,[lon1; lon2],[lat1; lat2],1);
x=round(x)+1;
y=round(y)+1;
ang=abs(atan2(y(2)-y(1),x(2)-x(1)));
[x,y]=calc_line(x,y);
% m=grid.maskr; l=sub2ind(size(m),y,x); m(l)=2;
% clf; pcolor_center(grid.lonr,grid.latr,m); hold on; plot([lon1 lon2],[lat1 lat2],'k');

for t=1:size(u,1),
  if (~isempty(h)),
    [z,zw,hz]=grid_depth(grid,'r',squeeze(h(t,:,:)));
  end
  tr=0;
  for l=1:length(x),
    i=x(l);
    j=y(l);
    for k=1:size(u,2),
      tr = nansum([tr (u(t,k,j,i)*0.5*(dy(j,i)+dy(j,i+1))*0.5*(hz(k,j,i)+hz(k,j,i+1))*sin(ang) +  ...
                       v(t,k,j,i)*0.5*(dx(j,i)+dx(j+1,i))*0.5*(hz(k,j,i)+hz(k,j+1,i))*cos(ang))]);
    end
  end
  trans(t)=tr*1e-6;
end

end %  function