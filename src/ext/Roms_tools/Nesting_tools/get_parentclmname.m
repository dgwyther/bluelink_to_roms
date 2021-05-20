function handles=get_parentclmname(h,handles)
%
% Get the name of the parent climatology  file from the GUI
%
% Pierrick Penven 2004
%
[filename, pathname] = uigetfile({'*.nc*', 'All netcdf-Files (*.nc*)'; ...
		'*.*','All Files (*.*)'},'PARENT CLIMATOLOGY');
if isequal([filename,pathname],[0,0])
  return
end
handles.parentclm=fullfile(pathname,filename);
nc=netcdf(handles.parentclm,'nowrite');
if isempty(nc)
  disp('Warning : this is not a netcdf file !!!')
  handles.parentclm=[];
  return
end
close(nc);
return
