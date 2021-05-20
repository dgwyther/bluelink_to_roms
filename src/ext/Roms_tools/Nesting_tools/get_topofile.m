function handles=get_topofile(h,handles)
%
% Get the name of the topography file from the GUI
%
% Pierrick Penven 2004
%
[filename, pathname] = uigetfile({'*.nc', 'All netcdf-Files (*.nc)'; ...
		'*.*','All Files (*.*)'},'TOPO FILE');
if isequal([filename,pathname],[0,0])
  return
end
handles.toponame=fullfile(pathname,filename);
nc=netcdf(handles.toponame,'nowrite');
if isempty(nc)
  disp('Warning : this is not a netcdf file')
  handles.toponame=[];
  return
end
return
