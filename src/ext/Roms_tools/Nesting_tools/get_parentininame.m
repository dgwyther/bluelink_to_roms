function handles=get_parentininame(h,handles)
%
% Get the name of the parent initial file from the GUI
%
% Pierrick Penven 2004
%
[filename, pathname] = uigetfile({'*.nc*', 'All netcdf-Files (*.nc*)'; ...
		'*.*','All Files (*.*)'},'PARENT INITIAL');
if isequal([filename,pathname],[0,0])
  return
end
handles.parentini=fullfile(pathname,filename);
nc=netcdf(handles.parentini,'nowrite');
if isempty(nc)
  disp('Warning : this is not a netcdf file !!!')
  handles.parentini=[];
  return
end
close(nc);
return
