function handles=get_hmin(h,handles);
%
% Get the minimum topography of the child grid from the GUI
%
% Pierrick Penven 2004
%
handles.hmin = str2num(get(handles.edithmin,'String'));
set(handles.edithmin,'String',num2str(handles.hmin));
return
