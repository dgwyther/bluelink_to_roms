function handles=get_rfactor(h,handles);
%
% Get the max r-factor(grad(H)/H) from the GUI
%
% Pierrick Penven 2004
%
%CVL testing lines
handles.editrfactor
get(handles.editrfactor,'String')
%
handles.rfactor=str2num(get(handles.editrfactor,'String'));
if isempty(handles.rfactor)
  handles.rfactor=0.2;
end
set(handles.editrfactor,'String',num2str(handles.rfactor));
return
