function handles=interp_restart(h,handles);
%
% Get everything in order to compute the child restart file
%
% Pierrick Penven 2004
%
if isempty(handles.parentgrid)
  handles=get_parentrstname(h,handles);
end
if isempty(handles.childgrid)
  handles=get_childgrdname(h,handles); 
end
if isempty(handles.parentrst)
  handles=get_parentrstname(h,handles);
end
lev=str2num(handles.parentrst(end));
if isempty(lev)
  childname=[handles.parentrst,'.1'];
else
  childname=[handles.parentrst(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child restart name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childrst=childname;
end
nested_restart(handles.childgrid,handles.parentrst,handles.childrst, ...
               handles.vertical_correc,handles.extrapmask,handles.biol)
return
