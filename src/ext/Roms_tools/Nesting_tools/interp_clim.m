function handles=interp_clim(h,handles);
%
% Get everything in order to compute the child climatology file
%
% Pierrick Penven 2004
%
if isempty(handles.parentgrid)
  handles=get_parentclmname(h,handles);
end
if isempty(handles.childgrid)
  handles=get_childgrdname(h,handles); 
end
if isempty(handles.parentclm)
  handles=get_parentclmname(h,handles);
end
lev=str2num(handles.parentclm(end));
if isempty(lev)
  childname=[handles.parentclm,'.1'];
else
  childname=[handles.parentclm(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child climatology name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childclm=childname;
end
nested_clim(handles.childgrid,handles.parentclm,handles.childclm,...
            handles.vertical_correc,handles.extrapmask,handles.biol)
return
