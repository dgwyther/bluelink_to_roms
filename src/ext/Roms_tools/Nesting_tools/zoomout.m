function handles=zoomout(h,handles)
%
% Zoom to fit the parent domain
%
% Pierrick Penven 2004
%
nc=netcdf(handles.parentgrid,'nowrite');
if isempty(nc)
  disp('Warning : please open a netcdf file !!!')
  return
end
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
handles.lonmin=min(min(lon));
handles.lonmax=max(max(lon));
handles.latmin=min(min(lat));
handles.latmax=max(max(lat));
close(nc)
plot_nestgrid(h,handles)
return
