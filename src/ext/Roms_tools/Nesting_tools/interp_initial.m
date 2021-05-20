function handles=interp_initial(h,handles);
%
% Get everything in order to compute the child initial file
%
% Pierrick Penven 2004
%
if isempty(handles.parentgrid)
  handles=get_parentininame(h,handles);
end
if isempty(handles.childgrid)
  handles=get_childgrdname(h,handles); 
end
if isempty(handles.parentini)
  handles=get_parentininame(h,handles);
end
lev=str2num(handles.parentini(end));
if isempty(lev)
  childname=[handles.parentini,'.1'];
else
  childname=[handles.parentini(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child initial name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childini=childname;
end
nested_initial(handles.childgrid,handles.parentini,handles.childini,...
               handles.vertical_correc,handles.extrapmask,handles.biol)
return
