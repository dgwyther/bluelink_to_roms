function handles=get_imin(h,handles);
%
% Get the imin position of the embedded grid
%
% Pierrick Penven 2004
%
imin=round(str2num(get(handles.edit_imin,'String')));
if imin<handles.imax & imin>1
 handles.imin=imin; 
end
%
handles=update_plot(h,handles);
%
return
