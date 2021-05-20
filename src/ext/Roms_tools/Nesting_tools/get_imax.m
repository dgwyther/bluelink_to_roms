function handles=get_imax(h,handles);
%
% Get the imin position of the embedded grid
%
% Pierrick Penven 2004
%
imax=round(str2num(get(handles.edit_imax,'String')));
if imax>handles.imin & imax>1
 handles.imax=imax; 
end
%
handles=update_plot(h,handles);
%
return
