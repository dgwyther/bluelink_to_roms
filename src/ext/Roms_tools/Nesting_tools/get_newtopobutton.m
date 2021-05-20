function handles=get_newtopobutton(h,handles);
%
% Button to set a new topography for the child grid
% instead of just interpolating the parent topography.
%
% Pierrick Penven 2004
%
if handles.newtopo==0
  handles.newtopo = 1;
  if isempty(handles.toponame);
    handles=get_topofile(h,handles);
  end
else
  handles.newtopo = 0;
end
return
