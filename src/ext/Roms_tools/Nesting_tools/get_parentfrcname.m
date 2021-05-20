function handles=get_parentfrcname(h,handles)
%
% Get the name of the parent forcing  file from the GUI
%
% Pierrick Penven 2004
%
[filename, pathname] = uigetfile({'*.nc*', 'All netcdf-Files (*.nc*)'; ...
		'*.*','All Files (*.*)'},'PARENT FORCING');
if isequal([filename,pathname],[0,0])
  return
end
handles.parentfrc=fullfile(pathname,filename);
nc=netcdf(handles.parentfrc,'nowrite');
if isempty(nc)
  disp('Warning : this is not a netcdf file !!!')
  handles.parentfrc=[];
  return
end
close(nc);
return
