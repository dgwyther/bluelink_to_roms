function handles=get_Mchild(h,handles);
%
% Get Mchild (eta child dimension) from the GUI
%
% Pierrick Penven 2004
%
handles.Mchild = round(str2num(get(handles.editMchild,'String')));
if ~(handles.Mchild>1)
  handles.Mchild=2;
end
set(handles.editMchild,'String',num2str(handles.Mchild));
handles.jmax=floor(min([handles.Mparent-1 ...
                        handles.jmin+(handles.Mchild-1)/handles.rcoeff]));
%
handles=update_plot(h,handles);
%
return
