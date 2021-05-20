function handles=update_plot(h,handles)
%
% Update the values on the GUI
%
% Pierrick Penven 2004
%
set(handles.edit_imin,'String',num2str(handles.imin));
set(handles.edit_imax,'String',num2str(handles.imax));
set(handles.edit_jmin,'String',num2str(handles.jmin));
set(handles.edit_jmax,'String',num2str(handles.jmax));
%
handles.Lchild=1+handles.rcoeff*(handles.imax-handles.imin);
set(handles.editLchild,'String',num2str(handles.Lchild));
handles.Mchild=1+handles.rcoeff*(handles.jmax-handles.jmin);
set(handles.editMchild,'String',num2str(handles.Mchild));
%
if (~isempty(handles.Isrcparent)) & ~(isempty(handles.Jsrcparent))
  set(handles.edit_Isrcparent,'String',num2str(handles.Isrcparent));
  set(handles.edit_Jsrcparent,'String',num2str(handles.Jsrcparent));
  handles.Isrcchild=(handles.Isrcparent-handles.imin)*handles.rcoeff+...
                    floor(0.5*handles.rcoeff)+1;
  handles.Jsrcchild=(handles.Jsrcparent-handles.jmin)*handles.rcoeff+...
                    floor(0.5*handles.rcoeff)+1;
		    
  set(handles.edit_Isrcchild,'String',num2str(handles.Isrcchild));
  set(handles.edit_Jsrcchild,'String',num2str(handles.Jsrcchild));
end



%if (~isempty(handles.Isrcchild)) & ~(isempty(handles.Jsrcchild))
%  set(handles.edit_Isrcchild,'String',num2str(handles.Isrcchild));
%   set(handles.edit_Jsrcchild,'String',num2str(handles.Jsrcchild));
%end
%
plot_nestgrid(h,handles)
%
return
