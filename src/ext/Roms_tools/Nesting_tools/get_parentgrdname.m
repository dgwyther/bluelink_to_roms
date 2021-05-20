function handles=get_parentgrdname(h,handles);
%
% Get the name of the parent grid file from the GUI
%
% Pierrick Penven 2004
%
[filename, pathname] = uigetfile({'*.nc*', 'All netcdf-Files (*.nc*)'; ...
		'*.*','All Files (*.*)'},'PARENT GRID');
handles=reset_handle(h,handles);
if isequal([filename,pathname],[0,0])
  return
end
handles.parentgrid=fullfile(pathname,filename);
nc=netcdf(handles.parentgrid,'nowrite');
if isempty(nc)
  disp('Warning : this is not a netcdf file !!!')
  handles.parentgrid=[];
  return
end
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
h=nc{'h'}(:);
[handles.Mparent,handles.Lparent]=size(lon);
handles.lonmin=min(min(lon));
handles.lonmax=max(max(lon));
handles.latmin=min(min(lat));
handles.latmax=max(max(lat));
handles.hmin=min(min(h));
set(handles.edithmin,'String',num2str(handles.hmin));
close(nc);
%
handles.imin=2;
handles.imax=handles.Lparent-2;
handles.jmin=2;
handles.jmax=handles.Mparent-2;
%
handles=update_plot(h,handles);
%
return
