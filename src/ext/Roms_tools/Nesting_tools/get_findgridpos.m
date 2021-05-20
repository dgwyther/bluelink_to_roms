function handles=get_findgridpos(h,handles)
%
% Get imin,imax,jmin,jmax (the child grid positions)
% from the mouse.
%
% Pierrick Penven 2004
%
nc=netcdf(handles.parentgrid,'nowrite');
if isempty(nc)
  disp('Please open a netcdf file !!!')
  handles=get_parentgrdname(h,handles);
  return
end
plon=nc{'lon_psi'}(:);
plat=nc{'lat_psi'}(:);
close(nc)
%
% Get the child grid
%
%
waitforbuttonpress
xy=get(gca,'currentpoint');
x=xy(1,1);
y=xy(1,2);
[lon1,lat1]=m_xy2ll(x,y);
rbbox  
xy=get(gca,'currentpoint');
x=xy(1,1);
y=xy(1,2);
[lon2,lat2]=m_xy2ll(x,y);
if lon1==lon2 | lat1==lat2
  return
end
dist=spheric_dist(plat,lat1,plon,lon1);
[j1,i1]=find(dist==min(min(dist)));
dist=spheric_dist(plat,lat2,plon,lon2);
[j2,i2]=find(dist==min(min(dist)));
%
handles.imin=min([i1 i2]);
handles.imax=max([i1 i2]);
handles.jmin=min([j1 j2]);
handles.jmax=max([j1 j2]);
%
handles=update_plot(h,handles);
%
return
