function handles=get_jmin(h,handles);
%
% Get the jmin position of the embedded grid
%
% Pierrick Penven 2004
%
jmin=round(str2num(get(handles.edit_jmin,'String')));
if jmin<handles.jmax & jmin>1
 handles.jmin=jmin;
end
%
handles=update_plot(h,handles);
%
return
