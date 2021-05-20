function handles=get_nband(h,handles);
%
% Get the width of the band that is used to
% connect the parent-child topographies from the GUI
%
% Pierrick Penven 2004
%
%cae commented this out.  Don't know what edinband is for yet.
%  handles.nband=round(str2num(get(handles.editnband,'String')));
if isempty(handles.nband)
  handles.nband=10;
end
set(handles.editnband,'String',num2str(handles.nband));
return
