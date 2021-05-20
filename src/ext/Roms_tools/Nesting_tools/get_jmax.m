function handles=get_jmax(h,handles);
%
% Get the jmax position of the embedded grid
%
% Pierrick Penven 2004
%
jmax=round(str2num(get(handles.edit_jmax,'String')));
if jmax>handles.jmin & jmax<handles.Mparent
 handles.jmax=jmax; 
end
%
handles=update_plot(h,handles);
%
return
