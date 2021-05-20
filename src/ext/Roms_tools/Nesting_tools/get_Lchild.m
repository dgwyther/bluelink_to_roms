function handles=get_Lchild(h,handles);
%
% Get Lchild (xi child dimension) from the GUI
%
% Pierrick Penven 2004
%
handles.Lchild = round(str2num(get(handles.editLchild,'String')));
if ~(handles.Lchild>1)
  handles.Lchild=2;
end
set(handles.editLchild,'String',num2str(handles.Lchild));
handles.imax=floor(min([handles.Lparent-1 ...
                        handles.imin+(handles.Lchild-1)/handles.rcoeff]));
%
handles=update_plot(h,handles);
%
return
