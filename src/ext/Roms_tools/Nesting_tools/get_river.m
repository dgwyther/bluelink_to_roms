function handles=get_river(h,handles);
%
% Get the river position
%
% Pierrick Penven 2004
%

%
% Get the position of the psi points
%
nc=netcdf(handles.parentgrid,'nowrite');
if isempty(nc)
  disp('Please open a netcdf file !!!')
  return
end
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
close(nc)
%
% Get the river
%
[x,y] = ginput(1);
[lon1,lat1]=m_xy2ll(x,y);
dist=spheric_dist(lat,lat1,lon,lon1);
[j1,i1]=find(dist==min(min(dist)));
lon1=lon(j1,i1);
lat1=lat(j1,i1);
handles.Isrcparent=i1-1;
handles.Jsrcparent=j1-1;
%
handles=update_plot(h,handles);
%
return
