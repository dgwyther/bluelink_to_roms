function handles=get_parentrstname(h,handles)
%
% Get the name of the parent restart file from the GUI
%
% Pierrick Penven 2004
%
[filename, pathname] = uigetfile({'*.nc*', 'All netcdf-Files (*.nc*)'; ...
		'*.*','All Files (*.*)'},'PARENT RESTART');
if isequal([filename,pathname],[0,0])
  return
end
handles.parentrst=fullfile(pathname,filename);
nc=netcdf(handles.parentrst,'nowrite');
if isempty(nc)
  disp('Warning : this is not a netcdf file !!!')
  handles.parentrst=[];
  return
end
close(nc);
return
