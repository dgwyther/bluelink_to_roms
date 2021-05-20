function handles=get_rcoef(h,handles);
%
% Get the embedding refinment coefficient from the GUI
%
% Pierrick Penven 2004
%
handles.rcoeff=round(str2num(get(handles.edit_rcoef,'String')));
set(handles.edit_rcoef,'String',num2str(handles.rcoeff));
handles.Lchild=1+handles.rcoeff*(handles.imax-handles.imin);
set(handles.editLchild,'String',num2str(handles.Lchild));
handles.Mchild=1+handles.rcoeff*(handles.jmax-handles.jmin);
set(handles.editMchild,'String',num2str(handles.Mchild));
return
